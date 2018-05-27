/*
 *  geolocation.cpp
 *  iQct
 *
 *  Created by craig on 9/19/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "geolocation.h"

GeoLocation::GeoLocation(double latitude, double longitude)
{
	_latitude=latitude;
	_longitude=longitude;
	
	_altitude=_speed=_direction=-1;
}

GeoLocation::~GeoLocation()
{
}

double GeoLocation::getLatitude()
{
	return _latitude;
}

double GeoLocation::getLongitude()
{
	return _longitude;
}
