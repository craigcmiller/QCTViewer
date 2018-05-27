
#include "qctpalette.h"

QctPalette::QctPalette()
{
}
 

QctPalette::~QctPalette()
{
}


int* QctPalette::getPaletteData()
{
    return m_palette;
}


void QctPalette::colourForIndex(const int index, unsigned char& r, unsigned char& g, unsigned char& b) const
{
    const unsigned char* colour = reinterpret_cast<const unsigned char *>(&m_palette[index]);

    b = colour[0];
    g = colour[1];
    r = colour[2];
}


/**
 * Return -1 if no index exists that specifies a the specified colour
 */
int QctPalette::indexForColour(const unsigned char r, const unsigned char g, const unsigned char b) const
{
    for (int i = 0; i < 256; ++i) {
        const unsigned char* colour = reinterpret_cast<const unsigned char *>(&m_palette[i]);
        if (colour[0] == b && colour[1] == g && colour[2] == r)
            return i;
    }

    return -1;
}

