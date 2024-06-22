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

# Option-related functions

declare -ga skrittOpts
declare -ga skrittOptGroups
declare -ga skrittRequiredArgs
declare -gA skrittMapOptGroup
declare -gA skrittMapOptDesc

# The utility to declare an option
# Usage: opt [-r] [-<Group Name>] <opt-name> <default-value> <description>
opt() {
  local __isRequired=false
  if [[ ${1-} == -r ]]; then
    __isRequired=true
    shift
  fi
  # A group is specified
  local __grpThis=""
  if [[ ${1-} == -* ]]; then
    __grpThis=${1:1}
    shift
  fi
  local __nameOpt=$1
  local __nameVar=${__nameOpt//-/_}
  local __nameVar=${__nameVar//./___}
  local __valueDefault=$2
  local __descOpt=$3
  skrittOpts+=( $__nameVar )

  # Write the description of this option
  if [[ $__isRequired == true ]]; then
    skrittMapOptDesc[$__nameVar]="[Req]$__nameOpt=$__valueDefault"$'\t'"$__descOpt"
    skrittRequiredArgs+=( $__nameVar )
  else
    skrittMapOptDesc[$__nameVar]="[--]$__nameOpt=$__valueDefault"$'\t'"$__descOpt"
  fi

  # Take note of group, and add to group list if not yet done
  skrittMapOptGroup[$__nameVar]=$__grpThis
  # [(i)...]: search for the 1-based index of this element. As per zsh doc: "On failure substitutes the length of the array plus one"
  if [[ ${skrittOptGroups[(i)$__grpThis]} -gt ${#skrittOptGroups} ]]; then
    if [[ -n $__grpThis && $__grpThis != Skritt ]]; then
      skrittOptGroups+=( $__grpThis )
    fi
  fi

  # Make the variable and assign it the default value
  if [[ $__valueDefault == \(* ]]; then
    declare -ga $__nameVar
    eval "$__nameVar=$__valueDefault"
  else
    declare -g $__nameVar
    eval "$__nameVar='$__valueDefault'"
  fi
}

printHelpMessage() {
  local grp
  local var
  printf "%s\n\n" "${description-}"
  (
    for grp in "" "${skrittOptGroups[@]}" "Skritt"; do
      if [[ -n $grp ]]; then printf "\n%s Options:\n\n" "$grp"; fi
      # This is less efficient than something like ${(k)skrittMapOptGroup[(R)$grp]},
      # but doing it this way can ensure the display order is the same as decleration order
      for var in "${skrittOpts[@]}"; do
        if [[ ${skrittMapOptGroup[$var]-} == $grp ]]; then
          printf "  %s\n" "${skrittMapOptDesc[$var]}"
        fi
      done | if command -v column >/dev/null; then column -ts $'\t'; else cat; fi
    done
  ) >&2
}

checkRequiredArgs() {
  local __var
  for __var in "${(@)skrittRequiredArgs}"; do
    if [[ -z ${(P)__var-} ]]; then
      if [[ ${1+ok} == ok ]]; then
        eval "$__var='$1'"
        debug "Filled required argument \$$__var with positional argument '$1'"
        shift
      else
        err "Required argument \$$__var not specified" 1
      fi
    fi
  done
}
addHook postparse checkRequiredArgs

SKRITT::HOOK::logOptions() {
  local __var
  for __var in "${(@)skrittOpts}"; do
    if [[ ${(Pt)__var-} == array ]]; then
      debug "option:$__var=(${(P*)__var-})"
    else
      debug "option:$__var=${(P)__var-}"
    fi
  done
}
addHook exit SKRITT::HOOK::logOptions
