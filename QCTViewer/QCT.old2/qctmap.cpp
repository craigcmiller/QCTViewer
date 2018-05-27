
#include "qctmap.h"

#include <iostream>
#include <iomanip>

template void QctMap::readTile<unsigned char>(const int, const int, unsigned char*) const;
template void QctMap::readTile<unsigned int>(const int, const int, unsigned int*) const;


QctMap::QctMap()
{
    int one = 0x01;

    if (*reinterpret_cast<char *>(&one) == 0x01)
        m_bigEndian = false;
    else
        m_bigEndian = true;

    m_tileMgr.setMetaData(&m_metaData);
    m_tileMgr.setPalette(&m_palette);
}

 
QctMap::~QctMap()
{
}


void QctMap::open(const std::string& path)
{
    m_file.open(path.c_str(), std::fstream::in | std::fstream::binary);

    m_file.seekg(0, std::ios::end);
    m_fileSize = m_file.tellg();
    m_file.seekg(0, std::ios::beg);
}


void QctMap::read()
{
    // Read metadata from offset 0
    m_file.seekg(0x00, std::fstream::beg);
    m_file.read(reinterpret_cast<char *>(&m_metaData), sizeof(QctMetaData));

    if (m_bigEndian) { // must do 'up front', as require a valid (in native byte order) metadata to read image index
        for (size_t i = 0; i < sizeof(QctMetaData) / 4; ++i)
            *(reinterpret_cast<int *>(&m_metaData) + i) = swapInt32(*(reinterpret_cast<int *>(&m_metaData) + i));
    }

    // Read extended data
    m_file.seekg(m_metaData.extended_data, std::fstream::beg);
    m_file.read(reinterpret_cast<char *>(&m_extendedData), sizeof(QctExtendedData));

    if (m_bigEndian) {
        for (size_t i = 0; i < sizeof(QctExtendedData) / 4; ++i)
            *(reinterpret_cast<int *>(&m_extendedData) + i) = swapInt32(*(reinterpret_cast<int *>(&m_extendedData) + i));
    }

    // Read datum shift array
    double datumShift[2];
    m_file.seekg(m_extendedData.offset_datum_shift, std::fstream::beg);
    m_file.read(reinterpret_cast<char *>(datumShift), sizeof(double) * 2);
    
    if (m_bigEndian)
        swapGeneric(reinterpret_cast<char *>(datumShift), sizeof(double), 2);

    m_geoRef.setDatumShift(datumShift[0], datumShift[1]);

    // Read Geographical Referencing Coefficients
    double* geoCoeff = m_geoRef.getCoeffArray();
    m_file.seekg(0x0060, std::ios::beg);
    m_file.read(reinterpret_cast<char *>(geoCoeff), 40 * sizeof(double));

    // Byte swap, if necessary
    if (m_bigEndian)
        swapGeneric(reinterpret_cast<char *>(&geoCoeff), sizeof(double), 40);

    // Read image palette - never needs byte swapped
    unsigned int* paletteData = m_palette.getPaletteData();
    m_file.seekg(0x01a0, std::ios::beg);
    m_file.read(reinterpret_cast<char *>(paletteData), 256 * sizeof(int));

    // Read image index - gets image dimensions from meta data
    int* imageIndex = m_tileMgr.newImageIndex();
    m_file.seekg(0x45a0, std::ios::beg);
    m_file.read(reinterpret_cast<char *>(imageIndex), m_tileMgr.getIndexCount() * sizeof(int));
    
    // Byte swap the image index, if necessary
    if (m_bigEndian)
        swapGeneric(reinterpret_cast<char *>(&imageIndex), sizeof(int), m_tileMgr.getIndexCount());
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
    return m_tileMgr.readTile(tileX, tileY, m_file, m_fileSize, tileBytes);
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

