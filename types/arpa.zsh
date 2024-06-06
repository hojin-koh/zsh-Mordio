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
  local nameVar="$1"
  local inout="$2"

  populateType "$nameVar" MORDIO::TYPE::arpa
}

MORDIO::TYPE::arpa::checkName() {
  local fname="$1"
  if [[ "$fname" == *.arpa ]]; then
    true
  elif [[ "$fname" == *.arpa.zst ]]; then
    true
  else
    err "Input argument $fname has invalid extension" 36
  fi
}

MORDIO::TYPE::arpa::checkValid() {
  local fname="$1"
  if [[ ! -r "$fname" ]]; then
    err "Input argument $fname does not exist" 36
  fi
  if [[ ! -r "$fname.meta" ]]; then
    err "Input argument $fname has no metadata" 36
  fi
}

MORDIO::TYPE::arpa::load() {
  local fname="$1"
  if [[ "$fname" == *.arpa.zst ]]; then
    zstd -dc "$fname"
  elif [[ "$fname" == *.arpa ]]; then
    gzip -c "$fname"
  fi
}

MORDIO::TYPE::arpa::save() {
  local fname="$1"
  local input="$2"
  if [[ "$fname" == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  if [[ "$fname" == *.arpa.zst ]]; then
    gunzip -c "$input" > "$fname.tmp"
    zstd --rm -17 -T$nj "$fname.tmp"
  elif [[ "$fname" == *.arpa ]]; then
    gunzip -c "$input" > "$fname.tmp"
  fi
}

MORDIO::TYPE::arpa::finalize() {
  local fname="$1"
  if [[ -f "$fname.tmp" ]]; then
    mv -vf "$fname.tmp" "$fname"
  elif [[ -f "$fname.tmp.zst" ]]; then
    mv -vf "$fname.tmp.zst" "$fname"
  fi
}

MORDIO::TYPE::arpa::cleanup() {
  local fname="$1"
  rm -vf "$fname.tmp"
  rm -vf "$fname.tmp.zst"
}

# Metadata

MORDIO::TYPE::arpa::computeMeta() {
  local fname="$1"
  true
}

MORDIO::TYPE::arpa::saveMeta() {
  local fname="$1"
  if [[ "$fname" == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  cat > "$fname.meta"
}
