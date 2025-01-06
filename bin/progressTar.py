#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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

# Show progress bar for tar data

import tarfile
import sys


def main():
    nFile = int(sys.argv[1])
    fpTar = tarfile.open(fileobj=sys.stdin.buffer, mode='r|')

    try:
        from tqdm import tqdm
        fpShow = open('/dev/fd/5', 'w', encoding='utf-8')
        pbar = tqdm(total=nFile, file=fpShow, smoothing=0, mininterval=2, dynamic_ncols=True)
    except:
        pbar = None
        pass
    
    with tarfile.open(fileobj=sys.stdout.buffer, mode='w|') as fpwTar:
        for entry in fpTar:
            if entry.isdir():
                continue
            fpFile = fpTar.extractfile(entry)
            fpwTar.addfile(entry, fileobj=fpFile)
            if pbar:
                pbar.update(1)

    if pbar:
        pbar.close()

if __name__ == '__main__':
    main()
