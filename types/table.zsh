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
  if [[ ! -r "$__fname" ]]; then
    err "Input argument $__fname does not exist" 36
  fi
  if [[ ! -r "$__fname.meta" ]]; then
    err "Input argument $__fname has no metadata" 36
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
    mkdir -pv "${__fname%/*}"
  fi
  if [[ "$__fname" == *.zst ]]; then
    zstd --rsyncable -19 -T$nj > "$__fname.tmp"
  fi
}

MORDIO::TYPE::table::finalize() {
  local __fname="$1"
  mv -vf "$__fname.tmp" "$__fname"
}

MORDIO::TYPE::table::cleanup() {
  local __fname="$1"
  rm -vf "$__fname.tmp"
}

# Metadata

MORDIO::TYPE::table::computeMeta() {
  local __fname="$1"
  MORDIO::TYPE::table::load "$__fname" \
    | LC_ALL=en_US.UTF-8 gawk -F$'\t' '
        END {
          print "nRecord=" NR;
          print "nField=" NF;
        }'
}

MORDIO::TYPE::table::saveMeta() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  cat > "$__fname.meta"
}

MORDIO::TYPE::table::getNR() {
  local __fname="$1"
  gawk -F= '/^nRecord=/ {print $2} /^---$/ {exit}' "$__fname.meta"
}

MORDIO::TYPE::table::getNF() {
  local __fname="$1"
  gawk -F= '/^nField=/ {print $2} /^---$/ {exit}' "$__fname.meta"
}
