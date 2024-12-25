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

# Merge multiple fifo pipes of csv output into a single stream,
# preserving the order of predetermined keys

import csv
import os
import selectors
import sys

idxKey = 0
objWriter = None
nameKey = None
aCols = None
aKeys = []
aPipes = []
mBuffer = {}
mLineBuffer = {}

def readKey(objSel, fp, _dumb):
    line = fp.readline()

    if line:
        aKeys.append(line.strip())
    else:
        # Pipe closed by writer, cleanup
        objSel.unregister(fp)
        fp.close()

def processPipeData(objSel, fp, objReader):
    global objWriter
    global nameKey
    global idxKey

    if nameKey is None:
        nameKey = objReader.fieldnames[0]
        objWriter = csv.DictWriter(sys.stdout, objReader.fieldnames, lineterminator="\n")
        objWriter.writeheader()

    try:
        row = next(objReader)
        key = row[nameKey]

        if idxKey < len(aKeys) and key == aKeys[idxKey]:
            idxKey += 1
            objWriter.writerow(row)
            sys.stdout.flush()
        else:
            mBuffer[key] = row
        # See if any other blocked outputs can now be printed
        while idxKey < len(aKeys) and len(mBuffer)>0:
            if aKeys[idxKey] not in mBuffer:
                break
            key = aKeys[idxKey]
            idxKey += 1
            objWriter.writerow(mBuffer[key])
            sys.stdout.flush()
            del mBuffer[key]

    except Exception as e:
        # Pipe closed by writer, cleanup
        objSel.unregister(fp)
        fp.close()

def main():
    global idxKey

    objSel = selectors.DefaultSelector()

    fpKey = open(sys.argv[1], 'r', encoding='utf-8')
    os.set_blocking(fpKey.fileno(), False)
    aPipes.append(fpKey)
    objSel.register(fpKey, selectors.EVENT_READ, (readKey, None))

    sys.stdout.reconfigure(encoding='utf-8')

    for fname in sys.argv[2:]:
        fp = open(fname, 'r', encoding='utf-8')
        os.set_blocking(fp.fileno(), False)
        objReader = csv.DictReader(fp)
        aPipes.append(fp)
        objSel.register(fp, selectors.EVENT_READ, (processPipeData, objReader))

    try:
        while len(objSel.get_map()) > 0:
            events = objSel.select(1)  # Wait for events
            for key, dumb in events:
                callback = key.data[0]
                objReader = key.data[1]
                callback(objSel, key.fileobj, objReader)
    finally:
        objSel.close()
        for pipe in aPipes:
            pipe.close()
    while idxKey < len(aKeys) and len(mBuffer)>0:
        if aKeys[idxKey] not in mBuffer:
            break
        key = aKeys[idxKey]
        idxKey += 1
        objWriter.writerow(mBuffer[key])
        del mBuffer[key]

if __name__ == '__main__':
    main()
