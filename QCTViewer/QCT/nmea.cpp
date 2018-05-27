
#include <cstring>
#include "nmea.h"

NmeaParser::NmeaParser()
{
}


NmeaParser::~NmeaParser()
{
}


void NmeaParser::parseLine(const char* line)
{
    int i = 0;
    char verb[32];

    // Determine operation
    while (*line && *line != ',' && i < 32) {
        verb[i++] = *line;
        ++line;
    }
    verb[i++] = 0;

    if (std::strcmp(verb, "$GPGGA") == 0) { // Fix data

    } else if (std::strcmp(verb, "$GPRMC") == 0) { // Minimum recommended data

    }
}

