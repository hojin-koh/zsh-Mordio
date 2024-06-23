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

# Type definition: base
# This is the base of file types, with no regard of what is inside

mordioTypeInit[file]=MORDIO::TYPE::file::INIT

MORDIO::TYPE::file::INIT() {
  local nameVar=$1
  local inout=$2

  populateType "$nameVar" MORDIO::TYPE::file
}

# === Mordio Things ===

MORDIO::TYPE::file::checkName() {
  local fname=$1
  if [[ $fname == *.zsh ]]; then
    return 0
  else
    return 36
  fi
}

MORDIO::TYPE::file::checkValid() {
  local fname=$1
  local typeMsg=$2
  if [[ ! -r $fname ]]; then
    "$typeMsg" "Argument $fname does not exist"
    return 36
  fi
  if [[ $fname == *.zsh && ! -x $fname ]]; then
    "$typeMsg" "Argument $fname is a script but not executable"
    return 36
  fi
  if [[ ! -r $fname.meta ]]; then
    "$typeMsg" "Argument $fname has no metadata"
    return 36
  fi
  return 0
}

MORDIO::TYPE::file::finalize() {
  local fname=$1
  mv -vf $fname.tmp "$fname"
}

MORDIO::TYPE::file::cleanup() {
  local fname=$1
  rm -vf $fname.tmp
}

MORDIO::TYPE::file::computeMeta() {
  cat >/dev/null
}

MORDIO::TYPE::file::saveMeta() {
  local fname=$1
  if [[ $fname == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  cat > $fname.meta
}

MORDIO::TYPE::file::putMeta() {
  local fname=$1
  local target=$2
  mordioMeta=()
  source $fname.meta
  declare -gA $target
  # This is basically associative array copy
  set -A $target "${(kv@)mordioMeta}"
}

# === Save/Load ===

MORDIO::TYPE::file::isReal() {
  local fname=$1
  if [[ $fname == *.zsh ]]; then
    false
  else
    true
  fi
}

MORDIO::TYPE::file::getLoader() {
  local fname=$1
  if [[ $fname == *.zsh ]]; then
    printf '"./%s"' "$fname"
    return 0
  else
    return 1
  fi
}

MORDIO::TYPE::file::load() {
  local fname=$1
  if [[ $fname == *.zsh ]]; then
    ./$fname
    return 0
  else
    return 1
  fi
}

MORDIO::TYPE::file::save() {
  local fname=$1
  if [[ $fname == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  if [[ $fname == *.zsh ]]; then
    echo "#!/usr/bin/env zsh" > $fname.tmp
    cat >> $fname.tmp
    chmod 755 $fname.tmp
    return 0
  else
    return 1
  fi
}

MORDIO::TYPE::file::saveCopy() {
  local fname=$1
  local fnameSource=$2
  if [[ $fname == */* ]]; then
    mkdir -pv "${fname%/*}"
  fi
  install -v "$fnameSource" $fname.tmp
}
