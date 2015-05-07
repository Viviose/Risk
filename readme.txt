############      #######       ##########       #####     ######
#############     #######      ###########       #####    ######
####     #####    #######     #####              #####   ######
####     #####    #######     ######             #####  ######
####    ####      #######      ###########       ############
###########       #######       ###########      ############
#####  ######     #######             #####      ###### #######
#####   ######    #######            ######      ######  #######
#####    ######   #######     ###########        ######   #######
#####    ######   #######     ##########         ######    #######   
_________________________________________________________________________

Risk: The Game of World Domination
(Racket Edition)

Version 0.1

Project Name: Riskit
A combination of Risk and Racket, yeah?

Included libraries are imgs and src.
- "imgs" library contains all images used in the game.
- "src" library contains ALL source code used in the game.

To require particular files using the Racket language follows the syntax:
(require [String path])

To require a library follows the syntax:
(require [String lib-name])

To provide functions in Racket uses the syntax:
(provide [function-name-1 ... function-name-x])

To provide all functions in a given file uses the syntax:
(provide all-defined-out)

Images in the "imgs" library will be utilized with the bitmap function provided by Racket, with the syntax:
(bitmap [String path])
- These images will be defined as global variables in the source code that they are used in.




