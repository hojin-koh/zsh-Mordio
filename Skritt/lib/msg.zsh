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

# Message-related functions
typeset -F SECONDS
opt -Skritt debug false "Whether to show debug messages on screen"
opt -Skritt notitle false "Whether to disable showing start/end messages"

SKRITT::INTERNAL::outputMessage() {
  local typeMsg=$1
  local codeColor=$2
  local msg=$3
  local charEnd=${4-\\n}
  local elapsed=$SECONDS
  printf "\033[%sm[%08.1f] " "$codeColor" "$elapsed" >&5
  printf "[%08.1f] " "$elapsed" >&6

  printf "$typeMsg%.0s" {1..$SKRITT_SHLVL} >&5
  printf "$typeMsg%.0s" {1..$SKRITT_SHLVL} >&6

  printf " %s\033[m\033[K$charEnd" "$msg" >&5
  printf " %s$charEnd" "$msg" >&6
}

debug() {
  if [[ ${debug-} == true ]]; then
    printf "\033[0;34m[%08.1f] " "$SECONDS" >&5
    printf "D%.0s" {1..$SKRITT_SHLVL} >&5
    printf " %s\033[m\033[K\n" "$1" >&5
  fi
  printf "[%08.1f] " "$SECONDS" >&6
  printf "D%.0s" {1..$SKRITT_SHLVL} >&6
  printf " %s\n" "$1" >&6
}

titleinfoBegin() {
  if [[ ${notitle-} != true ]]; then
    SKRITT::INTERNAL::outputMessage '>' '1;35' "$1"
  fi
}
titleinfoEnd() {
  if [[ ${notitle-} != true ]]; then
    SKRITT::INTERNAL::outputMessage '<' '1;32' "$1"
  fi
}

info() {
  SKRITT::INTERNAL::outputMessage I '1;37' "$1"
}

warn() {
  SKRITT::INTERNAL::outputMessage W '1;33' "$1"
}

err() {
  SKRITT::INTERNAL::outputMessage E '1;31' "$1"
  if [[ ${2-} -gt 0 ]]; then
    exit $2
  fi
}

prompt() {
  SKRITT::INTERNAL::outputMessage P '1;36' "$1: " ''
  read -r REPLY || true
  printf "[%06.1f] REPLY=%s\n" "$SECONDS" "$REPLY" >&6
}

promptyn() {
  SKRITT::INTERNAL::outputMessage P '1;33' "$1 (y/n): " ''
  read -q REPLY || true
  echo >&5
  printf "[%06.1f] REPLY=%s\n" "$SECONDS" "$REPLY" >&6
}

showReadableTime() {
  local secTotal=$1
  local hours=$[secTotal/3600]
  local minutes=$[(secTotal%3600)/60]
  local seconds=$[secTotal%60]
  if [[ $hours -lt 1 ]]; then
    printf "%dm%ds" $minutes $seconds
  else
    printf "%dh%dm%ds" $hours $minutes $seconds
  fi
}

lineProgressBar() {
  local nLineTotal=$1
  shift
  if command -v pv >/dev/null; then
    pv -l -W --average-rate-window 3600 -F "%t %b/$nLineTotal %p %e" -i 2 -s $nLineTotal "$@" 2>&5
  else
    cat
  fi
}
