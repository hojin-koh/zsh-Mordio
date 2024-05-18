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

# Basic flow of a single script

# The utility to hook a function
# Usage: addHook <hook-name> <function-name> [begin]
addHook() {
  local nameHook="$1"
  local nameArray="SKRITT_HOOK_$nameHook"
  local nameFunc="$2"
  shift; shift
  if [[ -z "${1-}" ]]; then # Default behavior: append at the end
    eval "$nameArray+=( '$nameFunc' )"
  elif [[ "${1-}" == "begin" ]]; then
    eval "$nameArray=( '$nameFunc' \"\${(@)$nameArray}\" )"
  fi
}

invokeHook() {
  local nameHook="$1"
  shift
  local nameArray="SKRITT_HOOK_$nameHook"
  if [[ "${(P@)#nameArray}" == 0 ]]; then
    return
  fi
  debug "Invoke Hook: $nameHook"
  for f in "${(P@)nameArray}"; do
    debug "Start hook function $f"
    "$f" "$@"
  done
  debug "End Hook: $nameHook"
}

declare -ga SKRITT_HOOK_preparse
SKRITT::FLOW::preparse() {
  invokeHook preparse "$@"
}

declare -ga SKRITT_HOOK_postparse
SKRITT::FLOW::postparse() {
  invokeHook postparse "$@"
}

declare -g SKRITT_BEGIN_DATE="$(date +'%Y-%m-%d %H:%M:%S')"
declare -ga SKRITT_HOOK_prescript
SKRITT::FLOW::prescript() {
  if [[ -n "${logfile-}" ]]; then
    setupLog "$logfile" "$logrotate"
  fi

  if [[ -n "${skrittCommandLineOriginal-}" ]]; then
    titleinfo "> Begin $$ $skrittCommandLineOriginal"
  else
    titleinfo "> Begin $$ $ZSH_ARGZERO $@"
  fi
  info "$SKRITT_BEGIN_DATE (SHLVL=$SHLVL)"

  invokeHook prescript "$@"
}

declare -ga SKRITT_HOOK_exit=()
TRAPEXIT() {
  local __rtn=$?
  invokeHook exit "$__rtn"
  if [[ "$__rtn" == 0 ]]; then
    titleinfo "< ($(showReadableTime $SECONDS)) End $$ $ZSH_ARGZERO"
  else
    err "< End with error ($__rtn) $ZSH_ARGZERO"
  fi
}

TRAPINT() {
  warn "Killed"
  exit 130
}
