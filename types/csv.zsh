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

# Type definition: csv
# Table is a series of id/contents rows, separated by tabs

mordioTypeInit[csv]=MORDIO::TYPE::csv::INIT

MORDIO::TYPE::csv::INIT() {
  local nameVar="$1"
  local inout="$2"

  populateType "$nameVar" MORDIO::TYPE::csv
}

MORDIO::TYPE::csv::checkName() {
  local fname="$1"
  if [[ "$fname" == *.csv ]]; then
    true
  elif [[ "$fname" == *.csv.zst ]]; then
    true
  else
    err "Input argument $fname has invalid extension" 36
  fi
}

MORDIO::TYPE::csv::checkValid() {
  local fname="$1"
  if [[ ! -r "$fname" ]]; then
    err "Input argument $fname does not exist" 36
  fi
  if [[ ! -r "$fname.meta" ]]; then
    err "Input argument $fname has no metadata" 36
  fi
}

MORDIO::TYPE::csv::load() {
  local fname="$1"
  if [[ "$fname" == *.csv.zst ]]; then
    zstd -dc "$fname"
  elif [[ "$fname" == *.csv ]]; then
    cat "$fname"
  fi
}

MORDIO::TYPE::csv::save() {
  local fname="$1"
  if [[ "$fname" == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  if [[ "$fname" == *.csv.zst ]]; then
    zstd --rsyncable -19 -T$nj > "$fname.tmp"
  elif [[ "$fname" == *.csv ]]; then
    cat > "$fname.tmp"
  fi
}

MORDIO::TYPE::csv::finalize() {
  local fname="$1"
  mv -vf "$fname.tmp" "$fname"
}

MORDIO::TYPE::csv::cleanup() {
  local fname="$1"
  rm -vf "$fname.tmp"
}

# Metadata

MORDIO::TYPE::csv::computeMeta() {
  local fname="$1"
  MORDIO::TYPE::csv::load "$fname" \
    | python3 -c "import csv; import sys; r = list(csv.reader(sys.stdin)); print(f'nRow={len(r)}\nnCol={len(r[0] if len(r)>0 else [])}')"
}

MORDIO::TYPE::csv::saveMeta() {
  local fname="$1"
  if [[ "$fname" == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  cat > "$fname.meta"
}

MORDIO::TYPE::csv::getNR() {
  local fname="$1"
  gawk -F= '/^nRow=/ {print $2} /^---$/ {exit}' "$fname.meta"
}

MORDIO::TYPE::csv::getNC() {
  local fname="$1"
  gawk -F= '/^nCol=/ {print $2} /^---$/ {exit}' "$fname.meta"
}
