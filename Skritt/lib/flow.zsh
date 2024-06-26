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
  local nameHook=$1
  local nameArray=SKRITT_HOOK_$nameHook
  local nameFunc=$2
  shift; shift
  if [[ -z ${1-} ]]; then # Default behavior: append at the end
    eval "$nameArray+=( '$nameFunc' )"
  elif [[ ${1-} == begin ]]; then
    eval "$nameArray=( '$nameFunc' \"\${(@)$nameArray}\" )"
  fi
}

invokeHook() {
  local nameHook=$1
  shift
  local nameArray=SKRITT_HOOK_$nameHook
  # P@: indirect + all elements, #: number of elements
  if [[ ${(P@)#nameArray} == 0 ]]; then
    debug "Empty Hook: $nameHook"
    return
  fi
  debug "Invoke Hook: $nameHook"
  local func
  for func in "${(P@)nameArray}"; do
    debug "Start hook function $func"
    $func "$@"
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

declare -g SKRITT_BEGIN_DATE="$(date +'%Y%m%d-%H%M%S')"
declare -ga SKRITT_HOOK_prerun
SKRITT::FLOW::prerun() {
  if [[ -n ${logfile-} ]]; then
    setupLog "$logfile" "$logrotate"
  fi

  local cmdlineTitle=${skrittCommandLineOriginal-$ZSH_ARGZERO $*}
  if [[ $#cmdlineTitle -gt 200 ]]; then cmdlineTitle=${cmdlineTitle:0:200}...; fi
  titleinfoBegin "($SKRITT_BEGIN_DATE) Begin $$ $cmdlineTitle"
  debug "@ ${HOST-${HOSTNAME-}}"
  invokeHook prerun "$@"
}

declare -ga SKRITT_HOOK_postrun
SKRITT::FLOW::postrun() {
  invokeHook postrun "$@"
}

declare -ga SKRITT_HOOK_exit=()
TRAPEXIT() {
  local rtn=$?
  invokeHook exit "$rtn"
  if [[ "$rtn" == 0 ]]; then
    titleinfoEnd "($(showReadableTime $SECONDS)) End $$ $ZSH_ARGZERO"
  else
    err "($(showReadableTime $SECONDS)) End with error ($rtn) $ZSH_ARGZERO"
  fi
  echo >&5 # a new line after ending
}

TRAPINT() {
  warn "Killed"
  exit 130
}
