
#include "qcttilemgr.h"
#include "qctpalette.h"
#include "qctdata.h"

#include <cmath>
#include <cstring>
#include <iostream>

template void QctTileMgr::readTile<unsigned char>(const int tileX, const int tileY, std::fstream& openFile, int fileSize, unsigned char* tileBytes) const;
template void QctTileMgr::readTile<unsigned int>(const int tileX, const int tileY, std::fstream& openFile, int fileSize, unsigned int* tileBytes) const;


QctTileMgr::QctTileMgr()
  : m_imageIndex(0)
  , m_factor(1)
  , m_nLinesPerTile(64)
  , m_nBytesPerTile(4096)
{
    deinterlacerInit();
    m_palettedTile = new unsigned char[4096];
}


QctTileMgr::~QctTileMgr()
{
    delete[] m_imageIndex;
    delete[] m_palettedTile;
}


void QctTileMgr::setMetaData(QctMetaData* metaData)
{
    m_metaData = metaData;
}


void QctTileMgr::setPalette(QctPalette* palette)
{
    m_palette = palette;
}


int* QctTileMgr::newImageIndex()
{
    m_indexCount = m_metaData->width_tiles * m_metaData->height_tiles;
    m_imageIndex = new int[m_indexCount];
    return m_imageIndex;
}


int QctTileMgr::getIndexCount() const
{
    return m_indexCount;
}


/**
 * Use image index to lookup a tile 'file offset'
 */
inline int QctTileMgr::getTileOffset(const int tileX, const int tileY) const
{
    return m_imageIndex[m_metaData->width_tiles * tileY + tileX];
}


void QctTileMgr::setFactor(const unsigned int factor)
{
    m_factor = factor;
    m_nLinesPerTile = 64 / factor;
    m_nBytesPerTile = 64 * m_nLinesPerTile;
}


/**
 * Read a tile into the buffer provided (tileBytes)
 */
template <typename T>
void QctTileMgr::readTile(const int tileX, const int tileY, std::fstream& openFile, int fileSize, T* tileBytes) const
{
    // Caution, decompressed tiles are interlaced in a strange order to allow partial decompression for 'zoom out' scale factors
    unsigned char subpaletteColours = 0;

    openFile.seekg(getTileOffset(tileX, tileY), std::ios::beg);
    openFile.read(reinterpret_cast<char *>(&subpaletteColours), sizeof(unsigned char));

    // Use the appropriate decoder for the current tile type
    if (subpaletteColours == 0 || subpaletteColours == 255) // huffman
        huffmanDecode(subpaletteColours, m_palettedTile, openFile, fileSize);
    else if (subpaletteColours > 127) // pixel packed
        pixelPackDecode(256 - subpaletteColours, m_palettedTile, openFile, fileSize);
    else // run length
        rleDecode(subpaletteColours, m_palettedTile, openFile, fileSize);

    // Deinterlace tile scan lines here, and convert to RGB
    for (unsigned int x = 0, dstX = 0; x < 64; x += m_factor, ++dstX) {
        for (unsigned int y = 0; y < m_nLinesPerTile; ++y) {
            unsigned char realScanlineIndex = scanLineIndex(y);
            realScanlineIndex /= m_factor;
            
            unsigned int srcOffset = 64 * y + x;
            unsigned int dstOffset = m_nLinesPerTile * realScanlineIndex + dstX;
            //std::cout << "x: " << x << " y: " << y << " realY: " << ((int)realScanlineIndex) << std::endl;
            /*switch (pixelFormat) {
                case PIXEL_FORMAT_RGB32:
                    m_palette->colourForIndex(m_palettedTile[srcOffset], r, g, b);
                    static_cast<unsigned int *>(tileBytes)[dstOffset] = (0xff << 24) + (r << 16) + (g << 8) + (b); // ARGB32 or RGB32 pixel format
                    break;
                case PIXEL_FORMAT_INDEXED:
                    static_cast<unsigned char *>(tileBytes)[dstOffset] = m_palettedTile[srcOffset];
                    break;
            }*/
            formatPixel<T>(srcOffset, dstOffset, tileBytes);
        }
    }
}


