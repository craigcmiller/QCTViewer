
#ifndef _GEOREF_H_
#define _GEOREF_H_

class GeoRef
{
public:
    GeoRef();
    ~GeoRef();
    double* getCoeffArray();
    void getDatumShift(double& north, double& east);
    void setDatumShift(double north, double east);

    enum {
        eas = 0,
        easY,
        easX,
        easYY,
        easXY,
        easXX,
        easYYY,
        easYYX,
        easYXX,
        easXXX,
        nor,
        norY,
        norX,
        norYY,
        norXY,
        norXX,
        norYYY,
        norYYX,
        norYXX,
        norXXX,
        lat,
        latX,
        latY,
        latXX,
        latXY,
        latYY,
        latXXX,
        latXXY,
        latXYY,
        latYYY,
        lon,
        lonX,
        lonY,
        lonXX,
        lonXY,
        lonYY,
        lonXXX,
        lonXXY,
        lonXYY,
        lonYYY
    };

    void imageToGeo(const int x, const int y, double& lambda, double& phi) const;
    void geoToImage(double lambda, double phi, int& x, int& y) const;

private:
    double m_coeff[40];
    double m_datumShiftNorth;
    double m_datumShiftEast;
};

#endif

