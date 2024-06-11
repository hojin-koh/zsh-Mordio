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

# Type definition: model
# Just a model file, potentially zstd-compressed
# We know nothing about the interior of the model

mordioTypeInit[model]=MORDIO::TYPE::model::INIT

MORDIO::TYPE::model::INIT() {
  local nameVar="$1"
  local inout="$2"

  populateType "$nameVar" MORDIO::TYPE::model
}

# === Mordio Things ===

MORDIO::TYPE::model::checkName() {
  local fname="$1"
  if ! MORDIO::TYPE::file::checkName "$@"; then
    if [[ "$fname" == *.zst ]]; then
      return 0
    elif [[ "$fname" == *.gz ]]; then
      return 0
    elif [[ "$fname" == *.bz2 ]]; then
      return 0
    elif [[ "$fname" == *.model ]]; then
      return 0
    else
      err "Input argument $fname has invalid extension"
      return 36
    fi
  fi
  return 0
}

MORDIO::TYPE::model::checkValid() {
  MORDIO::TYPE::file::checkValid "$@"
}

MORDIO::TYPE::model::finalize() {
  MORDIO::TYPE::file::finalize "$@"
}

MORDIO::TYPE::model::cleanup() {
  MORDIO::TYPE::file::cleanup "$@"
}

MORDIO::TYPE::model::computeMeta() {
  MORDIO::TYPE::file::computeMeta "$@"
}

MORDIO::TYPE::model::saveMeta() {
  MORDIO::TYPE::file::saveMeta "$@"
}

MORDIO::TYPE::model::dumpMeta() {
  MORDIO::TYPE::file::dumpMeta "$@"
}

MORDIO::TYPE::model::checkScriptSum() {
  MORDIO::TYPE::file::checkScriptSum "$@"
}

MORDIO::TYPE::model::getMainFile() {
  MORDIO::TYPE::file::getMainFile "$@"
}

# === Save/Load ===

MORDIO::TYPE::model::isReal() {
  MORDIO::TYPE::file::isReal "$@"
}

MORDIO::TYPE::model::getLoader() {
  local fname="$1"
  if ! MORDIO::TYPE::file::getLoader "$@"; then
    if [[ "$fname" == *.zst ]]; then
      printf 'zstd -dc "%s"' "$fname"
      return 0
    elif [[ "$fname" == *.gz ]]; then
      printf 'gunzip -c "%s"' "$fname"
      return 0
    elif [[ "$fname" == *.bz2 ]]; then
      printf 'bunzip2 -c "%s"' "$fname"
      return 0
    elif [[ "$fname" == *.model ]]; then
      printf 'cat "%s"' "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::model::load() {
  local fname="$1"
  if ! MORDIO::TYPE::file::load "$@"; then
    if [[ "$fname" == *.zst ]]; then
      zstd -dc "$fname"
      return 0
    elif [[ "$fname" == *.gz ]]; then
      gunzip -c "$fname"
      return 0
    elif [[ "$fname" == *.bz2 ]]; then
      bunzip2 -c "$fname"
      return 0
    elif [[ "$fname" == *.model ]]; then
      cat "$fname"
      return 0
    else
      return 1
    fi
  fi
}

MORDIO::TYPE::model::save() {
  local fname="$1"
  if ! MORDIO::TYPE::file::save "$@"; then
    if [[ "$fname" == *.zst ]]; then
      zstd --rsyncable --ultra -22 -T$nj > "$fname.tmp"
      return 0
    elif [[ "$fname" == *.gz ]]; then
      gzip -9c > "$fname.tmp"
      return 0
    elif [[ "$fname" == *.bz2 ]]; then
      bzip2 -9c > "$fname.tmp"
      return 0
    elif [[ "$fname" == *.model ]]; then
      cat > "$fname.tmp"
      return 0
    else
      return 1
    fi
  fi
}