/**
 * Specialisation for paletted data
 */
template <>
inline void QctTileMgr::formatPixel(const unsigned int srcOffset, const unsigned int dstOffset, unsigned char* tileBytes) const
{
    tileBytes[dstOffset] = m_palettedTile[srcOffset];
}


/**
 * Specialisation for RGB32 data
 */
template <>
inline void QctTileMgr::formatPixel(const unsigned int srcOffset, const unsigned int dstOffset, unsigned int* tileBytes) const
{
    unsigned char r, g, b;
    m_palette->colourForIndex(m_palettedTile[srcOffset], r, g, b);
    tileBytes[dstOffset] = (0xff << 24) + (r << 16) + (g << 8) + (b); // ARGB32 or RGB32 pixel format
}


void QctTileMgr::deinterlacerInit()
{
    const unsigned char powers[6] = { 1, 2, 4, 8, 16, 32 };
    int row = 0;

    for (unsigned int y = 0; y < 64; ++y) {
        unsigned int r = 0;
        for (unsigned int i = 0; i < 6; ++i) {
            if (y & powers[i]) // bit is set
                r |= powers[5 - i];
        }
        m_deinterlacerMap[row++] = r;
    }
}


/**
 * Test which bits are set, then create a new index in reverse order as per specification
 */
inline unsigned char QctTileMgr::scanLineIndex(const unsigned char y) const
{
    return m_deinterlacerMap[y];
}


/**
 * Decompress an RLE compressed tile
 * Since the size of RLE data is not known 'up front', this code will prefetch blocks of 64-bytes (or remainder of file, if 64 bytes are not available)
 */
void QctTileMgr::rleDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, const unsigned int fileSize) const
{
    unsigned char subpalette[subPaletteSize]; // list of indexes into main palette that are used for this data
    static const unsigned int chunkSize = 256;
    unsigned char buffer[chunkSize]; // small buffer - read in chunks, checking if the total size has been reached
    unsigned int nBitsRepCnt = 0;
    unsigned int nBitsColourIdx = 0;
    unsigned int bytesRead = 0;
 
    // work right to left, until find first bit set. this gives us number of bits required for sub palette index
    unsigned char pwr = 1;
    for (unsigned int i = 0; i < 8; ++i) {
        if ((subPaletteSize - 1) & pwr) // furthest left bit that is set determines how many bits are required for sub-palette
            nBitsColourIdx = i + 1;
        pwr <<= 1;
    }

    nBitsRepCnt = 8 - nBitsColourIdx; // remaining bits are used for the colour value

    // read the subpalette 
    openFile.read(reinterpret_cast<char *>(&subpalette), subPaletteSize); // load subpalette

    unsigned char msbMask = makeMsbMask(nBitsRepCnt);

    // run length decoder
    do {
        unsigned int currentOffset = openFile.tellg();
        unsigned int bytesToRead = (currentOffset + chunkSize >= fileSize ? fileSize - currentOffset : chunkSize); // read chunkSize bytes, or whatever's left, if this would exceeed EOF
        openFile.read(reinterpret_cast<char *>(buffer), bytesToRead);

        for (unsigned int i = 0; i < bytesToRead; ++i) {
            unsigned char repCnt = buffer[i] >> nBitsColourIdx;
            unsigned char subpaletteIndex = buffer[i] & ~msbMask; // mask most significant bits that form colour index
            unsigned char mainPaletteColour = subpalette[subpaletteIndex];
            for (unsigned int j = 0; j < repCnt && bytesRead < m_nBytesPerTile; ++j)
                tile[bytesRead++] = mainPaletteColour;
        }
    } while (bytesRead < m_nBytesPerTile);
}


// static
inline unsigned char QctTileMgr::makeMsbMask(const unsigned int nBits)
{
    static const unsigned char powers[8] = { 128, 64, 32, 16, 8, 4, 2, 1 };
    unsigned char v = 0;

    for (unsigned int i = 0; i < nBits; ++i)
        v |= powers[i];

    return v;
}


