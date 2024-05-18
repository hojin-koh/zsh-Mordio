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

__::outputMessage() {
  local __typ="$1"
  local __color="$2"
  local __msg="$3"
  local __nl="${4-\n}"
  local __t="$SECONDS"
  printf "\033[%sm[%s-%08.1f] %s\033[m\033[K$__nl" "$__color" "$__typ" "$__t" "$__msg" >&5
  printf "[%s-%08.1f] %s$__nl" "$__typ" "$__t" "$__msg" >&6
}

debug() {
  if [[ "${debug-}" == true ]]; then
    printf "\033[0;34m[D-%06.1f] %s\033[m\033[K\n" "$SECONDS" "$1" >&2
  else
    printf "[D-%06.1f] %s\n" "$SECONDS" "$1" >&6
  fi
}

titleinfo() {
  __::outputMessage T '1;32' "$1"
}

info() {
  __::outputMessage I '1;37' "$1"
}

warn() {
  __::outputMessage W '1;33' "$1"
}

err() {
  __::outputMessage E '1;31' "$1"
  if [[ "${2-}" -gt 0 ]]; then
    exit $2
  fi
}

prompt() {
  __::outputMessage P '1;36' "$1: " ''
  read -r REPLY || true
  printf "[%06.1f] REPLY=%s\n" "$SECONDS" "$REPLY" >&6
}

promptyn() {
  __::outputMessage P '1;33' "$1 (y/n): " ''
  read -q REPLY || true
  echo >&5
  printf "[%06.1f] REPLY=%s\n" "$SECONDS" "$REPLY" >&6
}

showReadableTime() {
  local __secTotal="$1"
  local __hours=$[__secTotal/3600]
  local __minutes=$[(__secTotal%3600)/60]
  local __seconds=$[__secTotal%60]
  if [[ $__hours == 0 ]]; then
    printf "%dm%ds" $__minutes $__seconds
  else
    printf "%dh%dm%ds" $__hours $__minutes $__seconds
  fi
}

lineProgressBar() {
  local __max="$1"
  pv -l -F "%t %b/$__max %p %e" -i 2 -s $__max
}
