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

#ifndef _QCTDATA_H_
#define _QCTDATA_H_

typedef struct {
    int magic_number;      // 0x1423d5fe quick chart, 0x1423d5ff quick chart map
    int format_version;    // integer - file format version
    int width_tiles;       // integer width in tiles
    int height_tiles;      // integer height in tiles
    int offset_long_title; // offset to string
    int offset_name;       // offset to string
    int offset_identifier;
    int offset_edition;
    int offset_revision;
    int offset_keywords;
    int offset_copyright;
    int offset_scale;
    int offset_datum;
    int offset_depths;
    int offset_heights;
    int offset_projection;
    int flags;                     // integer bit field
    int offset_orig_filename;      // pointer to string - orginal filename
    int orig_filesize;             // integer
    int orig_filetime;             // integer - seconds since epoch
    int reserved;                  // integer - reserved - set to zero
    int extended_data;             // offset to extended data structure
    int num_outine_points;         // integer - number of map outline points
    int offset_map_outline_points; // offset to map outline array
} QctMetaData;


typedef struct {
    int offset_map_type;    // offset to string
    int offset_datum_shift; // offset to datum shift array
    int offset_disk_name;   // offset to string
    int reserved0;
    int reserved1;
    int serial_number;      // optional
    int reserved3;
    int reserved4;
} QctExtendedData;

#endif

