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
  local nameVar="$1"
  local inout="$2"

  populateType "$nameVar" MORDIO::TYPE::text
}

# === Mordio Things ===

MORDIO::TYPE::text::checkName() {
  local fname="$1"
  if [[ "$fname" == *.zsh ]]; then
    true
  elif [[ "$fname" == *.txt.zst ]]; then
    true
  else
    err "Input argument $fname has invalid extension" 36
  fi
}

MORDIO::TYPE::text::checkValid() {
  MORDIO::TYPE::table::checkValid "$@"
}

MORDIO::TYPE::text::finalize() {
  MORDIO::TYPE::table::finalize "$@"
}

MORDIO::TYPE::text::cleanup() {
  MORDIO::TYPE::table::cleanup "$@"
}

MORDIO::TYPE::text::computeMeta() {
  local fname="$1"
  MORDIO::TYPE::text::load "$fname" \
    | LC_ALL=en_US.UTF-8 gawk -F$'\t' '
        END {
          print "nRecord=" NR;
        }'
}

MORDIO::TYPE::text::saveMeta() {
  MORDIO::TYPE::table::saveMeta "$@"
}

MORDIO::TYPE::text::dumpMeta() {
  MORDIO::TYPE::table::dumpMeta "$@"
}

MORDIO::TYPE::text::getMainFile() {
  MORDIO::TYPE::table::getMainFile "$@"
}

# === Save/Load ===

MORDIO::TYPE::text::isReal() {
  MORDIO::TYPE::table::isReal "$@"
}

MORDIO::TYPE::text::getLoader() {
  MORDIO::TYPE::table::getLoader "$@"
}

MORDIO::TYPE::text::load() {
  MORDIO::TYPE::table::load "$@"
}

MORDIO::TYPE::text::save() {
  MORDIO::TYPE::table::save "$@"
}

# === Metadata Processing ===

MORDIO::TYPE::text::getNR() {
  MORDIO::TYPE::table::getNR "$@"
}

