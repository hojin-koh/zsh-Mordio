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

# Type definition: text
# Text is a series of id/text pair, separated by a tab

mordioTypeInit[text]=MORDIO::TYPE::text::INIT

MORDIO::TYPE::text::INIT() {
  local __nameVar="$1"
  local __inout="$2"

  populateType "$__nameVar" MORDIO::TYPE::text
}

MORDIO::TYPE::text::checkName() {
  local __fname="$1"
  if [[ "$__fname" == *.txt.zst ]]; then
    true
  else
    err "Input argument $__fname has invalid extension" 36
  fi
}

MORDIO::TYPE::text::checkValid() {
  MORDIO::TYPE::table::checkValid "$@"
}

MORDIO::TYPE::text::load() {
  local __fname="$1"
  if [[ "$__fname" == *.txt.zst ]]; then
    zstd -dc "$__fname"
  fi
}

MORDIO::TYPE::text::save() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  if [[ "$__fname" == *.txt.zst ]]; then
    zstd --rsyncable -11 -T$nj > "$__fname.tmp"
  fi
}

MORDIO::TYPE::text::finalize() {
  MORDIO::TYPE::table::finalize "$@"
}

MORDIO::TYPE::text::cleanup() {
  MORDIO::TYPE::table::cleanup "$@"
}

# Metadata

MORDIO::TYPE::text::computeMeta() {
  local __fname="$1"
  MORDIO::TYPE::text::load "$__fname" \
    | LC_ALL=en_US.UTF-8 gawk -F$'\t' '
        END {
          print "nRecord=" NR;
        }'
}

MORDIO::TYPE::text::saveMeta() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  cat > "$__fname.meta"
}

MORDIO::TYPE::text::getNR() {
  local __fname="$1"
  gawk -F= '/^nRecord=/ {print $2} /^---$/ {exit}' "$__fname.meta"
}
