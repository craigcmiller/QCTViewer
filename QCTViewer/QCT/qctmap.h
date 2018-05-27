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

#ifndef _QCT_MAP_H_
#define _QCT_MAP_H_

#include "qctdata.h"
#include "georef.h"
#include "qctpalette.h"
#include "qcttilemgr.h"
#include "qctmmap.h"
#include "qctutil.h"

#include <string>

class QCT_API_EXPORT QctMap
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
    void setHuffmanPreload(const bool enabled) { m_tileMgr.setHuffmanPreload(enabled); }
    bool getHuffmanPreload() const { return m_tileMgr.getHuffmanPreload(); }

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
    mutable QctMemMap m_file;
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

