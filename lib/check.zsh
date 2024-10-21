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

opt -Mordio bump '' "Bump the metadata of output files without actually re-run the script"

# Check if any output data is outdated in regards to inputs, scripts, and config
# If no need to run, return 0, else return 1
MORDIO::FLOW::check() {
  # No output, don't do check here, always run
  if [[ ${#mordioOutputArgs[@]} == 0 ]]; then
    return 1
  fi

  local __arg
  # If any of the output isn't valid, then no need for further check, just run
  for __arg in "${mordioOutputArgs[@]}"; do
    if [[ -z ${(P)__arg} ]]; then continue; fi
    ${__arg}::ALL::checkValid debug
  done

  # Now that all output exists, just bump the meta file
  # So that we don't need to re-run
  if [[ $bump == true ]]; then
    MORDIO::FLOW::writeAllMeta # Pretending we DID generated these output
    return 0
  fi

  # If the script is very expensive, and at this point output exists
  # Don't run
  if [[ ${veryexpensive-} == true ]]; then
    return 0
  fi

  # If any of the output is from outdated script or mismatched config, run
  makeScriptConfig
  makeScriptSum
  local __i
  local __cached
  for __arg in "${mordioOutputArgs[@]}"; do
    # P has low priority, so it need to be wrapped in the inner subsitution
    # A: treat the output as an array, whether it's a scalar or array
    for (( __i=1; __i<=${#${(A)${(P)__arg}[@]}}; __i++ )); do
      getMeta $__arg $__i "_config" __cached
      if [[ $__cached != $mordioCachedConfig ]]; then
        warn "\$$__arg was from outdated config, will rerun"
        return 1
      fi
      getMeta $__arg $__i "_scriptsum" __cached
      if [[ $__cached != $mordioCachedScriptSum ]]; then
        warn "\$$__arg was from outdated script, will rerun"
        return 1
      fi
    done
  done

  # If any of the output is from outdated input, rerun
  makeScriptInputSum
  for __arg in "${mordioOutputArgs[@]}"; do
    for (( __i=1; __i<=${#${(A)${(P)__arg}[@]}}; __i++ )); do
      getMeta $__arg $__i "_insum" __cached
      if [[ $__cached != $mordioCachedInputSum ]]; then
        warn "\$$__arg was from outdated input, will rerun"
        return 1
      fi
    done
  done

  return 0
}

# Hijack check if user didn't define it
if ! declare -f check >/dev/null; then
  check() {
    MORDIO::FLOW::check "$@"
  }
fi
