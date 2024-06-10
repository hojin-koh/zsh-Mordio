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
  if [[ "$fname" == *.zsh ]]; then
    true
  elif [[ "$fname" == *.zst ]]; then
    true
  else
    warn "Input argument $fname has invalid extension"
    return 36
  fi
}

MORDIO::TYPE::table::checkValid() {
  local fname="$1"
  local warnerr="$2"
  if [[ ! -r "$fname" ]]; then
    "$warnerr" "Argument $fname does not exist"
    return 36
  fi
  if [[ "$fname" == *.zsh && ! -x "$fname" ]]; then
    "$warnerr" "Argument $fname is a script but not executable"
    return 36
  fi
  if [[ ! -r "$fname.meta" ]]; then
    "$warnerr" "Argument $fname has no metadata"
    return 36
  fi
}

MORDIO::TYPE::table::finalize() {
  local fname="$1"
  mv -vf "$fname.tmp" "$fname"
}

MORDIO::TYPE::table::cleanup() {
  local fname="$1"
  rm -vf "$fname.tmp"
}

MORDIO::TYPE::table::computeMeta() {
  local fname="$1"
  MORDIO::TYPE::table::load "$fname" \
    | LC_ALL=en_US.UTF-8 gawk -F$'\t' '
        END {
          print "nRecord=" NR;
          print "nField=" NF;
        }'
}

MORDIO::TYPE::table::saveMeta() {
  local fname="$1"
  if [[ "$fname" == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  cat > "$fname.meta"
}

MORDIO::TYPE::table::dumpMeta() {
  local fname="$1"
  cat "$fname.meta"
}

MORDIO::TYPE::table::getMainFile() {
  local fname="$1"
  echo "$fname"
}

# === Save/Load ===

MORDIO::TYPE::table::isReal() {
  local fname="$1"
  if [[ "$fname" == *.zsh ]]; then
    false
  else
    true
  fi
}

MORDIO::TYPE::table::getLoader() {
  local fname="$1"
  if [[ "$fname" == *.zsh ]]; then
    printf '"./%s"' "$fname"
  elif [[ "$fname" == *.zst ]]; then
    printf 'zstd -dc "%s"' "$fname"
  fi
}

MORDIO::TYPE::table::load() {
  local fname="$1"
  if [[ "$fname" == *.zsh ]]; then
    "./$fname"
  elif [[ "$fname" == *.zst ]]; then
    zstd -dc "$fname"
  fi
}

MORDIO::TYPE::table::save() {
  local fname="$1"
  if [[ "$fname" == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  if [[ "$fname" == *.zsh ]]; then
    echo "#!/usr/bin/env zsh" > "$fname.tmp"
    cat >> "$fname.tmp"
    chmod 755 "$fname.tmp"
  else
    zstd --rsyncable -13 -T$nj > "$fname.tmp"
  fi
}

# === Metadata Processing ===

MORDIO::TYPE::table::getNR() {
  local fname="$1"
  MORDIO::TYPE::table::dumpMeta "$1" \
  | gawk -F= '/^nRecord=/ {print $2} /^---$/ {exit}'
}

MORDIO::TYPE::table::getNF() {
  local fname="$1"
  MORDIO::TYPE::table::dumpMeta "$1" \
  | gawk -F= '/^nField=/ {print $2} /^---$/ {exit}'
}
