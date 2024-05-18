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
  local __required=false
  if [[ "${1-}" == "-r" ]]; then
    __required=true
    shift
  fi
  # A group is specified
  local __group=""
  if [[ "${1-}" == -* ]]; then
    __group="${1:1}"
    shift
  fi
  local __name="$1"
  local __nameVar="${__name//-/_}"
  local __nameVar="${__nameVar//./___}"
  local __value="$2"
  local __desc="$3"
  skrittOpts+=( "$__nameVar" )

  # Write the description of this option
  if [[ "$__required" == true ]]; then
    skrittMapOptDesc[$__nameVar]="$__name=(Required)"$'\t'"$__desc"
    skrittRequiredArgs+=( "$__nameVar" )
  else
    skrittMapOptDesc[$__nameVar]="[--]$__name=$__value"$'\t'"$__desc"
  fi

  # Take note of group, and add to group list if not yet done
  skrittMapOptGroup[$__nameVar]="$__group"
  if [[ ${skrittOptGroups[(i)$__group]} -gt ${#skrittOptGroups} ]]; then
    if [[ -n "$__group" && "$__group" != "Skritt" ]]; then
      skrittOptGroups+=( "$__group" )
    fi
  fi

  # Make the variable and assign it the default value
  if [[ "$__value" == "("* ]]; then
    declare -ga "$__nameVar"
    eval "$__nameVar=$__value"
  else
    declare -g "$__nameVar"
    eval "$__nameVar='$__value'"
  fi
}

printHelpMessage() {
  (
    printf "%s\n\n" "${description-}"
    for grp in "" "${skrittOptGroups[@]}" "Skritt"; do
      if [[ -n "$grp" ]]; then printf "\n%s Options:\n\n" "$grp"; fi
      for var in ${(k)skrittMapOptGroup[(R)$grp]}; do
        printf "  %s\n" "${skrittMapOptDesc[$var]}"
      done
    done
  ) | if command -v column >/dev/null; then column -tLs $'\t'; else cat; fi >&2
}

checkRequiredArgs() {
  for __var in "${(@)skrittRequiredArgs}"; do
    if [[ -z "${(P)__var-}" ]]; then
      if [[ "${1+ok}" == "ok" ]]; then
        eval "$__var='$1'"
        info "Filled required argument \$$__var with positional argument '$1'"
        shift
      else
        err "Required argument \$$__var not specified" 1
      fi
    fi
  done
}
addHook postparse checkRequiredArgs

SKRITT::HOOK::logOptions() {
  for __var in "${(@)skrittOpts}"; do
    if [[ "${(Pt)__var-}" == "array" ]]; then
      debug "option:$__var=(${(P@)__var-})"
    else
      debug "option:$__var=${(P)__var-}"
    fi
  done
}
addHook exit SKRITT::HOOK::logOptions
