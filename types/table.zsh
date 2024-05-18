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

# Type definition: table
# Table is a series of id/content pair

mordioTypeInit[table]=MORDIO::TYPE::table::populate

MORDIO::TYPE::table::populate() {
  local __varName="$1"
  local __inout="$2"

  eval "${__varName}::save() { MORDIO::TYPE::table::save \"\$$__varName\" }"
}

MORDIO::TYPE::table::save() {
  local __fname="$1"
  mkdir -p "$__fname"
  cat | zstd --rsyncable -17 > "$__fname/data.zst"
}
