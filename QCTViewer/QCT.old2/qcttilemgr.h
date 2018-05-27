
#ifndef _QCT_TILE_H_
#define _QCT_TILE_H_

#include "qctdata.h"
#include <fstream>

class QctPalette;

typedef struct CodeBookEntry {
    int offset; // offset in codebook, or -1 for not set (ie. is a colour)
    int sz;
    unsigned char colourIndex; // colour index in main palette, or -1 if not sent (ie. is a branch)
} CodebookEntry;

class QctTileMgr
{
public:
    QctTileMgr();
    ~QctTileMgr();
    void setMetaData(QctMetaData* metaData);
    void setPalette(QctPalette* palette);
    int* newImageIndex();
    int getIndexCount() const;
    void setFactor(const unsigned int factor);

    template <typename T>
    void readTile(const int tileX, const int tileY, std::fstream& openFile, int fileSize, T* tileBytes) const;

private:
    void deinterlacerInit();
    inline unsigned char scanLineIndex(const unsigned char y) const;
    inline int getTileOffset(const int tileX, const int tileY) const;
    void rleDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, const unsigned int fileSize) const;
    static inline unsigned char makeMsbMask(const unsigned int nBits);
    void huffmanDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, const unsigned int fileSize) const;
    void pixelPackDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, const unsigned int fileSize) const;
    static inline int swapInt32(int x);

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
};

#endif

