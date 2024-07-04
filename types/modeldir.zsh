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

# Type definition: modeldir
# Just a model directory
# We know nothing about the interior of the directory

mordioTypeInit[modeldir]=MORDIO::TYPE::modeldir::INIT

MORDIO::TYPE::modeldir::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::dir
  populateType "$nameVar" MORDIO::TYPE::modeldir
}

# === Mordio Things ===

MORDIO::TYPE::modeldir::checkName() {
  local fname=$1
  if [[ $fname == *.model ]]; then
    return 0
  else
    err "Input argument $fname has invalid extension"
    return 36
  fi
  return 0
}

# === Save/Load ===

