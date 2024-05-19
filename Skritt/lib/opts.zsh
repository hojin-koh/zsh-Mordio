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
  local isRequired=false
  if [[ "${1-}" == "-r" ]]; then
    isRequired=true
    shift
  fi
  # A group is specified
  local grp=""
  if [[ "${1-}" == -* ]]; then
    grp="${1:1}"
    shift
  fi
  local nameOpt="$1"
  local nameVar="${nameOpt//-/_}"
  local nameVar="${nameVar//./___}"
  local valueDefault="$2"
  local descOpt="$3"
  skrittOpts+=( "$nameVar" )

  # Write the description of this option
  if [[ "$isRequired" == true ]]; then
    skrittMapOptDesc[$nameVar]="$nameOpt=(Required)"$'\t'"$descOpt"
    skrittRequiredArgs+=( "$nameVar" )
  else
    skrittMapOptDesc[$nameVar]="[--]$nameOpt=$valueDefault"$'\t'"$descOpt"
  fi

  # Take note of group, and add to group list if not yet done
  skrittMapOptGroup[$nameVar]="$grp"
  if [[ ${skrittOptGroups[(i)$grp]} -gt ${#skrittOptGroups} ]]; then
    if [[ -n "$grp" && "$grp" != "Skritt" ]]; then
      skrittOptGroups+=( "$grp" )
    fi
  fi

  # Make the variable and assign it the default value
  if [[ "$valueDefault" == "("* ]]; then
    declare -ga "$nameVar"
    eval "$nameVar=$valueDefault"
  else
    declare -g "$nameVar"
    eval "$nameVar='$valueDefault'"
  fi
}

printHelpMessage() {
  local grp
  local var
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
  local var
  for var in "${(@)skrittRequiredArgs}"; do
    if [[ -z "${(P)var-}" ]]; then
      if [[ "${1+ok}" == "ok" ]]; then
        eval "$var='$1'"
        debug "Filled required argument \$$var with positional argument '$1'"
        shift
      else
        err "Required argument \$$var not specified" 1
      fi
    fi
  done
}
addHook postparse checkRequiredArgs

SKRITT::HOOK::logOptions() {
  local var
  for var in "${(@)skrittOpts}"; do
    if [[ "${(Pt)var-}" == "array" ]]; then
      debug "option:$var=(${(P@)var-})"
    else
      debug "option:$var=${(P)var-}"
    fi
  done
}
addHook exit SKRITT::HOOK::logOptions
