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
# Table is a series of id/contents rows, separated by tabs
# ids are supposed to be unique

mordioTypeInit[table]=MORDIO::TYPE::table::INIT

MORDIO::TYPE::table::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::file
  populateType "$nameVar" MORDIO::TYPE::table
}

# === Mordio Things ===

MORDIO::TYPE::table::checkName() {
  local fname=$1
  if ! MORDIO::TYPE::file::checkName "$@"; then
    if [[ $fname == *.zst ]]; then
      return 0
    else
      err "Input argument $fname has invalid extension"
      return 36
    fi
  fi
  return 0
}

MORDIO::TYPE::table::computeMeta() {
  local fname=$1
  printf "[nRecord]="
  wc -l
}

# === Save/Load ===

MORDIO::TYPE::table::getLoader() {
  local fname=$1
  if ! MORDIO::TYPE::file::getLoader "$@"; then
    if [[ $fname == *.zst ]]; then
      printf 'zstd -dc "%s"' "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::table::load() {
  local fname=$1
  if ! MORDIO::TYPE::file::load "$@"; then
    if [[ $fname == *.zst ]]; then
      zstd -dc "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::table::getLoaderKey() {
  MORDIO::TYPE::table::getLoader "$@"
  printf ' | %s' "cut -d\$'\\t' -f1"
}

MORDIO::TYPE::table::loadKey() {
  MORDIO::TYPE::table::load "$@" \
  | cut -d$'\t' -f1
}

MORDIO::TYPE::table::getLoaderValue() {
  MORDIO::TYPE::table::getLoader "$@"
  printf ' | %s' "cut -d\$'\\t' -f2-"
}

MORDIO::TYPE::table::loadValue() {
  MORDIO::TYPE::table::load "$@" \
  | cut -d$'\t' -f2-
}

MORDIO::TYPE::table::save() {
  local fname=$1
  if ! MORDIO::TYPE::file::save "$@"; then
    if [[ $fname == *.zst ]]; then
      zstd --rsyncable -13 -T$nj > $fname.tmp
      return 0
    else
      return 1
    fi
  fi
}
