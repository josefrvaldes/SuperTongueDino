##-----------------------------LICENSE NOTICE------------------------------------
##  This file is part of CPCtelera: An Amstrad CPC Game Engine 
##  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)  modified by Carlos de la Fuente / Jose Martinez / Jose Francisco Valdes / (@clover_gs)
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Lesser General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##------------------------------------------------------------------------------
############################################################################
##                        CPCTELERA ENGINE                                ##
##                 Automatic compression utilities                        ##
##------------------------------------------------------------------------##
## This file is intended for users to automate the generation of          ##
## compressed files and their inclusion in users' projects.               ##
############################################################################

## COMPRESSION EXAMPLE (Uncomment lines to use)
##

## First 3 calls to ADD2PACK add enemy, hero and background
## graphics (previously converted to binary data) into the 
## compressed group 'mygraphics'. After that, call to PACKZX7B
## compresses all the data and generates an array with the result
## that is placed in src/mygraphics.c & src/mygraphics.h, ready
## to be included and used by other modules.
##
#$(eval $(call ADD2PACK,mygraphics,gfx/enemy.bin))
#$(eval $(call ADD2PACK,mygraphics,gfx/hero.bin))
#$(eval $(call ADD2PACK,mygraphics,gfx/background.bin))
#$(eval $(call PACKZX7B,mygraphics,src/))

# creamos paquetes
$(eval $(call ADD2PACK,level00_pack,src/tilesets/level00.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level01_pack,src/tilesets/level01.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level02_pack,src/tilesets/level02.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level03_pack,src/tilesets/level03.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level04_pack,src/tilesets/level04.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level05_pack,src/tilesets/level05.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level06_pack,src/tilesets/level06.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level07_pack,src/tilesets/level07.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level08_pack,src/tilesets/level08.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level09_pack,src/tilesets/level09.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level10_pack,src/tilesets/level10.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level11_pack,src/tilesets/level11.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level12_pack,src/tilesets/level12.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level13_pack,src/tilesets/level13.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level14_pack,src/tilesets/level14.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level15_pack,src/tilesets/level15.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level16_pack,src/tilesets/level16.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level17_pack,src/tilesets/level17.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level18_pack,src/tilesets/level18.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level19_pack,src/tilesets/level19.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level20_pack,src/tilesets/level20.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level21_pack,src/tilesets/level21.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level22_pack,src/tilesets/level22.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level23_pack,src/tilesets/level23.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level24_pack,src/tilesets/level24.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level25_pack,src/tilesets/level25.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level26_pack,src/tilesets/level26.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level27_pack,src/tilesets/level27.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level28_pack,src/tilesets/level28.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level29_pack,src/tilesets/level29.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level30_pack,src/tilesets/level30.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level31_pack,src/tilesets/level31.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level32_pack,src/tilesets/level32.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level33_pack,src/tilesets/level33.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level34_pack,src/tilesets/level34.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level35_pack,src/tilesets/level35.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level36_pack,src/tilesets/level36.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level37_pack,src/tilesets/level37.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level38_pack,src/tilesets/level38.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level39_pack,src/tilesets/level39.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level40_pack,src/tilesets/level40.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level41_pack,src/tilesets/level41.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level42_pack,src/tilesets/level42.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level43_pack,src/tilesets/level43.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level44_pack,src/tilesets/level44.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level45_pack,src/tilesets/level45.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level46_pack,src/tilesets/level46.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level47_pack,src/tilesets/level47.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level48_pack,src/tilesets/level48.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level49_pack,src/tilesets/level49.bin)) # este es el tilemap, es decir, el tmx importado de tiled
$(eval $(call ADD2PACK,level50_pack,src/tilesets/level50.bin)) # este es el tilemap, es decir, el tmx importado de tiled

$(eval $(call ADD2PACK,tileset_juego_pack,src/tilesets/tileset_juego.bin)) # este es el tileset, es decir, el png con los tiles base

$(eval $(call ADD2PACK,menu_principal_pack,src/tilesets/menu_principal.bin)) # este es el tileset, es decir, el png con los tiles base
$(eval $(call ADD2PACK,menu_you_win_pack,src/tilesets/menu_you_win.bin)) # este es el tileset, es decir, el png con los tiles base
$(eval $(call ADD2PACK,menu_ingame_pack,src/tilesets/menu_ingame.bin)) # este es el tileset, es decir, el png con los tiles base

# comprimimos
$(eval $(call PACKZX7B,level00_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level01_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level02_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level03_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level04_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level05_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level06_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level07_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level08_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level09_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level10_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level11_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level12_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level13_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level14_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level15_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level16_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level17_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level18_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level19_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level20_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level21_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level22_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level23_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level24_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level25_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level26_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level27_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level28_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level29_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level30_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level31_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level32_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level33_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level34_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level35_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level36_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level37_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level38_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level39_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level40_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level41_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level42_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level43_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level44_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level45_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level46_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level47_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level48_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level49_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,level50_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,tileset_juego_pack,src/tilesets/compressed))

$(eval $(call PACKZX7B,menu_principal_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,menu_you_win_pack,src/tilesets/compressed))
$(eval $(call PACKZX7B,menu_ingame_pack,src/tilesets/compressed))



############################################################################
##              DETAILED INSTRUCTIONS AND PARAMETERS                      ##
##------------------------------------------------------------------------##
##                                                                        ##
## Macros used for compression are ADD2PACK and PACKZX7B:                 ##
##                                                                        ##
##	ADD2PACK: Adds files to packed (compressed) groups. Each call to this ##
##  		  macro will add a file to a named compressed group.          ##
##  PACKZX7B: Compresses all files in a group into a single binary and    ##
##            generates a C-array and a header to comfortably use it from ##
##            inside your code.                                           ##
##                                                                        ##
##------------------------------------------------------------------------##
##                                                                        ##
##  $(eval $(call ADD2PACK,<packname>,<file>))                            ##
##                                                                        ##
##		Sequentially adds <file> to compressed group <packname>. Each     ##
## call to this macro adds a new <file> after the latest one added.       ##
## packname could be any valid C identifier.                              ##
##                                                                        ##
##  Parameters:                                                           ##
##  (packname): Name of the compressed group where the file will be added ##
##  (file)    : File to be added at the end of the compressed group       ##
##                                                                        ##
##------------------------------------------------------------------------##
##                                                                        ##
##  $(eval $(call PACKZX7B,<packname>,<dest_path>))                       ##
##                                                                        ##
##		Compresses all files in the <packname> group using ZX7B algorithm ##
## and generates 2 files: <packname>.c and <packname>.h that contain a    ##
## C-array with the compressed data and a header file for declarations.   ##
## Generated files are moved to the folder <dest_path>.                   ##
##                                                                        ##
##  Parameters:                                                           ##
##  (packname) : Name of the compressed group to use for packing          ##
##  (dest_path): Destination path for generated output files              ##
##                                                                        ##
############################################################################
##                                                                        ##
## Important:                                                             ##
##  * Do NOT separate macro parameters with spaces, blanks or other chars.##
##    ANY character you put into a macro parameter will be passed to the  ##
##    macro. Therefore ...,src/sprites,... will represent "src/sprites"   ##
##    folder, whereas ...,  src/sprites,... means "  src/sprites" folder. ##
##  * You can omit parameters by leaving them empty.                      ##
##  * Parameters (4) and (5) are optional and generally not required.     ##
############################################################################
