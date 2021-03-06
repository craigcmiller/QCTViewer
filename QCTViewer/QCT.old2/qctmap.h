#ifndef _QCT_MAP_H_
#define _QCT_MAP_H_

#include "qctdata.h"
#include "georef.h"
#include "qctpalette.h"
#include "qcttilemgr.h"

#include <string>
#include <fstream>

class QctMap
{
public:
    QctMap();
    ~QctMap();
    void open(const std::string& path);
    void read();
    void close();
    int getNumXTiles() const;
    int getNumYTiles() const;
    void setFactor(const unsigned int factor) { m_tileMgr.setFactor(factor); }

    template <typename T>
    void readTile(const int tileX, const int tileY, T* tileBytes) const;

    void imageToGeo(const int x, const int y, double& lambda, double& phi) const;
    void geoToImage(const double lambda, const double phi, int& x, int& y) const;

    unsigned int* getPaletteData() { return m_palette.getPaletteData(); }

private:
    static inline void swapGeneric(char *buffer, int numBytes, int numItems);
    static inline int swapInt32(int x);
    static inline short swapInt16(short x);

private:
    bool m_bigEndian;
    mutable std::fstream m_file;
    size_t m_fileSize;
    double *m_outlineLatitudes;
    double *m_outlineLongitudes;
    int *m_imageOffsets; // Tile index: width x height x sizeof(int)
    QctMetaData m_metaData;
    QctExtendedData m_extendedData;
    GeoRef m_geoRef;
    QctPalette m_palette;
    QctTileMgr m_tileMgr;
};

#endif

