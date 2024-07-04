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

# Type definition: report
# Just a report file, potentially zstd-compressed
# We know nothing about the interior of the report

mordioTypeInit[report]=MORDIO::TYPE::report::INIT

MORDIO::TYPE::report::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::file
  populateType "$nameVar" MORDIO::TYPE::report
}

# === Mordio Things ===

MORDIO::TYPE::report::checkName() {
  true
}

# === Save/Load ===

MORDIO::TYPE::report::getLoader() {
  local fname=$1
  printf 'cat "%s"' "$fname"
}

MORDIO::TYPE::report::load() {
  local fname=$1
  cat "$fname"
}

MORDIO::TYPE::report::save() {
  local fname=$1
  cat > "$fname.tmp"
}
