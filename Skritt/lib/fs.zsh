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

# Filesystem-related functions

declare -ga skrittTempDirs

# Add temp dir
putTemp() {
  local __var="$1"
  typeset -g "$__var=$(mktemp -d)"
  info "Generated temp dir: ${(P)__var}"
  skrittTempDirs+=("${(P)__var}")
}

SKRITT::HOOK::cleanUpTemp() {
  local pathTmp
  for pathTmp in "${(@)skrittTempDirs}"; do
    if [[ "$pathTmp" != /tmp* ]]; then
      continue
    fi
    rm -rf "$pathTmp"
    info "Deleted temp dir: $pathTmp"
  done
}
addHook exit SKRITT::HOOK::cleanUpTemp begin
