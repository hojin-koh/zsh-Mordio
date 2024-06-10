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
  local nameVar="$1"
  local inout="$2"

  populateType "$nameVar" MORDIO::TYPE::table
}

# === Mordio Things ===

MORDIO::TYPE::table::checkName() {
  local fname="$1"
  if ! MORDIO::TYPE::file::checkName "$@"; then
    if [[ "$fname" == *.zst ]]; then
      return 0
    else
      err "Input argument $fname has invalid extension"
      return 36
    fi
  fi
  return 0
}

MORDIO::TYPE::table::checkValid() {
  MORDIO::TYPE::file::checkValid "$@"
}

MORDIO::TYPE::table::finalize() {
  MORDIO::TYPE::file::finalize "$@"
}

MORDIO::TYPE::table::cleanup() {
  MORDIO::TYPE::file::cleanup "$@"
}

MORDIO::TYPE::table::computeMeta() {
  local fname="$1"
  MORDIO::TYPE::table::load "$fname" \
    | LC_ALL=en_US.UTF-8 gawk -F$'\t' '
        END {
          print "nRecord=" NR;
        }'
  MORDIO::TYPE::file::computeMeta "$@"
}

MORDIO::TYPE::table::saveMeta() {
  MORDIO::TYPE::file::saveMeta "$@"
}

MORDIO::TYPE::table::dumpMeta() {
  MORDIO::TYPE::file::dumpMeta "$@"
}

MORDIO::TYPE::table::checkScriptSum() {
  MORDIO::TYPE::file::checkScriptSum "$@"
}

MORDIO::TYPE::table::getMainFile() {
  MORDIO::TYPE::file::getMainFile "$@"
}

# === Save/Load ===

MORDIO::TYPE::table::isReal() {
  MORDIO::TYPE::file::isReal "$@"
}

MORDIO::TYPE::table::getLoader() {
  local fname="$1"
  if ! MORDIO::TYPE::file::getLoader "$@"; then
    if [[ "$fname" == *.zst ]]; then
      printf 'zstd -dc "%s"' "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::table::load() {
  local fname="$1"
  if ! MORDIO::TYPE::file::load "$@"; then
    if [[ "$fname" == *.zst ]]; then
      zstd -dc "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::table::save() {
  local fname="$1"
  if ! MORDIO::TYPE::file::save "$@"; then
    if [[ "$fname" == *.zst ]]; then
      zstd --rsyncable -13 -T$nj > "$fname.tmp"
      return 0
    else
      return 1
    fi
  fi
}

# === Metadata Processing ===

MORDIO::TYPE::table::getNR() {
  local fname="$1"
  MORDIO::TYPE::table::dumpMeta "$1" \
  | gawk -F= '/^nRecord=/ {print $2} /^---$/ {exit}'
}
