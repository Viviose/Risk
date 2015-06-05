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

Version 0.1.9 

Project Name: Riskit
A combination of Risk and Racket, yeah?

Included libraries are imgs and src.
- "imgs" library contains all images used in the game.
- "src" library contains ALL source code used in the game.
  - "bkup" library contains all back-up files for program files.
  - "compiled" library contains error-trace files used by Racket.
  - "testfiles" library contains programs that test functions not easily tested by check-expects.
  - "dice-functs.rkt" sub-module contains functions to help simulate dice rolls during gameplay for things such as turn selection and attacks/defenses.
      - To require sub-module: (require "dice-functs.rkt")
  - "graph.rkt" sub-module contains functions that are used for animation purposes such as point comparisons.
      - To require sub-module: (require "graph.rkt")

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
Project is using BitBucket repository: https://TheHeroOfTimez@bitbucket.org/TheHeroOfTimez/risk.git
In order to acquire access to this repository, clients must have appropriate Git credentials that have been approved by the repository owner.
Game files can be downloaded into any folder named "Risk" with any path, but to be updated remotely, they must have Git initialized in said folder.

*** AUTHORS ***
Joshua Sanchez & Patrick "Patty G" Gallagher

*** PROJECT MANAGEMENT FEATURES ***
Bugs should be reported at the following URL: https://bitbucket.org/TheHeroOfTimez/risk/issues?status=new&status=open
Wiki can be found at https://bitbucket.org/TheHeroOfTimez/risk/wiki/Home.

*** CONTACT ***
Josh Sanchez 
- E-mail: joshuaesanch@gmail.com
- Phone Number: +1(773)499-5535

Patty G
- E-mail: pghahaha@cpgallagher.com
- Phone Number: +1(312)493-5743

