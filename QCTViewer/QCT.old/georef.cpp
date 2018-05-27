
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
    lambda = (lonXXX * pow(x, 3)) + (lonXX * pow(x, 2)) + (lonX * x) +
             (lonYYY * pow(y, 3)) + (lonYY * pow(y, 2)) + (lonY * y) +
             (lonXXY * pow(x, 2) * y) + (lonXYY * pow(y, 2) * x) + (lonXY * x * y) +
             lon;

    phi = (latXXX * pow(x, 3)) + (latXX * pow(x, 2)) + (latX * x) +
          (latYYY * pow(y, 3)) + (latYY * pow(y, 2)) + (latY * y) +
          (latXXY * pow(x, 2) * y) + (latXYY * pow(y, 2) * x) + (latXY * x * y) +
          lat;

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
	
    y = (m_coeff[norXXX] * pow(lambda, 3.0)) + (m_coeff[norXX] * pow(lambda, 2)) + (m_coeff[norX] * lambda) +
	(m_coeff[norYYY] * pow(phi, 2.0)) + (m_coeff[norYY] * pow(phi, 2.0)) + (m_coeff[norY] * phi) +
	(m_coeff[norYXX] * pow(lambda, 2.0) * phi) + (m_coeff[norYYX] * pow(phi, 2.0) * lambda) + (m_coeff[norXY] * lambda * phi) +
	m_coeff[nor];
}


