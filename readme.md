# Oracle Spatial Functions
Although the Oracle `SDO_GEOMETRY` and `SDO_LRS` functions are very powerful, I have found basic spatial operations to be quite lacking. This repository is intended to be a cookbook
of scripts for performing basic actions on Points, Lines, and Polygons (gtypes 2001, 2002, and 2003 respectively).

These functions do not account for every type of geometry. Clean your data before adapting these scripts to your needs. The sdo_geometry object can be a real pain, and these scripts can
only hope to reduce that pain by so much.

Also, while it would be ideal for these functions to exist as object methods, objects require function creation rights on the database. Depending upon the nature of your role, you may
not have access to do this. Consequently, I have decided to write these as stand-alone functions that can be incorporated into any ad hoc PL/SQL block. Don't hate the player, hate the game.