/*
void QctTileMgr::test() const
{
    unsigned char testcase[] = { 0xf7, 0xff, 0x54, 0xff, 0x34, 0xff, 0x1d, 0xff, 0x53, 0x2f, 0x1b, 0xac, 0x4f, 0xd5, 0x10, 0x00, 0x29 };
    unsigned char tile[4096];
    std::fstream file;

    std::cout << "TEST" << std::endl;

    file.open("test.dat", std::fstream::in | std::fstream::out | std::fstream::binary | std::fstream::trunc);
    file.write(reinterpret_cast<char *>(testcase), 17);
    file.seekg(0, std::ios::beg);

    huffmanDecode(0, tile, file, 17);
    file.close();
}
*/


void QctTileMgr::huffmanDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, const unsigned int fileSize) const
{
    unsigned int nColours = 0; // number of colours
    unsigned int nBranches = 0; // number of branches
    CodebookEntry codebook[256];
    static const int chunkSize = 256;
    unsigned char buffer[chunkSize + 2]; // extra 2 bytes allocated, so that if a long jump is encountered at the end of the block, it can be fetched
    unsigned int startOffset = openFile.tellg(); // keep track of offset at start of codebook
    unsigned int bytesRead = 0;
    unsigned int codebookSize = 0;

    // read the Huffman codebook
    do {
        unsigned int currentOffset = startOffset + bytesRead;
        unsigned int bytesToRead = (currentOffset + chunkSize >= fileSize ? fileSize - currentOffset : chunkSize);

        openFile.read(reinterpret_cast<char *>(buffer), bytesToRead);

        for (unsigned int i = 0; i < bytesToRead && nColours <= nBranches; ++i) {
            CodeBookEntry& entry = codebook[codebookSize];
            if (buffer[i] < 128) { // is colour
                entry.offset = -1;
                entry.colourIndex = buffer[i];
                entry.sz = 1;
                ++nColours;
                ++bytesRead; // increment processed byte count
                ++codebookSize;
            } else if (buffer[i] > 128) { // near branch
                unsigned int jump = 257 - (unsigned int)buffer[i];
                entry.colourIndex = 0;
                entry.offset = jump;
                entry.sz = 1;
                ++nBranches;
                ++bytesRead; // increment processed byte count
                ++codebookSize;
            } else { // far branch (== 128)
                if (i + 2 >= bytesToRead) // overlength by 2 - read the characters needed to complete this branch
                    openFile.read(reinterpret_cast<char *>(&buffer[chunkSize]), 2);
                else if (i + 1 >= bytesToRead) // overlength by only 1 - read the characters needed to complete this branch
                    openFile.read(reinterpret_cast<char *>(&buffer[chunkSize]), 1);
                unsigned int jump = 65537 - (256 * static_cast<unsigned int>(buffer[i + 2]) + static_cast<int>(buffer[i + 1])) + 2;
                entry.colourIndex = 0;
                entry.offset = jump;
                entry.sz = 3;
                ++nBranches;
                i += 2; // force loop counter forward by extra two bytes for long branch
                bytesRead += 3; // increment processed byte count
                // in codebook, only the first entry is actually USED, but for the jumps to point to the correct place, must put some placeholders in
                codebookSize += 3;
            }
        }
    } while (nColours <= nBranches);

    // If no branches exist in the codebook, the whole tile should just be flood filled with the colour from the root
    if (nBranches == 0) {
        if (nColours)
            std::memset(tile, codebook[0].colourIndex, m_nBytesPerTile);
        return;
    }

    unsigned int dataOffset = startOffset + bytesRead; // file offset at which data beings
    openFile.seekg(dataOffset, std::ios::beg); // seek to start of compressed data

    // Parse codebook, and make sure all jumps are to locations within the codebook.
    // If not, fix the jumps to point to the last colour, or similar
    for (unsigned int i = 0; i < codebookSize; ) {
        CodeBookEntry& entry = codebook[i];
        if (entry.offset != -1 && entry.offset + i >= codebookSize) {
            std::cout << "Huffman table - invalid offset in codebook: " << entry.offset << std::endl;
            entry.offset = codebookSize - 1;
        }
        i += entry.sz;
    }

    // Decode Huffman compressed data stream
    unsigned int pixelsDrawn = 0;
    unsigned char dstream[chunkSize];
    unsigned int codebookPtr = 0; // current position in the codebook - reset after ever leaf
    do {
        unsigned int currentOffset = openFile.tellg();
        unsigned int bytesToRead = (currentOffset + chunkSize >= fileSize ? fileSize - currentOffset : chunkSize);
        openFile.read(reinterpret_cast<char *>(dstream), bytesToRead);
        for (unsigned int i = 0; i < bytesToRead; ++i) {
            unsigned char byte = dstream[i];
            for (int i = 0; i < 8 && pixelsDrawn < m_nBytesPerTile; ) { // deal with each individual bit in the byte
                unsigned char set = byte & 0x01;
                CodeBookEntry& entry = codebook[codebookPtr];
                if (entry.offset == -1) {
                    tile[pixelsDrawn++] = entry.colourIndex;
                    codebookPtr = 0; // reset code book pointer
                } else {
                    if (set) { // take branch
                        codebookPtr += entry.offset; // codebook pointer is incremented by offset to branch
                    } else { // do not take branch - just continue to next entry in codebook
                        codebookPtr += entry.sz;
                    }
                    if (codebookPtr >= codebookSize) { // check for corrupt data stream
                        codebookPtr = codebookSize - 1; // if outside range, clamp to max in palette - better than nothing, but not right
                        std::cout << "offset outside bounds: " << entry.offset << " - Will try to continue..." << std::endl;
                    }
                    byte >>= 1; // shift right 1 bit, ready to use next bit
                    ++i;
                }
            }
        }
    } while (pixelsDrawn < m_nBytesPerTile);
}


