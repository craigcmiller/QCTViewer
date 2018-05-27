#ifndef __NMEA_PARSER_H__
#define __NMEA_PARSER_H__

class NmeaParser
{
public:
    NmeaParser();
    ~NmeaParser();
    void parseLine(const char* line);

private:
    double m_lat;
    double m_lon;
};

#endif

