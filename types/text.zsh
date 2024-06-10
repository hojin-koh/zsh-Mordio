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
  if ! MORDIO::TYPE::file::checkName "$@"; then
    if [[ "$fname" == *.txt.zst ]]; then
      return 0
    else
      err "Input argument $fname has invalid extension"
      return 36
    fi
  fi
  return 0
}

MORDIO::TYPE::text::checkValid() {
  MORDIO::TYPE::file::checkValid "$@"
}

MORDIO::TYPE::text::finalize() {
  MORDIO::TYPE::file::finalize "$@"
}

MORDIO::TYPE::text::cleanup() {
  MORDIO::TYPE::file::cleanup "$@"
}

MORDIO::TYPE::text::computeMeta() {
  MORDIO::TYPE::table::computeMeta "$@"
}

MORDIO::TYPE::text::saveMeta() {
  MORDIO::TYPE::file::saveMeta "$@"
}

MORDIO::TYPE::text::dumpMeta() {
  MORDIO::TYPE::file::dumpMeta "$@"
}

MORDIO::TYPE::text::checkScriptSum() {
  MORDIO::TYPE::file::checkScriptSum "$@"
}

MORDIO::TYPE::text::getMainFile() {
  MORDIO::TYPE::file::getMainFile "$@"
}

# === Save/Load ===

MORDIO::TYPE::text::isReal() {
  MORDIO::TYPE::file::isReal "$@"
}

MORDIO::TYPE::text::getLoader() {
  MORDIO::TYPE::table::getLoader "$@"
}

MORDIO::TYPE::text::load() {
  MORDIO::TYPE::table::load "$@"
}

MORDIO::TYPE::text::getLoaderKey() {
  MORDIO::TYPE::table::getLoaderKey "$@"
}

MORDIO::TYPE::text::loadKey() {
  MORDIO::TYPE::table::loadKey "$@"
}

MORDIO::TYPE::text::getLoaderValue() {
  MORDIO::TYPE::table::getLoaderValue "$@"
}

MORDIO::TYPE::text::loadValue() {
  MORDIO::TYPE::table::loadValue "$@"
}

MORDIO::TYPE::text::save() {
  MORDIO::TYPE::table::save "$@"
}

# === Metadata Processing ===

MORDIO::TYPE::text::getNR() {
  MORDIO::TYPE::table::getNR "$@"
}

