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

# Check whether the script need to run

getScriptSum() {
  cat "$ZSH_ARGZERO" "${dependencies[@]-/dev/null}" | md5sum | cut -d' ' -f1
}

isAllOlder() {
  local var1="$1"
  local var2="$2"

  local filelist1="$(${var1}::ALL::getMainFile)"
  local filelist2="$(${var2}::ALL::getMainFile)"

  local aFile1=( "${(f)filelist1}" )
  local aFile2=( "${(f)filelist2}" )

  local f1
  local f2
  for f1 in "${aFile1[@]}"; do
    for f2 in "${aFile2[@]}"; do
      if [[ ! "$f1" -ot "$f2" ]]; then
        return 1
      fi
    done
  done
  return 0
}

opt -Mordio bump '' "Bump the metadata of output files without actually re-run the script"

# Check if all input data is older than all output data, and the script checksum didn't change
# If no need to run, return 0, else return 1
MORDIO::FLOW::check() {
  local aVarIn=()
  local aVarOut=()
  for arg in "${(k)mordioMapOptType[@]}"; do
    if [[ "${mordioMapOptDirection[$arg]}" == "input" ]]; then
      aVarIn+=( "$arg" )
    else
      aVarOut+=( "$arg" )
    fi
  done

  # No output, don't do check here, always run
  if [[ "${#aVarOut[@]}" == 0 ]]; then
    return 1
  fi

  local arg1
  local arg2
  for arg2 in "${aVarOut[@]}"; do
    ${arg2}::ALL::checkValid debug
  done

  # Now that all output exists, just bump the meta file and update the timestamp
  # So that we don't need to re-run
  if [[ $bump == true ]]; then
    MORDIO::FLOW::writeMeta # Pretending we DID generated these output
    for arg2 in "${aVarOut[@]}"; do
      info "Bumping metadata for $arg2=${(P)arg2[*]}"
      touch ${(z)$(${arg2}::ALL::getMainFile)} /dev/null # /dev/null ensure we always has at least 1 argument to touch
    done
    return 0
  fi

  for arg2 in "${aVarOut[@]}"; do
    for arg1 in "${aVarIn[@]}"; do
      if ! isAllOlder "$arg1" "$arg2"; then
        warn "$arg1 not older than $arg2, will rerun"
        return 1
      fi
    done
    if ! ${arg2}::ALL::checkScriptSum; then
      warn "Script changed for $arg2, will rerun"
      return 1
    fi
  done

  return 0
}

# Hijack check if user didn't define it
if ! declare -f check >/dev/null; then
  check() {
    MORDIO::FLOW::check "$@"
  }
fi
