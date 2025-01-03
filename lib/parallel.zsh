# Copyright 2020-2024, Hojin Koh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Parallel-related helpers

doParallelPipeCsv() {
  local nj=$1
  local nr=$2
  local dirTempPipe=$3
  local func=$4

  # Create a space to hold pipes
  mkdir -p $dirTempPipe/_pipes

  # Create input/output pipes
  local -a pipesOutput
  local -a pipesInput
  for i in $(seq -f '%03.0f' 0 $[nj-1]); do
    mkfifo $dirTempPipe/_pipes/_input.$i
    pipesInput+=( $dirTempPipe/_pipes/_input.$i )
    mkfifo $dirTempPipe/_pipes/_output.$i
    pipesOutput+=( $dirTempPipe/_pipes/_output.$i )
  done

  # Split the input from stdin
  local pidSplit
  #split -da 3 -n r/$nj /dev/stdin $dirTempPipe/_pipes/_input. & pidSplit=$!
  local pipeKey=$dirTempPipe/_pipes/_keys
  mkfifo "$pipeKey"
  $MORDIO_ROOT_DIR/bin/splitCsv.py "$pipeKey" "${pipesInput[@]}" & pidSplit=$!

  # Spawn things
  local -a pids
  local i
  for i in $(seq -f '%03.0f' 0 $[nj-1]); do
    local INPUT=$dirTempPipe/_pipes/_input.$i
    if [[ $func == *INPUT* ]]; then
      eval "$func"
    else
      eval "$func" <"$INPUT"
    fi \
    > $dirTempPipe/_pipes/_output.$i & pids+=( $! )
  done
  info "Spawned subprocesses ($nj) ${pids[*]}"

  # Merge output from pipe into stdout
  $MORDIO_ROOT_DIR/bin/mergeParallelCsv.py "$pipeKey" "${pipesOutput[@]}" \
  | lineProgressBar $nr

  # Wait all processes
  wait $pidSplit
  for pid in "${pids[@]}"; do
    wait $pid
  done
}
