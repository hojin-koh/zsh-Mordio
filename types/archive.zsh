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

# Type definition: base
# This is the base of file types, with no regard of what is inside

mordioTypeInit[archive]=MORDIO::TYPE::archive::INIT

MORDIO::TYPE::archive::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::file
  populateType "$nameVar" MORDIO::TYPE::archive
}

# === Mordio Things ===

MORDIO::TYPE::archive::checkName() {
  local fname=$1
  if [[ $fname == *.tar.zst ]]; then
    return 0
  else
    return 36
  fi
}

MORDIO::TYPE::archive::computeMeta() {
  local fname=$1
  local nRecord=$(tar tf - | grep -vE '/$' | wc -l)
  printf "[nRecord]=%d\n" "$nRecord"
}

# === Save/Load ===

MORDIO::TYPE::archive::getLoader() {
  local fname=$1
  if ! MORDIO::TYPE::file::getLoader "$@"; then
    if [[ $fname == *.tar.zst ]]; then
      printf 'zstd -dc "%s"' "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::archive::load() {
  local fname=$1
  if ! MORDIO::TYPE::file::load "$@"; then
    if [[ $fname == *.tar.zst ]]; then
      zstd -dc "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::archive::getLoaderKey() {
  MORDIO::TYPE::archive::getLoader "$@"
  printf ' | %s | %s' "tar tf -" "grep -vE '/$'"
}

MORDIO::TYPE::archive::loadKey() {
  MORDIO::TYPE::archive::load "$@" \
  | tar tf - \
  | grep -vE '/$'
}

MORDIO::TYPE::archive::save() {
  local fname=$1
  if ! MORDIO::TYPE::file::save "$@"; then
    if [[ $fname == *.tar.zst ]]; then
      zstd --rsyncable -13 -T$nj > $fname.tmp
      return 0
    else
      return 1
    fi
  fi
}
