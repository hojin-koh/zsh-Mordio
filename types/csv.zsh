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

mordioTypeInit[csv]=MORDIO::TYPE::csv::INIT

MORDIO::TYPE::csv::INIT() {
  local __nameVar="$1"
  local __inout="$2"

  populateType "$__nameVar" MORDIO::TYPE::csv
}

MORDIO::TYPE::csv::checkName() {
  local __fname="$1"
  if [[ "$__fname" == *.csv ]]; then
    true
  elif [[ "$__fname" == *.csv.zst ]]; then
    true
  else
    err "Input argument $__fname has invalid extension" 36
  fi
}

MORDIO::TYPE::csv::checkValid() {
  local __fname="$1"
  if [[ ! -r "$__fname" ]]; then
    err "Input argument $__fname does not exist" 36
  fi
  if [[ ! -r "$__fname.meta" ]]; then
    err "Input argument $__fname has no metadata" 36
  fi
}

MORDIO::TYPE::csv::load() {
  local __fname="$1"
  if [[ "$__fname" == *.csv.zst ]]; then
    zstd -dc "$__fname"
  elif [[ "$__fname" == *.csv ]]; then
    cat "$__fname"
  fi
}

MORDIO::TYPE::csv::save() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  if [[ "$__fname" == *.csv.zst ]]; then
    zstd --rsyncable -19 -T$nj > "$__fname"
  elif [[ "$__fname" == *.csv ]]; then
    cat > "$__fname"
  fi
}

# Metadata

MORDIO::TYPE::csv::computeMeta() {
  local __fname="$1"
  MORDIO::TYPE::csv::load "$__fname" \
    | python3 -c "import csv; import sys; r = list(csv.reader(sys.stdin)); print(f'nRow={len(r)}\nnCol={len(r[0] if len(r)>0 else [])}')"
}

MORDIO::TYPE::csv::saveMeta() {
  local __fname="$1"
  if [[ "$__fname" == */* ]]; then
    mkdir -pv "${__fname%/*}"
  fi
  cat > "$__fname.meta"
}

MORDIO::TYPE::csv::getNR() {
  local __fname="$1"
  gawk -F= '/^nRow=/ {print $2} /^---$/ {exit}' "$__fname.meta"
}

MORDIO::TYPE::csv::getNC() {
  local __fname="$1"
  gawk -F= '/^nCol=/ {print $2} /^---$/ {exit}' "$__fname.meta"
}
