
#include "qctmap.h"
#include <iostream>
#include <sys/time.h>
#include <cstdio>

int main(int argc, char **argv)
{
    QctMap map;

    if (argc < 2) {
        std::cout << "Must specify map name." << std::endl;
        return 1;
    }

	map.open(argv[1]);
	map.read();
	std::cout << "Number of tiles in X direction: " << map.getNumXTiles() << std::endl;
	std::cout << "Number of tiles in Y direction: " << map.getNumYTiles() << std::endl;

    struct timeval tstart, tend;
    struct timezone tzone;
    tzone.tz_minuteswest = 0;
    tzone.tz_dsttime = 0;

    gettimeofday(&tstart, &tzone); // man page contradicts itself, as to whether it is safe to specify 2nd argument as NULL - pretty poor

    unsigned int* tile = new unsigned int[4096];
    for (unsigned int y = 0; y < map.getNumYTiles(); ++y) {
        for (unsigned int x = 0; x < map.getNumXTiles(); ++x) {
            map.readTile<unsigned int>(x, y, tile);
        }
    }
    
    gettimeofday(&tend, &tzone);

	map.close();
    delete[] tile;

    double tTotal = (tend.tv_sec + (tend.tv_usec * 1.0e-6)) - (tstart.tv_sec + (tstart.tv_usec * 1.0e-6));

    std::cout << "Total time (excluding read() of map): = " << tTotal << " seconds" << std::endl;

	return 0;
}

