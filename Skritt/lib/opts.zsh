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

skrittHelpMessage="${desc-}"$'\n'$'\n'
skrittOpts=()
skrittRequiredArgs=()

# The utility to declare an option
# Usage: opt [-r] <opt-name> <default-value> <description>
opt() {
  local __required=false
  if [[ "${1-}" == "-r" ]]; then
    __required=true
    shift
  fi
  local __name="$1"
  local __nameVar="${__name//-/_}"
  local __nameVar="${__nameVar//./___}"
  local __value="$2"
  local __desc="$3"
  skrittOpts+=( "$__nameVar" )
  if [[ "$__required" == true ]]; then
    skrittHelpMessage+="  $__name=$__value"$'\t'"$__desc"$'\n'
    skrittRequiredArgs+=( "$__nameVar" )
  else
    skrittHelpMessage+="  [--]$__name=$__value"$'\t'"$__desc"$'\n'
  fi
  if [[ "$__value" == "("* ]]; then
    declare -ga "$__nameVar"
    eval "$__nameVar=$__value"
  else
    declare -g "$__nameVar"
    eval "$__nameVar='$__value'"
  fi
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
