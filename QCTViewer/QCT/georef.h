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

#ifndef _GEOREF_H_
#define _GEOREF_H_

#include "qctutil.h"

class QCT_API_EXPORT GeoRef
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

