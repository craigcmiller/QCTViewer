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

#ifndef _QCT_TILE_H_
#define _QCT_TILE_H_

#include "qctdata.h"
#include "qctutil.h"

class QctPalette;

typedef struct CodeBookEntry {
    int offset; // offset in codebook, or -1 for not set (ie. is a colour)
    int sz;
    unsigned char colourIndex; // colour index in main palette, or -1 if not sent (ie. is a branch)
} CodebookEntry;

class QctMemMap;

class QCT_API_EXPORT QctTileMgr
{
public:
    QctTileMgr();
    ~QctTileMgr();
    void setMetaData(QctMetaData* metaData);
    void setPalette(QctPalette* palette);
    int* newImageIndex();
    int getIndexCount() const;
    void setFactor(const unsigned int factor);
    inline void setHuffmanPreload(const bool enabled) { m_enableHuffmanTablePreload = enabled; }
    inline bool getHuffmanPreload() const { return m_enableHuffmanTablePreload; }
    void buildHuffmanTables(); // probably should be private, and friend?
    inline void setFile(QctMemMap* file) { m_file = file; }

    template <typename T>
    void readTile(const int tileX, const int tileY, T* tileBytes) const;

private:
    void deinterlacerInit();
    inline unsigned char scanLineIndex(const unsigned char y) const;
    inline int getTileOffset(const int tileX, const int tileY, unsigned int& tileNumber) const;
    void rleDecode(const unsigned char subPaletteSize, unsigned char* tile, unsigned int offset) const;
    void huffmanDecode(const int tileNum, unsigned char* tile, unsigned int offset) const;
    void pixelPackDecode(const unsigned char subPaletteSize, unsigned char* tile, unsigned int offset) const;
    static inline int swapInt32(int x);
    unsigned int readCodebook(CodeBookEntry** codebookPtr, unsigned int startOffset) const;
    void freeHuffmanTables();

    template <typename T>
    inline void formatPixel(const unsigned int srcOffset, const unsigned int dstOffset, T* tileBytes) const;

private:
    int* m_imageIndex;
    int m_indexCount;
    QctMetaData* m_metaData;
    QctPalette* m_palette;
    unsigned char* m_palettedTile;
    unsigned char m_deinterlacerMap[64];
    unsigned int m_factor;
    unsigned int m_nLinesPerTile;
    unsigned int m_nBytesPerTile;
    CodeBookEntry** m_codeBooks;
    unsigned int* m_huffmanDataOffsets;
    int m_codeBookCount;
    bool m_enableHuffmanTablePreload;
    QctMemMap* m_file;
};

#endif

