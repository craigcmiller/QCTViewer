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
 * Filename: qctmmap.h
 * Date: 27 Sept 2009
 * Author: kdm
 */

#ifndef _QCTMMAP_H_
#define	_QCTMMAP_H_

#include <sys/types.h>
#include <cstddef>
#include <algorithm>

#ifdef WIN32
#include <windows.h>
#endif

#include "qctutil.h"

/**
 * Memory mapped file I/O for UNIX / Windows
 */

class QCT_API_EXPORT QctMemMap
{
public:
    QctMemMap();
    ~QctMemMap();

    void open(const char* filename = 0); //! open a file, and map region
    void close(); //! close a file, and unmap region

    void map(size_t size, size_t fileOffset);

    inline void* getDataPtr() { return m_data; }
    inline void* getDataPtr(const size_t offset);
    inline size_t getSize() const { return m_size; } //! get file size

    //! Set max mapping region size. Must be called before opening file.
    //inline void setWindowSize(size_t windowSize) { m_windowSize = windowSize; }

#ifdef WIN32
    HANDLE m_hFile;
    HANDLE m_hMapping;
#else
    int m_fd;
#endif
    size_t m_size;
    void* m_data;
    size_t m_preferredWindowSize; //! max size of mapped region
    size_t m_actualWindowSize;
    size_t m_lastActualWindowSize; //! previous actual window size - need to keep track of this for unmapping
    size_t m_windowOffset; //! start file offset of mapped region - normally gets automatically determined in getDataPtr()
};


/**
 * Region allocator
 * Rules:
 * 1. Regions are mapped in fixed size blocks of m_windowSize
 * 2. If within 8K of end of block, a remapping of next m_windowSize bytes occurs (or remaining bytes, if m_windowSize excceds bytes that remain in file)
 * 3. If offset < m_windowOffset, map from m_windowSize bytes before m_windowOffset (or zero)
 */
//#include <iostream>
inline void* QctMemMap::getDataPtr(const size_t offset)
{
    bool remap = false;
    size_t maxRemain = m_size;
    //std::cout << "Request offset: " << offset << std::endl;

    // if offset is past end of current mapping, or nearby, map next 256Mb (or whatever remains) region
    while (offset > m_windowOffset + (m_preferredWindowSize - 8192))
    {
        m_windowOffset += (m_preferredWindowSize - 8192);
        maxRemain = m_size - m_windowOffset; // max number of bytes that could possible be mapped
        //std::cout << "MAP FORWARD TO: " << m_windowOffset << std::endl;
        remap = true;
    }

    while (offset < m_windowOffset) // map previous region
    {
        //std::cout << "MAP BACKWARD TO: " << m_windowOffset << std::endl;
        m_windowOffset -= (m_preferredWindowSize - 8192);
        // map previous region (m_windowOffset - 8192)
        remap = true;
    }

    //std::cout << "maxRemain: " << maxRemain << " File size: " << m_size << std::endl;
    //std::cout << "preferred window size: " << m_preferredWindowSize << " actual: " << m_actualWindowSize << std::endl;

    if (remap) {
        m_lastActualWindowSize = m_actualWindowSize;
        m_actualWindowSize = std::min(maxRemain, std::min(m_size, m_preferredWindowSize));
        map(m_actualWindowSize, m_windowOffset);
    }

    size_t blockOffset = offset - m_windowOffset; // calculate offset within currently mapped region
    //std::cout << "Offset within current window: " << blockOffset << std::endl;
    return reinterpret_cast<void *>((size_t)m_data + blockOffset);
}


#endif	/* _QCTMMAP_H_ */

