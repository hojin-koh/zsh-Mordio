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

# Logging-related functions

# Default options
opt -Skritt logfile '' "Log File"
opt -Skritt logrotate 3 "Number of old log files to keep"

setupLog() {
  local fname=$1
  local nRotate=$2
  if [[ -d $fname ]]; then
    err "Cannot log to $fname, it is a directory!" 2
  fi
  if [[ $fname == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  if [[ $nRotate -gt 0 ]]; then # Do log rotation first if needed
    rotateLog "$fname" "$nRotate"
    exec 6>"$fname"
  else # No rotate, then just append
    exec 6>>"$fname"
  fi
  exec 2> /dev/null
  exec 2> >(tee -a /dev/fd/6 >&2)
}

rotateLog() {
  local fname=$1
  local nRotate=$2
  if [[ ! -f $fname && ! -h $fname ]]; then # No need to rotate if no log at all
    return
  fi
  if [[ $nRotate -le 0 ]]; then # No need to rotate if not keeping old logs at all
    return
  fi
  local i
  for (( i=$[nRotate-1]; i>0; i-- )); do
    if [[ -f $fname.$i ]]; then
      mv -f "$fname.$i" "$fname.$[i+1]"
    fi
  done
  mv -v "$fname" "$fname.1"
}
