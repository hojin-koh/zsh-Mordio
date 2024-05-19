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

opt -Mordio auto-logdir "${MORDIO_LOGDIR-}" "Directory to keep logs if logfile is not set"

MORDIO::FLOW::setupLogging() {
  if [[ -z "$logfile" ]]; then # If the Skritt version is not set
    if [[ -n "$auto_logdir" ]]; then # If the Mordio version is set
      local nameScript="${ZSH_ARGZERO##*/}"
      nameScript="${nameScript%%.zsh}"
      logfile="$auto_logdir/$(date +'%Y%m%d-%H%M%S')-$nameScript.log"
    fi
  fi
}
addHook postparse MORDIO::FLOW::setupLogging
