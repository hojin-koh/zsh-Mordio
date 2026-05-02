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

import typing

import io
import csv
import tarfile

import zstandard as zstd

type TypeArchiveIterator = typing.Iterator[tuple[tarfile.TarInfo,io.BufferReader]]

class IndexedTarZstdWriter:
    """
    Tarfile-like interface for an indexed .tar.zstd archive, the writer part
    """
    def __init__(self,
                 name: str,
                 fIndex: str|None = None,
                 sizeBlock: int = 4194304,
                 levelCompression: int = 17,
                 ) -> None:
        self.sizeBlock: int = sizeBlock
        self.name: str = name

        self._fp: typing.BinaryIO|None = None
        self._fpwIndex: zstd.ZstdCompressionWriter|None = None
        self._fpwCsv: csv.DictWriter|None = None
        self._closed: bool = True
        self._objZstd = zstd.ZstdCompressor(level=levelCompression, write_content_size=True)

        try:
            self._fp = open(name, 'wb')
            self._closed = False
            if fIndex is not None:
                objZstdForIndex = zstd.ZstdCompressor(level=levelCompression)
                self._fpwIndex = objZstdForIndex.stream_writer(open(fIndex, 'wb'), closefd=True)
                self._fpwCsv = csv.DictWriter(
                        io.TextIOWrapper(self._fpwIndex, encoding='utf-8', newline='\n', write_through=True),
                        ('id', 'archive', 'offset'),
                        lineterminator="\n",
                        )
                self._fpwCsv.writeheader()
        except Exception:
            self.close()
            raise

    def addfile(self, tarinfo:tarfile.TarInfo, fpRead:typing.BinaryIO|None=None) -> None:
        """Write a TarInfo + payload as one self-contained zstd frame."""

        assert self._fp is not None
        offset = self._fp.tell()

        bufHeader = tarinfo.tobuf()
        sizePad = (512 - tarinfo.size%512) % 512
        lenFrame = len(bufHeader) + tarinfo.size + sizePad

        try:
            with self._objZstd.stream_writer(self._fp, closefd=False, size=lenFrame, write_size=self.sizeBlock) as z:
                z.write(bufHeader)
                remain = tarinfo.size
                if tarinfo.size > 0 and fpRead is None:
                    raise OSError("TarInfo object specifies non-zero size, but no file is provided")
                if fpRead:
                    while True:
                        chunk = fpRead.read(self.sizeBlock)
                        if not chunk:
                            break
                        if len(chunk) > remain:
                            raise OSError(F"The provided file is larger than specified by TarInfo object {len(chunk)} {remain} {tarinfo.name}")
                        z.write(chunk)
                        remain -= len(chunk)
                    if remain > 0:
                        raise OSError("The provided file is smaller than specified by TarInfo object")
                z.write(b'\x00' * sizePad)
        except (OSError, zstd.ZstdError): # Rollback in case of trouble
            self._fp.seek(offset)
            self._fp.truncate()
            raise

        if self._fpwIndex:
            assert self._fpwCsv is not None
            self._fpwCsv.writerow({'id': tarinfo.name, 'archive': self.name, 'offset': offset})

    def close(self) -> None:
        if self._closed:
            return
        assert self._fp is not None

        # Final tar EOF block as its own frame
        with self._objZstd.stream_writer(self._fp, closefd=False, size=tarfile.BLOCKSIZE*2) as z:
            z.write(b'\x00' * (tarfile.BLOCKSIZE*2))

        self._fp.close()
        if self._fpwIndex:
            self._fpwIndex.close()
        self._closed = True

    def __enter__(self): # type: ignore
        return self

    def __exit__(self, *exc): # type: ignore
        self.close()
        return False


class IndexedTarZstdReader:
    """
    Tarfile-like interface for an indexed .tar.zstd archive, the reading part
    """
    def __init__(self,
                 name: str,
                 fIndex: str|typing.TextIO|None = None,
                 sizeBlock: int = 4194304,
                 ) -> None:
        self.sizeBlock: int = sizeBlock
        self.name: str = name

        self._mode: typing.Literal['archive', 'index']|None = None
        self._fp: zstd.ZstdDecompressionReader|None = None
        self._fpTar: tarfile.TarFile|None = None
        self._fpCsv: csv.DictReader|None = None
        self._closed: bool = True
        self._objZstd = zstd.ZstdDecompressor()

        # Sniff to decide if this is an tarball or index csv
        try:
            with self._objZstd.stream_reader(open(name, 'rb'), closefd=True) as fpTest:
                with tarfile.open(fileobj=fpTest, mode='r|'):
                    self._mode = 'archive'
        except tarfile.ReadError:
            self._mode = 'index'

        try:
            objZstdMainFile = zstd.ZstdDecompressor()
            self._fp = objZstdMainFile.stream_reader(
                    open(name, 'rb'),
                    read_size=self.sizeBlock,
                    read_across_frames=True,
                    closefd=True
                    )
            self._closed = False
            if self._mode == 'archive':
                self._fpTar = tarfile.open(fileobj=self._fp, mode='r|')
            else:
                self._fpCsv = csv.DictReader(io.TextIOWrapper(self._fp, encoding='utf-8'))
        except Exception:
            self.close()
            raise

    def iteratorIndex(self) -> TypeArchiveIterator:
        fpArchiveThis: typing.BinaryIO|None = None
        nameArchiveThis: str|None = None
        try:
            for row in self._fpCsv:
                if nameArchiveThis != row['archive']:
                    if fpArchiveThis:
                        fpArchiveThis.close()
                    nameArchiveThis = row['archive']
                    fpArchiveThis = open(nameArchiveThis, 'rb')
                fpArchiveThis.seek(int(row['offset']))
                with self._objZstd.stream_reader(fpArchiveThis, read_size=self.sizeBlock, closefd=False) as fpZstd:
                    with tarfile.open(fileobj=fpZstd, mode='r|') as objTar:
                        entry = objTar.next()
                        if row['id'] != entry.name:
                            raise OSError("The filename in the index is different from that in the archive")
                        fpEntry = objTar.extractfile(entry)
                        yield entry, fpEntry

        finally:
            if fpArchiveThis:
                fpArchiveThis.close()

    def iteratorArchive(self) -> TypeArchiveIterator:
        assert self._fpTar is not None
        for entry in self._fpTar:
            fpEntry = self._fpTar.extractfile(entry)
            yield entry, fpEntry

    def __iter__(self) -> TypeArchiveIterator:
        if self._mode == 'archive':
            return self.iteratorArchive()
        else:
            return self.iteratorIndex()

    def close(self) -> None:
        if self._closed:
            return
        assert self._fp is not None

        self._fp.close()
        if self._fpTar:
            self._fpTar.close()
        self._closed = True

    def __enter__(self): # type: ignore
        return self

    def __exit__(self, *exc): # type: ignore
        self.close()
        return False
