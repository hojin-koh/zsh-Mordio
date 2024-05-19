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

# Type-related functions

declare -gA mordioTypeInit
declare -gA mordioMapOptDirection
declare -gA mordioMapOptType

# Register all types
source "$MORDIO_ROOT_DIR/types"/*.zsh

optType() {
  local __nameVar="$1"
  local __inout="$2"
  local __type="$3"

  if [[ "$__inout" != "input" && "$__inout" != "output" ]]; then
    err "Invalid type for option $__nameVar: $__type" 35
  fi
  if [[ -z "${mordioTypeInit[$__type]-}" ]]; then
    err "Type $__type for option $__nameVar doesn't exist" 35
  fi
  mordioMapOptDirection[$__nameVar]="$__inout"
  mordioMapOptType[$__nameVar]="$__type"

  "${mordioTypeInit[$__type]}" "$__nameVar" "$__inout"
}

populateType() {
  local __nameVar="$1"
  local __namespace="$2"

  local func
  for func in ${(ok)functions[(I)${__namespace}::*]}; do
    local stem="${func##*::}"
    if [[ "$stem" == INIT ]]; then continue; fi
    eval "${__nameVar}::${stem}() { ${__namespace}::${stem} \"\$$__nameVar\" }"
  done
}

MORDIO::FLOW::checkArgs() {
  local arg
  for arg in "${(k)mordioMapOptType[@]}"; do
    ${arg}::checkName
    if [[ "${mordioMapOptDirection[$arg]}" == "input" ]]; then
      ${arg}::checkValid
    fi
  done
}
addHook postparse MORDIO::FLOW::checkArgs

MORDIO::FLOW::writeMeta() {
  local arg
  for arg in "${(k)mordioMapOptType[@]}"; do
    if [[ "${mordioMapOptDirection[$arg]}" == "input" ]]; then continue; fi
    (
      ${arg}::computeMeta
      printf '\n---\n\n'
      date +'%Y-%m-%d %H:%M:%S'
      printf '\n'
      local grp
      local var
      for grp in "" "${skrittOptGroups[@]}" "Skritt"; do
        if [[ -n "$grp" ]]; then printf "\n# %s Options:\n" "$grp"; fi
        for var in ${(k)skrittMapOptGroup[(R)$grp]}; do
          printf "%s=%s\n" "$var" "${(P@)var-}"
        done
      done
    ) | ${arg}::saveMeta
  done
}
addHook postrun MORDIO::FLOW::writeMeta
