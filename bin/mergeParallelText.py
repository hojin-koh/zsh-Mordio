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

# Merge multiple fifo pipes of text output into a single stream,
# preserving the order of predetermined keys

import os
import selectors
import sys

idxKey = 0
nKey = 0
aKeys = []
aPipes = []
mBuffer = {}
mLineBuffer = {}

def readKeys(fname):
    global nKey
    with open(fname, 'rb') as fp:
        for key in fp:
            if b'\t' in key:
                key = key.split(b'\t', 1)[0]
            if len(key) > 0:
                aKeys.append(key.strip())
    nKey = len(aKeys)

def processPipeData(objSel, fp):
    global nKey
    global idxKey
    line = fp.readline()

    if line:
        # Buffering for incomplete packets
        if fp in mLineBuffer:
            line = mLineBuffer[fp] + line
        if not line.endswith(b"\n"):
            mLineBuffer[fp] = line
            return
        else:
            if fp in mLineBuffer:
                del mLineBuffer[fp]

        if b'\t' in line:
            key, val = line.split(b'\t', 1)
        else:
            key = line
            val = ''
        key = key.strip()
        if key != aKeys[idxKey]:
            mBuffer[key] = line
        else:
            idxKey += 1
            sys.stdout.buffer.write(line)
        # See if any other blocked outputs can now be printed
        while idxKey < nKey and len(mBuffer)>0:
            if aKeys[idxKey] not in mBuffer:
                break
            key = aKeys[idxKey]
            idxKey += 1
            line = mBuffer[key]
            sys.stdout.buffer.write(line)
            del mBuffer[key]

    else:
        # Pipe closed by writer, cleanup
        objSel.unregister(fp)
        fp.close()

def main():
    readKeys(sys.argv[1])
    aPipeFiles = sys.argv[2:]

    objSel = selectors.DefaultSelector()

    for fname in aPipeFiles:
        fp = open(fname, 'rb')
        os.set_blocking(fp.fileno(), False)
        aPipes.append(fp)
        objSel.register(fp, selectors.EVENT_READ, processPipeData)

    try:
        while len(objSel.get_map()) > 0:
            events = objSel.select(1)  # Wait for events
            for key, dumb in events:
                callback = key.data
                callback(objSel, key.fileobj)
    finally:
        objSel.close()
        for pipe in aPipes:
            pipe.close()

if __name__ == '__main__':
    main()

