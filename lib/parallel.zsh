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

doParallelPipeText() {
  local nj=$1
  local nr=$2
  local fileIdList=$3
  local dirTempPipe=$4
  local func=$5

  # Create a space to hold pipes
  mkdir -p $dirTempPipe/_pipes

  # Create input/output pipes
  local -a pipesOutput
  for i in $(seq -f '%03.0f' 0 $[nj-1]); do
    mkfifo $dirTempPipe/_pipes/_input.$i
    mkfifo $dirTempPipe/_pipes/_output.$i
    pipesOutput+=( $dirTempPipe/_pipes/_output.$i )
  done

  # Progress bar
  local fdPV
  exec {fdPV}> >(exec lineProgressBar $nr >/dev/null)

  # Split the input from stdin
  local pidSplit
  split -da 3 -n r/$nj /dev/stdin $dirTempPipe/_pipes/_input. & pidSplit=$!

  # Spawn things
  local -a pids
  local i
  for i in $(seq -f '%03.0f' 0 $[nj-1]); do
    local INPUT=$dirTempPipe/_pipes/_input.$i
    if [[ $func == *INPUT* ]]; then
      ( eval "$func" | tee $dirTempPipe/_pipes/_output.$i >&${fdPV} ) & pids+=( $! )
    else
      ( cat "$INPUT" | eval "$func" | tee $dirTempPipe/_pipes/_output.$i >&${fdPV} ) & pids+=( $! )
    fi
  done
  info "Spawned subprocesses ($nj) ${pids[*]}"
  exec {fdPV}<&-

  # Merge output from pipe into stdout
  $MORDIO_ROOT_DIR/bin/mergeParallelText.py "$fileIdList" "${pipesOutput[@]}"

  # Wait all processes
  wait $pidSplit
  for pid in "${pids[@]}"; do
    wait $pid
  done
}

computeMIMOStride() {
  local __argMain=$1
  shift
  local __argRest=( "$@" )

  # Initialize
  for __arg in "${__argRest[@]}"; do
    declare -g "STRIDE_$__arg=${(P)#__argMain}"
  done

  # If output count is 1, then everything below isn't necessary
  if [[ ${(P)#__argMain} -le 1 ]]; then return; fi

  for __arg in "${__argRest[@]}"; do
    # If there is only one, then the default stride is fine
    if [[ ${(P)#__arg} -le 1 ]]; then continue; fi
    if [[ $[${(P)#__argMain}%${(P)#__arg}] -ne 0 ]]; then
      err "\$$__argMain should have the same or integer multiple length with \$$__arg" 15
    fi
    eval "STRIDE_$__arg=$[${(P)#__argMain}/${(P)#__arg}]"
  done
}

computeMIMOIndex() {
  local __idx=$1
  shift
  local __argMain=$1
  shift
  local __argRest=( "$@" )

  local __infoSet
  for __arg in "${__argRest[@]}"; do
    local __varStride=STRIDE_$__arg
    local __varIndex=INDEX_$__arg
    declare -g "$__varIndex=$[(i-1)/${(P)__varStride}+1]"
    __infoSet+="${__arg}[${(P)__varIndex}] "
  done
  info "Processing set $__idx/${(P)#__argMain}: $__infoSet${${(P)__argMain}[$i]}"
}
