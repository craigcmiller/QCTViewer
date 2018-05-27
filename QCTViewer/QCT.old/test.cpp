
#include "qctmap.h"
#include <iostream>
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
    for (int y = 0; y < map.getNumYTiles(); ++y) {
        for (int x = 0; x < map.getNumXTiles(); ++x) {
            int* tile = map.readTile(x, y);
            delete[] tile;
        }
    }
	map.close();

	return 0;
}

