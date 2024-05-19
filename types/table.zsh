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

mordioTypeInit[table]=MORDIO::TYPE::table::INIT

MORDIO::TYPE::table::INIT() {
  local __nameVar="$1"
  local __inout="$2"

  populateType "$__nameVar" MORDIO::TYPE::table
}

MORDIO::TYPE::table::checkName() {
  local __fname="$1"
  if [[ "$__fname" == *.zst ]]; then
    true
  else
    err "Input argument $__fname has invalid extension" 36
  fi
}

MORDIO::TYPE::table::checkValid() {
  local __fname="$1"
  if [[ ! -e "$__fname" ]]; then
    err "Input argument $__fname does not exist" 36
  fi
  if [[ ! -e "$__fname.meta" ]]; then
    err "Input argument $__fname has no metadata" 36
  fi
  if [[ "$(stat --printf="%s" "$__fname")" -lt 33 ]]; then
    err "Input argument $__fname is too small and maybe corrupted" 36
  fi
}

MORDIO::TYPE::table::load() {
  local __fname="$1"
  if [[ "$__fname" == *.zst ]]; then
    zstd -dc "$__fname"
  fi
}

MORDIO::TYPE::table::save() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -p "${__fname##*/}"
  fi
  if [[ "$__fname" == *.zst ]]; then
    cat | zstd --rsyncable -17 > "$__fname"
  fi
  mkdir -p "$__fname"
}

# Metadata

MORDIO::TYPE::table::computeMeta() {
  local __fname="$1"
  printf 'nRecord='
  ${__fname}::load | wc -l
}

MORDIO::TYPE::table::getNR() {
  local __fname="$1"
  gawk -F= '/^nRecord=/ {print $2}' "$__fname.meta"
}
