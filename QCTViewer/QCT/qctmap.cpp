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
 */

#include "qctmap.h"

#include <iostream>
#include <iomanip>
#include <cstring>


template QCT_API_EXPORT void QctMap::readTile<unsigned char>(const int, const int, unsigned char*) const;
template QCT_API_EXPORT void QctMap::readTile<unsigned int>(const int, const int, unsigned int*) const;


QctMap::QctMap()
{
    int one = 0x01;

    if (*reinterpret_cast<char *>(&one) == 0x01)
        m_bigEndian = false;
    else
        m_bigEndian = true;

    m_tileMgr.setMetaData(&m_metaData);
    m_tileMgr.setPalette(&m_palette);
    m_tileMgr.setFile(&m_file);
}

 
QctMap::~QctMap()
{
}


void QctMap::open(const std::string& path)
{
    m_file.open(path.c_str());
}


void QctMap::read()
{
    // Read metadata from offset 0
    std::memcpy(&m_metaData, m_file.getDataPtr(0x00), sizeof(QctMetaData));

    if (m_bigEndian) { // must do 'up front', as require a valid (in native byte order) metadata to read image index
        for (size_t i = 0; i < sizeof(QctMetaData) / 4; ++i)
            *(reinterpret_cast<int *>(&m_metaData) + i) = swapInt32(*(reinterpret_cast<int *>(&m_metaData) + i));
    }

    // Read extended data
    std::memcpy(&m_extendedData, m_file.getDataPtr(m_metaData.extended_data), sizeof(QctExtendedData));

    if (m_bigEndian) {
        for (size_t i = 0; i < sizeof(QctExtendedData) / 4; ++i)
            *(reinterpret_cast<int *>(&m_extendedData) + i) = swapInt32(*(reinterpret_cast<int *>(&m_extendedData) + i));
    }

    // Read datum shift array
    double datumShift[2];
    std::memcpy(datumShift, m_file.getDataPtr(m_extendedData.offset_datum_shift), sizeof(double) * 2);
    
    if (m_bigEndian)
        swapGeneric(reinterpret_cast<char *>(datumShift), sizeof(double), 2);

    m_geoRef.setDatumShift(datumShift[0], datumShift[1]);

    // Read Geographical Referencing Coefficients
    double* geoCoeff = m_geoRef.getCoeffArray();
    std::memcpy(geoCoeff, m_file.getDataPtr(0x0060), 40 * sizeof(double));

    // Byte swap, if necessary
    if (m_bigEndian)
        swapGeneric(reinterpret_cast<char *>(&geoCoeff), sizeof(double), 40);

    // Read image palette - never needs byte swapped
    unsigned int* paletteData = m_palette.getPaletteData();
    std::memcpy(paletteData, m_file.getDataPtr(0x01a0), 256 * sizeof(int));

    // Read image index - gets image dimensions from meta data
    int* imageIndex = m_tileMgr.newImageIndex();
    std::memcpy(imageIndex, m_file.getDataPtr(0x45a0), m_tileMgr.getIndexCount() * sizeof(int));
    
    // Byte swap the image index, if necessary
    if (m_bigEndian)
        swapGeneric(reinterpret_cast<char *>(&imageIndex), sizeof(int), m_tileMgr.getIndexCount());

    m_tileMgr.buildHuffmanTables();
}


void QctMap::close()
{
    m_file.close();
}


int QctMap::getNumXTiles() const
{
    return m_metaData.width_tiles;
}


int QctMap::getNumYTiles() const
{
    return m_metaData.height_tiles;
}


/**
 * Caller should free tile with delete[] <ptr>
 */
template <typename T>
void QctMap::readTile(const int tileX, const int tileY, T* tileBytes) const
{
    return m_tileMgr.readTile(tileX, tileY, tileBytes);
}


void QctMap::imageToGeo(const int x, const int y, double& lambda, double& phi) const
{
    m_geoRef.imageToGeo(x, y, lambda, phi);
}


void QctMap::geoToImage(const double lambda, const double phi, int& x, int& y) const
{
    m_geoRef.geoToImage(lambda, phi, x, y);
}


inline void QctMap::swapGeneric(char *buffer, int numBytes, int numItems)
{
    char tmp;
    int i, j;

    for (int cnt = 0; cnt < numItems; cnt++, buffer += numBytes) {
        for (i = 0, j = (numBytes - 1); i < numBytes / 2; i++, j--) {
            tmp = buffer[i];
            buffer[i] = buffer[j];
            buffer[j] = tmp;
        }
    }
}


inline int QctMap::swapInt32(int x)
{
    static const unsigned int M1 = 0xff000000, M2 = 0x00ff0000, M3 = 0x0000ff00;

    return ((unsigned int)x << 24) | (((unsigned int)x & M3) << 8) | (((unsigned int)x & M2) >> 8) | (((unsigned int)x & M1) >> 24);
}


inline short QctMap::swapInt16(short x)
{
    return ((unsigned short)x << 8) | (((unsigned short)x & 0xff00) >> 8);
}

