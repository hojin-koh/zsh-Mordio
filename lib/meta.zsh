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

# Metadata manipulation

declare -gA mordioMeta

makeScriptSum() {
  declare -g mordioCachedScriptSum
  if [[ -z $mordioCachedScriptSum ]]; then
    mordioCachedScriptSum="$(cat "$ZSH_ARGZERO" "${metaDepScripts[@]-/dev/null}" | b3sum -l 16 --no-names)"
  fi
}

makeScriptConfig() {
  declare -g mordioCachedConfig
  local __var
  if [[ -z $mordioCachedConfig ]]; then
    for __var in ${metaDepOpts[@]-}; do
      if [[ ${(Pt)__var} == array ]]; then
        mordioCachedConfig+="$__var=(${(P*)__var-});;"
      else
        mordioCachedConfig+="$__var=${(P)__var-};;"
      fi
    done
  fi
}

makeScriptInputSum() {
  declare -g mordioCachedInputSum
  local __var
  local __i
  local __cached
  if [[ -z $mordioCachedInputSum ]]; then
    for __var in "${mordioInputArgs[@]}"; do
      # P has low priority, so it need to be wrapped in the inner subsitution
      # A: treat the output as an array, whether it's a scalar or array
      for (( __i=1; __i<=${#${(A)${(P)__var}[@]}}; __i++ )); do
        getMeta $__var $__i "_outsum" __cached
        mordioCachedInputSum+="$__cached;;"
      done
    done
  fi
}

composeMeta() {
  local __arg=$1
  local __i=$2
  if [[ ${(Pt)__arg} == scalar ]]; then
    __i="" # making it expanding to empty list for non-array
  fi

  printf 'typeset -A mordioMeta=(\n'

  # Calculate checksum for the outputfile and generate type-specific metadata
  # The coprocess is for dumping once, calculating twice
  coproc b3sum -l 16 --no-names
  ${__arg}::load $__i >&p | ${__arg}::computeMeta $__i
  local __fd
  exec {__fd}<&p
  coproc :
  printf "[_outsum]="
  cat <&$__fd
  exec {__fd}<&-

  # Put all important config options into string
  printf "[_config]=%s\n" "${(q+)mordioCachedConfig}"

  # Write checksum for this script
  printf "[_scriptsum]=%s\n" "$mordioCachedScriptSum"

  # Write checksum from inputs
  printf "[_insum]=%s\n" "${(q+)mordioCachedInputSum}"

  printf ')\n'
}

getMeta() {
  local __arg=$1
  local __i=$2
  local __field=$3
  local __target=$4
  if [[ ${(Pt)__arg} == scalar ]]; then
    __i="" # making it expanding to empty list for non-array
  fi
  local __hashname=mordioMeta_${__arg}_${__i}
  if ! declare -p $__hashname >/dev/null 2>&1; then
    ${__arg}::putMeta $__i $__hashname
  fi
  eval "$__target=\${${__hashname}[$__field]}"
}

MORDIO::FLOW::writeAllMeta() {
  local __arg
  local __i

  if [[ ${#mordioOutputArgs[@]} -gt 0 ]]; then
    # Doing the cache-getting here instead of inside subprocess so that the cache work
    makeScriptConfig
    makeScriptSum
    makeScriptInputSum
  fi

  for __arg in "${mordioOutputArgs[@]}"; do
    if [[ -z ${(P)__arg} ]]; then continue; fi

    # P has low priority, so it need to be wrapped in the inner subsitution
    # A: treat the output as an array, whether it's a scalar or array
    for (( __i=1; __i<=${#${(A)${(P)__arg}[@]}}; __i++ )); do
      (
        composeMeta "$__arg" $__i

        printf '\n#%s\n' "$SKRITT_BEGIN_DATE"
        printf '#%s @ %s\n\n' "${ZSH_ARGZERO:t}" "${HOST-${HOSTNAME-}}"
        local __grp
        local __var
        for __grp in "" "${skrittOptGroups[@]}" "Skritt"; do
          if [[ -n $__grp ]]; then printf "\n## %s Options:\n" "$__grp"; fi
          for __var in "${skrittOpts[@]}"; do
            if [[ ${skrittMapOptGroup[$__var]-} != $__grp ]]; then continue; fi
            if [[ ${(Pt)__var} == array ]]; then
              printf "#%s=(%s)\n" "$__var" "${(P*q+)__var-}"
            else
              printf "#%s=%s\n" "$__var" "${(Pq+)__var-}"
            fi
          done
        done
      ) | ${__arg}::saveMeta $__i
    done

  done
}
addHook postrun MORDIO::FLOW::writeAllMeta