void QctTileMgr::pixelPackDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, const unsigned int fileSize) const
{
    unsigned char subpalette[subPaletteSize];
    unsigned int nBitsPerPixel = 0;

    // load subpalette for this tile
    openFile.read(reinterpret_cast<char *>(&subpalette), subPaletteSize); // load subpalette

    // work right to left, until find first bit set. this gives us number of bits required to represent all possible colours in sub-palette
    unsigned char pwr = 1;
    for (unsigned int i = 0; i < 8; ++i) {
        if ((subPaletteSize - 1) & pwr) // furthest left bit that is set determines how many bits are required for addressing each colour in the palette
            nBitsPerPixel = i + 1;
        pwr <<= 1;
    }

    unsigned int nPixelsPerDataWord = 32 / nBitsPerPixel; // any bits that are not an exact multiple are unused
    unsigned int nDataWordsForTile = m_nBytesPerTile / nPixelsPerDataWord;

    if (m_nBytesPerTile % nPixelsPerDataWord != 0)
        ++nDataWordsForTile;

    unsigned char buffer[nDataWordsForTile * sizeof(unsigned int)];

    // Read pixel data
    openFile.read(reinterpret_cast<char *>(buffer), nDataWordsForTile * sizeof(unsigned int));

    unsigned int pixelsDrawn = 0;

    // mask for current pixel colour that is being read
    unsigned int mask = (static_cast<unsigned int>(std::pow(2.0f, (float)nBitsPerPixel)) - 1);

    for (unsigned int i = 0; i < nDataWordsForTile; ++i) {
        unsigned char* bufByts = &buffer[i * sizeof(unsigned int)];
        unsigned int word = (static_cast<unsigned int>(bufByts[0])) |
                            (static_cast<unsigned int>(bufByts[1]) << 8) |
                            (static_cast<unsigned int>(bufByts[2]) << 16) |
                            (static_cast<unsigned int>(bufByts[3]) << 24); // data is packed into blocks of 4 bytes
        for (unsigned int px = 0; px < nPixelsPerDataWord && pixelsDrawn < m_nBytesPerTile; ++px) {
            unsigned char subpaletteIndex = word & mask;
            tile[pixelsDrawn++] = subpalette[subpaletteIndex];
            word >>= nBitsPerPixel; // shift all data right, ready for next pixel
        }
    }
}

