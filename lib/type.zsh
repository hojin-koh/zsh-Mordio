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
for f in "$MORDIO_ROOT_DIR/types"/*.zsh; do
  source "$f"
done

optType() {
  local __nameVar="$1"
  local __inout="$2"
  local __type="$3"

  if [[ "$__inout" != "input" && "$__inout" != "output" ]]; then
    err "Invalid in/out for option $__nameVar: $__type" 35
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

  local __func
  for __func in ${(ok)functions[(I)${__namespace}::*]}; do
    local __stem="${__func##*::}"
    if [[ "$__stem" == INIT ]]; then continue; fi
    if [[ "${(Pt)__nameVar}" == "array" ]]; then
      eval "${__nameVar}::${__stem}() { local __i=\"\$1\"; ${__namespace}::${__stem} \"\${${__nameVar}[\$__i]}\" \"\$@\" }"
      eval "${__nameVar}::ALL::${__stem}() { local __i; for (( __i=1; __i<=\${#${__nameVar}[@]}; __i++ )); do ${__nameVar}::${__stem} \"\$__i\" \"\$@\"; done }"
    elif [[ "${(Pt)__nameVar}" == "scalar" ]]; then 
      eval "${__nameVar}::${__stem}() { ${__namespace}::${__stem} \"\$$__nameVar\" \"\$@\" }"
      eval "${__nameVar}::ALL::${__stem}() { ${__namespace}::${__stem} \"\$$__nameVar\" \"\$@\" }"
    fi
  done

  if [[ "${mordioMapOptDirection[$__nameVar]}" == "output" ]]; then
    if declare -f "${__nameVar}::cleanup" >/dev/null; then
      addHook exit "${__nameVar}::ALL::cleanup"
    fi
  fi
}

MORDIO::FLOW::checkArgs() {
  local arg
  local i
  for arg in "${(k)mordioMapOptType[@]}"; do
    ${arg}::ALL::checkName $i

    if [[ "${mordioMapOptDirection[$arg]}" == "input" ]]; then
      ${arg}::ALL::checkValid $i
    fi
  done
}
addHook postparse MORDIO::FLOW::checkArgs

MORDIO::FLOW::writeMeta() {
  local __arg
  local __i
  for __arg in "${(k)mordioMapOptType[@]}"; do
    if [[ "${mordioMapOptDirection[$__arg]}" == "input" ]]; then continue; fi

    ${__arg}::ALL::finalize $__i
    for (( __i=1; __i<=${#${(A)${(P)__arg}}[@]}; __i++ )); do
      (
        ${__arg}::computeMeta $__i
        printf '\n---\n\n'
        date +'%Y-%m-%d %H:%M:%S'
        printf '@ %s\n\n' "${HOST-${HOSTNAME-}}"
        local grp
        local var
        for grp in "" "${skrittOptGroups[@]}" "Skritt"; do
          if [[ -n "$grp" ]]; then printf "\n# %s Options:\n" "$grp"; fi
          for var in ${(k)skrittMapOptGroup[(R)$grp]}; do
            if [[ "${(Pt)var}" == "array" ]]; then
              printf "%s=(%s)\n" "$var" "${(P*)var-}"
            else
              printf "%s=%s\n" "$var" "${(P)var-}"
            fi
          done
        done
      ) | ${__arg}::saveMeta $__i
    done

  done
}
addHook postrun MORDIO::FLOW::writeMeta
