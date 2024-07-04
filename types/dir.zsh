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

# Type definition: dir
# This is the base of directory types, with no regard of what is inside

mordioTypeInit[dir]=MORDIO::TYPE::dir::INIT

MORDIO::TYPE::dir::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::dir
}

# === Mordio Things ===

MORDIO::TYPE::dir::checkName() {
  true
}

MORDIO::TYPE::dir::checkValid() {
  local fname=$1
  local typeMsg=$2
  if [[ ! -d $fname ]]; then
    "$typeMsg" "Argument $fname does not exist or is not a directory"
    return 36
  fi
  return 0
}

MORDIO::TYPE::dir::finalize() {
  local fname=$1
  if [[ -d $fname ]]; then
    warn "Removing old directory $fname"
    rm -rf $fname
  fi
  mv -f $fname.tmp "$fname"
}

MORDIO::TYPE::dir::cleanup() {
  local fname=$1
  rm -vrf $fname.tmp
}

MORDIO::TYPE::dir::computeMeta() {
  cat >/dev/null
}

MORDIO::TYPE::dir::saveMeta() {
  local fname=$1
  mkdir -pv "$fname"
  cat > $fname/.meta
}

MORDIO::TYPE::dir::putMeta() {
  local fname=$1
  local target=$2
  mordioMeta=()
  source $fname/.meta
  declare -gA $target
  # This is basically associative array copy
  set -A $target "${(kv@)mordioMeta}"
}

# === Save/Load ===

MORDIO::TYPE::dir::putDir() {
  local fname=$1
  local target=$2
  declare -g $target
  mkdir -p $fname.tmp
  eval "$target=$fname.tmp"
}

MORDIO::TYPE::dir::load() {
  local fname=$1
  local files=( "${(f@)$(cd "$fname"; find . -type f)}" )
  for f in "${(o@)files}"; do
    if [[ $f == ./.meta ]]; then continue; fi
    cat "$fname/$f"
  done
}
