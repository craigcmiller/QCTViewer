/*
 *   This file is part of libqct
 *
 *   libqct is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Lesser General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   libqct is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public License
 *   along with libqct.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   Copyright (c)2009 K D Miller
 */

/**
 * Subject: Memory mapped file i/o for UNIX/Windows
 * Filename: qctmmap.cpp
 * Date: 27 Sept 2009
 * Author: kdm
 */

#include "qctmmap.h"
#include <vector>

#ifndef WIN32
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#include <cassert>
#include <iostream>

#ifndef WIN32

QctMemMap::QctMemMap()
  : m_fd(-1)
  , m_size(0)
  , m_data(0)
  , m_preferredWindowSize(1048576 * 128)
  , m_actualWindowSize(m_preferredWindowSize)
  , m_lastActualWindowSize(m_preferredWindowSize)
  , m_windowOffset(0)
{
}


void QctMemMap::open(const char* filename)
{
    struct stat finfo;

    m_fd = ::open(filename, O_RDONLY); // O_NOATIME
    fstat(m_fd, &finfo);
    m_size = finfo.st_size;
    m_actualWindowSize = std::min(m_size, m_preferredWindowSize); // if window is bigger than file, decrease window to file size
    map(m_actualWindowSize, 0); // initial mapping for file offset zero
}


void QctMemMap::map(size_t size, size_t fileOffset)
{
    //std::cout << "MAP: Size:" << size << " Offset: " << fileOffset << std::endl;
    if (m_data)
        munmap(m_data, m_lastActualWindowSize);
    m_data = mmap(NULL, size, PROT_READ, MAP_SHARED, m_fd, fileOffset); // map region at kernel decided address, whole file size, starting offset zero
    assert(m_data != MAP_FAILED);
}


void QctMemMap::close()
{
    munmap(m_data, m_actualWindowSize);
    ::close(m_fd);
}

#else

QctMemMap::QctMemMap(const char* filename)
  : m_hFile(INVALID_HANDLE_VALUE)
  , m_hMapping(INVALID_HANDLE_VALUE)
  , m_size(0)
  , m_data(0)
{
    if (filename)
        open(filename);
}


void QctMemMap::open(const char* filename)
{
    m_hFile = CreateFileA(filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    m_size = GetFileSize(m_hFile, NULL);
    m_hMapping = CreateFileMapping(m_hFile, NULL, PAGE_READONLY, 0, 0, NULL);
    m_data = MapViewOfFile(m_hMapping, FILE_MAP_READ, 0, 0, 0);
    assert(m_data);
}


void QctMemMap::close()
{
    UnmapViewOfFile(m_data);
    CloseHandle(m_hMapping);
    CloseHandle(m_hFile);
}

#endif


QctMemMap::~QctMemMap()
{
}

