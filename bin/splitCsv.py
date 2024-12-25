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

# Split the stdin csv into multiple output files in a round-robin manner

import csv
import sys

def main():
    sys.stdin.reconfigure(encoding='utf-8')
    objReader = csv.DictReader(sys.stdin)
    nameKey = objReader.fieldnames[0]
    aFPs = []

    fpwKey = open(sys.argv[1], 'w', encoding='utf-8')

    for fname in sys.argv[2:]:
        fpw = open(fname, 'w', encoding='utf-8')
        objWriter = csv.DictWriter(fpw, objReader.fieldnames, lineterminator="\n")
        objWriter.writeheader()
        aFPs.append((fpw, objWriter))

    isExhausted = False
    while not isExhausted:
        for fpw, objWriter in aFPs:
            try:
                row = next(objReader)
            except StopIteration:
                isExhausted = True
                break
            fpwKey.write(F"{row[nameKey]}\n")
            objWriter.writerow(row)
            fpw.flush()

    for fpw, objWriter in aFPs:
        fpw.close()
    fpwKey.close()

if __name__ == '__main__':
    main()
