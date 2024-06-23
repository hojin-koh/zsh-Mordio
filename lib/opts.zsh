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

# Mordio-specific options
opt -Mordio nj ${OMP_NUM_THREADS-3} "Number of parallel processes on this machine"

MORDIO::FLOW::exportParallel() {
  if [[ -z $nj ]]; then return; fi
  export OMP_THREAD_LIMIT=$nj
  export OMP_NUM_THREADS=$nj
  export NUMEXPR_NUM_THREADS=$nj
  export OPENBLAS_NUM_THREADS=$nj
  export MKL_NUM_THREADS=$nj
  export JULIA_NUM_THREADS=$nj
}
addHook prerun MORDIO::FLOW::exportParallel
