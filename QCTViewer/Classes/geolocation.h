/*
 *  geolocation.h
 *  iQct
 *
 *  Created by craig on 9/19/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

class GeoLocation
{
private:
	double _latitude;
	double _longitude;
	double _altitude;
	float _speed;
	float _direction;
	
public:
	GeoLocation(double latitude, double longitude);
	~GeoLocation();
	
	double getLatitude();
	double getLongitude();
};
