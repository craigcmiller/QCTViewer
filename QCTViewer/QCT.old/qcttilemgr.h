
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
    int* readTile(const int tileX, const int tileY, std::fstream& openFile, int fileSize) const;

private:
void test() const;
    inline unsigned char scanLineIndex(const unsigned char y) const;
    inline int getTileOffset(const int tileX, const int tileY) const;
    void rleDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, int fileSize) const;
    static unsigned char makeMsbMask(int nBits);
    void huffmanDecode(const unsigned char subPaletteSize, unsigned char* tile, std::fstream& openFile, int fileSize) const;

private:
    int* m_imageIndex;
    int m_indexCount;
    QctMetaData* m_metaData;
    QctPalette* m_palette;
};

#endif

