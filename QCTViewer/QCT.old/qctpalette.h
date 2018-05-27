
#ifndef _QCT_PALETTE_H_
#define _QCT_PALETTE_H_

class QctPalette
{
public:
    QctPalette();
    ~QctPalette();
    int* getPaletteData();
    void colourForIndex(const int index, unsigned char& r, unsigned char& g, unsigned char& b) const;
    int indexForColour(const unsigned char r, const unsigned char g, const unsigned char b) const;

private:
    int m_palette[256];
};

#endif

