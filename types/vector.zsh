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
# Dimensions of vectors are separated by tabs
# Dimensions are supposed to be the same across all rows

mordioTypeInit[vector]=MORDIO::TYPE::vector::INIT

MORDIO::TYPE::vector::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::file
  populateType "$nameVar" MORDIO::TYPE::table
  populateType "$nameVar" MORDIO::TYPE::vector
}

# === Mordio Things ===

MORDIO::TYPE::vector::checkName() {
  local fname="$1"
  if ! MORDIO::TYPE::file::checkName "$@"; then
    if [[ "$fname" == *.vec.zst ]]; then
      return 0
    else
      err "Input argument $fname has invalid extension"
      return 36
    fi
  fi
  return 0
}

MORDIO::TYPE::vector::computeMeta() {
  local fname=$1
  perl -CSAD -lane 'END {my $NF = $#F+1; print "[nRecord]=$.\n[nDim]=$NF"}'
}

# === Save/Load ===

