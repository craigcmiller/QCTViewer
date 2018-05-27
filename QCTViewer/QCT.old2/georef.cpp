
#include "georef.h"
#include <cmath>


GeoRef::GeoRef()
{
}


GeoRef::~GeoRef()
{
}


double* GeoRef::getCoeffArray()
{
    return m_coeff;
}


void GeoRef::getDatumShift(double& north, double& east)
{
    north = m_datumShiftNorth;
    east = m_datumShiftEast;
}


void GeoRef::setDatumShift(double north, double east)
{
    m_datumShiftNorth = north;
    m_datumShiftEast = east;
}


void GeoRef::imageToGeo(const int x, const int y, double& lambda, double& phi) const
{
    lambda = (m_coeff[lonXXX] * pow(x, 3.0)) + (m_coeff[lonXX] * pow(x, 2.0)) + (m_coeff[lonX] * x) +
             (m_coeff[lonYYY] * pow(y, 3.0)) + (m_coeff[lonYY] * pow(y, 2.0)) + (m_coeff[lonY] * y) +
             (m_coeff[lonXXY] * pow(x, 2.0) * y) + (m_coeff[lonXYY] * pow(y, 2.0) * x) + (m_coeff[lonXY] * x * y) +
             m_coeff[lon];

    phi = (m_coeff[latXXX] * pow(x, 3.0)) + (m_coeff[latXX] * pow(x, 2.0)) + (m_coeff[latX] * x) +
          (m_coeff[latYYY] * pow(y, 3.0)) + (m_coeff[latYY] * pow(y, 2.0)) + (m_coeff[latY] * y) +
          (m_coeff[latXXY] * pow(x, 2.0) * y) + (m_coeff[latXYY] * pow(y, 2.0) * x) + (m_coeff[latXY] * x * y) +
          m_coeff[lat];

    lambda += m_datumShiftEast;
    phi += m_datumShiftNorth;
}


void GeoRef::geoToImage(double lambda, double phi, int& x, int& y) const
{
    lambda -= m_datumShiftEast;
    phi -= m_datumShiftNorth;

    x = (m_coeff[easXXX] * pow(lambda, 3.0)) + (m_coeff[easXX] * pow(lambda, 2.0)) + (m_coeff[easX] * lambda) +
        (m_coeff[easYYY] * pow(phi, 3.0)) + (m_coeff[easYY] * pow(phi, 2.0)) + (m_coeff[easY] * phi) +
        (m_coeff[easYXX] * pow(lambda, 2.0) * phi) + (m_coeff[easYYX] * pow(phi, 2.0) * lambda) + (m_coeff[easXY] * lambda * phi) +
        m_coeff[eas];

    y = (m_coeff[norXXX] * pow(lambda, 3.0)) + (m_coeff[norXX] * pow(lambda, 2.0)) + (m_coeff[norX] * lambda) +
        (m_coeff[norYYY] * pow(phi, 3.0)) + (m_coeff[norYY] * pow(phi, 2.0)) + (m_coeff[norY] * phi) +
        (m_coeff[norYXX] * pow(lambda, 2.0) * phi) + (m_coeff[norYYX] * pow(phi, 2.0) * lambda) + (m_coeff[norXY] * lambda * phi) +
        m_coeff[nor];
}


