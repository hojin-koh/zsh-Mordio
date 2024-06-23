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

declare -ga mordioInputArgs
declare -ga mordioOutputArgs
declare -gA mordioTypeInit
declare -gA mordioMapOptDirection
declare -gA mordioMapOptType

# Register all types
for f in $MORDIO_ROOT_DIR/types/*.zsh; do
  source $f
done

optType() {
  local __nameVar=$1
  local __inout=$2
  local __type=$3

  if [[ $__inout != input && $__inout != output ]]; then
    err "Invalid in/out for option $__nameVar: $__type" 35
  fi
  if [[ -z ${mordioTypeInit[$__type]-} ]]; then
    err "Type $__type for option $__nameVar doesn't exist" 35
  fi
  mordioMapOptDirection[$__nameVar]=$__inout
  mordioMapOptType[$__nameVar]=$__type

  if [[ $__inout == input ]]; then
    mordioInputArgs+=($__nameVar)
  elif [[ $__inout == output ]]; then
    mordioOutputArgs+=($__nameVar)
  fi

  "${mordioTypeInit[$__type]}" "$__nameVar" "$__inout"
}

populateType() {
  local __nameVar=$1
  local __namespace=$2

  local __func
  # [(I)...] all functions matching the pattern. As per zsh doc: "all possible matching keys in an associative array"
  # k: Return keys instead of values in the associative array subscription (the key here is name of functions)
  for __func in ${(k)functions[(I)${__namespace}::*]}; do
    local __stem=${__func##*::}
    if [[ $__stem == INIT ]]; then continue; fi
    # t: print out the type name of the variable
    if [[ ${(Pt)__nameVar} == array ]]; then
      eval "${__nameVar}::${__stem}() { local __i=\"\$1\"; shift; ${__namespace}::${__stem} \"\${${__nameVar}[\$__i]}\" \"\$@\" }"
      eval "${__nameVar}::ALL::${__stem}() { local __i; for (( __i=1; __i<=\${#${__nameVar}[@]}; __i++ )); do ${__nameVar}::${__stem} \"\$__i\" \"\$@\"; done }"
    elif [[ ${(Pt)__nameVar} == scalar ]]; then 
      eval "${__nameVar}::${__stem}() { ${__namespace}::${__stem} \"\$$__nameVar\" \"\$@\" }"
      eval "${__nameVar}::ALL::${__stem}() { ${__namespace}::${__stem} \"\$$__nameVar\" \"\$@\" }"
    fi
  done

  if [[ ${mordioMapOptDirection[$__nameVar]} == output ]]; then
    if declare -f ${__nameVar}::cleanup >/dev/null; then
      addHook exit ${__nameVar}::ALL::cleanup
    fi
  fi
}

MORDIO::FLOW::checkArgNames() {
  local __arg
  for __arg in "${mordioInputArgs[@]}" "${mordioOutputArgs[@]}"; do
    if [[ -z ${(P)__arg} ]]; then continue; fi
    ${__arg}::ALL::checkName
  done
}
addHook postparse MORDIO::FLOW::checkArgNames

MORDIO::FLOW::checkInputArgs() {
  local __arg
  for __arg in "${mordioInputArgs[@]}"; do
    if [[ -z ${(P)__arg} ]]; then continue; fi
    ${__arg}::ALL::checkValid err
  done
}
addHook prerun MORDIO::FLOW::checkInputArgs

MORDIO::FLOW::finalizeOutput() {
  local __arg
  local __i
  for __arg in "${mordioOutputArgs[@]}"; do
    if [[ -z ${(P)__arg} ]]; then continue; fi
    ${__arg}::ALL::finalize $__i
  done
}
addHook postrun MORDIO::FLOW::finalizeOutput

MORDIO::FLOW::writeMeta() {
  local __arg
  local __i
  for __arg in "${mordioOutputArgs[@]}"; do
    if [[ -z ${(P)__arg} ]]; then continue; fi

    for (( __i=1; __i<=${#${(A)${(P)__arg}}[@]}; __i++ )); do
      (
        ${__arg}::computeMeta $__i
        printf '_scriptsum='
        getScriptSum || true

        printf '\n---\n\n'
        date +'%Y-%m-%d %H:%M:%S'
        printf '%s @ %s\n\n' "${ZSH_ARGZERO:t}" "${HOST-${HOSTNAME-}}"
        local __grp
        local __var
        for __grp in "" "${skrittOptGroups[@]}" "Skritt"; do
          if [[ -n $__grp ]]; then printf "\n# %s Options:\n" "$__grp"; fi
          for __var in "${(k)skrittMapOptGroup[(R)$__grp]}"; do
            if [[ ${(Pt)__var} == array ]]; then
              printf "%s=(%s)\n" "$__var" "${(P*)__var-}"
            else
              printf "%s=%s\n" "$__var" "${(P)__var-}"
            fi
          done
        done
      ) | ${__arg}::saveMeta $__i
    done

  done
}
addHook postrun MORDIO::FLOW::writeMeta
