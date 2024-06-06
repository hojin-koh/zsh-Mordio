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

mordioTypeInit[arpa]=MORDIO::TYPE::arpa::INIT

MORDIO::TYPE::arpa::INIT() {
  local __nameVar="$1"
  local __inout="$2"

  populateType "$__nameVar" MORDIO::TYPE::arpa
}

MORDIO::TYPE::arpa::checkName() {
  local __fname="$1"
  if [[ "$__fname" == *.arpa ]]; then
    true
  elif [[ "$__fname" == *.arpa.zst ]]; then
    true
  else
    err "Input argument $__fname has invalid extension" 36
  fi
}

MORDIO::TYPE::arpa::checkValid() {
  local __fname="$1"
  if [[ ! -r "$__fname" ]]; then
    err "Input argument $__fname does not exist" 36
  fi
  if [[ ! -r "$__fname.meta" ]]; then
    err "Input argument $__fname has no metadata" 36
  fi
}

MORDIO::TYPE::arpa::load() {
  local __fname="$1"
  if [[ "$__fname" == *.arpa.zst ]]; then
    zstd -dc "$__fname"
  elif [[ "$__fname" == *.arpa ]]; then
    gzip -c "$__fname"
  fi
}

MORDIO::TYPE::arpa::save() {
  local __fname="$1"
  local __input="$2"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  if [[ "$__fname" == *.arpa.zst ]]; then
    gunzip -c "$__input" > "$__fname.tmp"
    zstd --rm -17 -T$nj "$__fname.tmp"
  elif [[ "$__fname" == *.arpa ]]; then
    gunzip -c "$__input" > "$__fname.tmp"
  fi
}

MORDIO::TYPE::arpa::finalize() {
  local __fname="$1"
  if [[ -f "$__fname.tmp" ]]; then
    mv -vf "$__fname.tmp" "$__fname"
  elif [[ -f "$__fname.tmp.zst" ]]; then
    mv -vf "$__fname.tmp.zst" "$__fname"
  fi
}

MORDIO::TYPE::arpa::cleanup() {
  local __fname="$1"
  rm -vf "$__fname.tmp"
  rm -vf "$__fname.tmp.zst"
}

# Metadata

MORDIO::TYPE::arpa::computeMeta() {
  local __fname="$1"
  true
}

MORDIO::TYPE::arpa::saveMeta() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  cat > "$__fname.meta"
}
