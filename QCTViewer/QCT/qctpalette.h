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

#ifndef _QCT_PALETTE_H_
#define _QCT_PALETTE_H_

#include "qctutil.h"

class QCT_API_EXPORT QctPalette
{
public:
    QctPalette();
    ~QctPalette();
    unsigned int* getPaletteData();

    inline void colourForIndex(const int index, unsigned char& r, unsigned char& g, unsigned char& b) const
    {
        const unsigned char* colour = reinterpret_cast<const unsigned char *>(&m_palette[index]);

        b = colour[0];
        g = colour[1];
        r = colour[2];
    }

    /**
     * Return -1 if no index exists that specifies a the specified colour
     */
    inline int indexForColour(const unsigned char r, const unsigned char g, const unsigned char b) const
    {
        for (int i = 0; i < 256; ++i) {
            const unsigned char* colour = reinterpret_cast<const unsigned char *>(&m_palette[i]);
            if (colour[0] == b && colour[1] == g && colour[2] == r)
                return i;
        }

        return -1;
    }

private:
    unsigned int m_palette[256];
};

#endif

