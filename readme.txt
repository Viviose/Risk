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

Version 1.5a

Project Name - Risk: Racket Edition

Included libraries, modules, and definitions files:
- "src" library contains ALL source code used in the game.
  - "imgs" library contains all images used in the game.
  - "bkup" library contains all back-up files for program files.
  - "fonts" library contains fonts used in by Racket to draw text with that font.
  - "sounds" library contains mp3 source files that can play during the game using rsound, an extension to Racket that is not yet implemented in Risk.
  - "testfiles" library contains programs that test functions not easily tested by check-expects.
  - "Map-Positions" library contains files that store the information of hitboxes used in territories in-game.
    - "map-positions.txt" contains a list of hitboxes for all territories.

  (Note: The "compiled" library is often created by the DrRacket Racket IDE when creating errortrace files, but is not tracked by the repository using .gitignore.)

  - "dice-functs.rkt" module contains functions to help simulate dice rolls during gameplay for things such as turn selection and attacks/defenses.
      - To require module: (require "dice-functs.rkt")
  - "graph.rkt" module contains functions that are used for animation purposes such as point comparisons.
      - To require module: (require "graph.rkt")
  - "ellipse.rkt" module provides important ellipse functions used for hitboxes and math throughout programs.
      - To require sub-module: (require "ellipse.rkt")
  - "hit-box-determiner.rkt" program allows hitboxes to be made for all territories in the game using ellipses, and outputs results to a file inside of Map-Positions lib.
  - "test-animations.rkt" contains tests for any animations thought to require tests outside of their host files.

To require particular files using the Racket language follows the syntax:
(require [String path])

To require a library follows the syntax:
(require [identifier lib-name])

To provide functions in Racket uses the syntax:
(provide function-name-1 ... function-name-x)

To provide a struct in Racket uses the syntax:
(provide (struct-out struct-id))

To provide all identifiers in a given file uses the syntax:
(provide (all-defined-out))

Images in the "imgs" library will be utilized with the bitmap function provided by Racket, with the syntax:
(bitmap [String path])
These images will be defined as global variables in the source code that they are used in.

*** INSTALL ***
Project is using GitHub repository: https://github.com/Viviose/Risk.git
Persons interested in being an official member of this team can contact the developers at any time for more information. This will allow users read and write access to the repo at any time.
Anyone that wishes to contribute anything to this project can fork the project and create a pull request that will be reviewed before implementation.
Game files can be downloaded into any folder with any path, but to be updated remotely, they must have Git initialized in said folder.
The best way to do this is to clone the repo using Git with the following command:

git clone https://github.com/Viviose/Risk.git

The home page for the project can be found at: https://github.com/Viviose/Risk

*** AUTHORS ***
Joshua Sanchez & Patrick "Patty G" Gallagher

*** PROJECT MANAGEMENT FEATURES ***
Bugs should be reported at: https://github.com/Viviose/Risk/issues
Wiki can be found at: https://github.com/Viviose/Risk/wiki

*** CONTACT ***
Josh Sanchez (Project Manager and Head Programmer)
- E-mail: joshuaesanch@gmail.com
- Phone Number: +1(773)499-5535

Patty G (Head Programmer)
- E-mail: pghahaha@cpgallagher.com
- Phone Number: +1(312)493-5743
