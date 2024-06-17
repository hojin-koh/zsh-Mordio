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

# Type definition: vector
# vector is a series of id/vector pair, separated by a tab (vec.zst)
# or is in tar file + npy format (npy.tar.zst)

mordioTypeInit[vector]=MORDIO::TYPE::vector::INIT

MORDIO::TYPE::vector::INIT() {
  local nameVar="$1"
  local inout="$2"

  populateType "$nameVar" MORDIO::TYPE::vector
}

# === Mordio Things ===

MORDIO::TYPE::vector::checkName() {
  local fname="$1"
  if ! MORDIO::TYPE::file::checkName "$@"; then
    if [[ "$fname" == *.vec.zst ]]; then
      return 0
    elif [[ "$fname" == *.npy.tar.zst ]]; then
      return 0
    else
      err "Input argument $fname has invalid extension"
      return 36
    fi
  fi
  return 0
}

MORDIO::TYPE::vector::checkValid() {
  MORDIO::TYPE::file::checkValid "$@"
}

MORDIO::TYPE::vector::finalize() {
  MORDIO::TYPE::file::finalize "$@"
}

MORDIO::TYPE::vector::cleanup() {
  MORDIO::TYPE::file::cleanup "$@"
}

MORDIO::TYPE::vector::computeMeta() {
  MORDIO::TYPE::table::computeMeta "$@"
}

MORDIO::TYPE::vector::saveMeta() {
  MORDIO::TYPE::file::saveMeta "$@"
}

MORDIO::TYPE::vector::dumpMeta() {
  MORDIO::TYPE::file::dumpMeta "$@"
}

MORDIO::TYPE::vector::checkScriptSum() {
  MORDIO::TYPE::file::checkScriptSum "$@"
}

MORDIO::TYPE::vector::getMainFile() {
  MORDIO::TYPE::file::getMainFile "$@"
}

# === Save/Load ===

MORDIO::TYPE::vector::isReal() {
  MORDIO::TYPE::file::isReal "$@"
}

MORDIO::TYPE::vector::getLoader() {
  MORDIO::TYPE::table::getLoader "$@"
}

MORDIO::TYPE::vector::load() {
  MORDIO::TYPE::table::load "$@"
}

MORDIO::TYPE::vector::getLoaderKey() {
  MORDIO::TYPE::table::getLoaderKey "$@"
}

MORDIO::TYPE::vector::loadKey() {
  MORDIO::TYPE::table::loadKey "$@"
}

MORDIO::TYPE::vector::getLoaderValue() {
  MORDIO::TYPE::table::getLoaderValue "$@"
}

MORDIO::TYPE::vector::loadValue() {
  MORDIO::TYPE::table::loadValue "$@"
}

MORDIO::TYPE::vector::save() {
  MORDIO::TYPE::table::save "$@"
}

# === Metadata Processing ===

MORDIO::TYPE::vector::getNR() {
  MORDIO::TYPE::table::getNR "$@"
}

