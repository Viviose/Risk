;__________________________________________________________________________________________________________________________________________________

#lang racket
(require "dice-functs.rkt")
#|
A sub-module containing functions to help simulate dice rolls during gameplay for things such as turn selection and attacks/defenses.

Provided by dice-functs.rkt:

**Functions**
- roll-die: anything -> number
    - Returns a random value between 1-6. Used to simulate the rolling of a die.
    - Is a dependency all further dice functions.
- roll-dice: number(armies defending/attacking) -> [Listof Numbers]
    - Creates a list of numbers that contains a value for each of the dice rolled. Must take in an armies value of 1, 2, or 3.
    - The list created by this dice-roll simulates a roll of between 1-3 dice by a player.
    - Is used in practice as the input to the dice function sort-rolls.\
    - Dependent of roll-die function.
- sort-rolls: [Listof Numbers] -> [Listof Numbers]
    - Sorts a list of numbers from greatest to least.
    - Input should be roll-dice function.
    - Dependency on remove-max-min function and find-sup-inf function.
- remove-max-or-min: Function(operator) [Listof Numbers] -> [Listof Numbers]
    - Takes in a list of numbers and an operator and returns a list absent of either its least or greatest number, whichever is specified.
    - Has dependency of find-sup-inf function. Removes only the largest/smallest.
- find-sup-inf: function(comparison operator) number(comparison value) [Listof Numbers] -> Number 
    - Takes in a comparison operator, a number in which to compare numbers to, and a list of numbers to be compared to the comparison value.
    - Returns the greatest or least (depending on the given operator) number in a list, or the comparison value given, whichever is greater/lesser.
    - No dependencies.
- produce-rolls: number(attacking armies) number(defending armies) -> [Listof [Listof Numbers]]
    - Creates a list that contains two lists of attack and defense dice.
    - Dependency on sort-rolls function and roll-dice function.
- tally-deaths: [Listof [Listof Numbers]] -> [Listof Numbers]
    - Takes in a list containing lists of numbers and returns a list of numbers that result from a comparison of the first items in each respective list.
    - The first number in the new list will represent the deaths sustained by attacking players.
    - The second number in the new list will represent the deaths sustained by defending players.
    - Dependency on unrequired functions found in dice-functs.rkt, tally-deaths-a and tally-deaths-b.
- create-die-list: [Listof [Listof Numbers]] -> [Listof Die]
    - Creates a list of die that represent the values of either attacking or defending die and their numerical values.
    - Has dependency on unrequired functions found in dice-functs.rkt, create-attack-die and create-defense-die
    - Used to create a list containing dice to be utilized in game functions.

**Structs**
die: number(die value) string(type of die) -> die
    - Contains a number that is used for comparison to other die and to display the correct image to users when die are rolled.
    - Contains a string that is used to specify whether the die is being used by an attacker or defender.
        - This string is used in dice comparison functions and to display the correct color die in the GUI.
|#

(require "graph.rkt")
#|
A sub-module which contains functions that are used for animation purposes such as point comparisons.

Provided by graph.rkt:
**Functions**
- distance: number(x1) number(y1) number(x2) number(y2) -> number(distance between points)
    - Returns the distance between two points. Often used in animations to trigger events when the mouse is a certain distance from a point.
    - No dependencies.
- slope: number(x1) number (y1) number(x2) number(y2) -> number(slope)
    - Calculates the change in y over change in x of a line given two points.
    - No dependencies.
- calc-angle: number(x1) number(y1) number(x2) number(y2) -> number(angle in degrees)
    - Calculates an angle in degrees given two points are used to determine a right triangle of such points.
    - Dependency on slope function of found within sub-module.
- in-ellipse?: number(x1) number(y1) number(x2) number(y2) number(x3) number(y3) number(x) number(y) -> boolean
    - Given the left, right, and top points of an ellipse, as well as a point to compare, checks to see if the point is inside of the given ellipse.
    - Dependencies on calc-angle and distance, both of which are local to sub-module.

|#

(require picturing-programs)
;Picturing-Programs library contains all functions necessary for drawing images.
;All references can be found at this location by default: (file:///C:/Program%20Files/Racket/doc/picturing-programs/index.html)
;It can also be found by looking up the picturing-programs module at the Racket Help Desk.

(require test-engine/racket-tests)
;test-engine/racket-tests library contains all functions necessary for testing functions, such as check-expect, test, and check-random.

;__________________________________________________________________________________________________________________________________________________

;Debug mode variable
;When set to 0, debug mode will not run on the draw handler in the Risk animation.
;When set to 1, it will run debug mode to find points on the map found in imgs folder to be used in functions.
(define DEBUG 0)

;__________________________________________________________________________________________________________________________________________________
(define BOARD (scale .6 (bitmap "imgs/board.png")))
(define TITLESCRN (bitmap "imgs/titlescreen.jpg"))

;System struct (Holds a list of players and kee  ps tracks of whose turn it is)
;[System] : List (player structs) Number (0-5, depending on the player), String (what screen to show)
(define-struct system (playerlist player-turn turn-stage screen dicelist territory-selected territory-list debug x y)
  #:transparent)

;Player struct (Holds the information of each player)
;[Player] : List (card structs) List (strings) Number (armies) String (status) Number(pos)
(define-struct player (cardlist territories-owned reserved-armies status pos)
  #:transparent) 

;Card struct (Holds the information for each card)
;[Card]: String (unit name) String (territory value)
(define-struct card (unit territory)
  #:transparent)

;Territory Struct (Holds the information of each territory)
;[territory]: string(armies) number(armies) string(owner) -> territory
(define-struct territory (name armies owner adjacent-territories)
  #:transparent)

;The 'X' image for closing things
(define X (scale .5 (bitmap "imgs/close.png")))

;List of all territories
(define INITIAL-TERRITORY-LIST (list ;North America
                                (territory "Alaska" 0 "null" (list "Northwest Territory"
                                                                   "Alberta"
                                                                   "Kamchatka")
                                           )
                                (territory "Alberta" 0 "null"(list "Ontario"
                                                                   "Northwest Territory"
                                                                   "Western United States"
                                                                   "Alaska")
                                           )
                                (territory "Central America" 0 "null" (list "Venezuela"
                                                                            "Eastern United States"
                                                                            "Western United States"
                                                                            )
                                           )
                                (territory "Eastern United States" 0 "null" (list "Western United States"
                                                                                  "Ontario"
                                                                                  "Quebec"
                                                                                  "Central America"
                                                                                  )
                                           )
                                (territory "Greenland" 0 "null" (list "Northwest Territory"
                                                                      "Ontario"
                                                                      "Quebec"
                                                                      "Iceland"
                                                                      )
                                           )
                                (territory "Northwest Territory" 0 "null" (list "Alaska"
                                                                                "Alberta"
                                                                                "Ontario"
                                                                                "Greenland"
                                                                                )
                                           )
                                (territory "Ontario" 0 "null" (list "Greenland"
                                                                    "Quebec"
                                                                    "Northwest Territory"
                                                                    "Alberta"
                                                                    "Western United States"
                                                                    "Eastern United States"
                                                                    )
                                           )
                                (territory "Quebec" 0 "null" (list "Greenland"
                                                                   "Ontario"
                                                                   "Eastern United States"
                                                                   )
                                           )
                                (territory "Western United States" 0 "null" (list "Alberta"
                                                                                  "Eastern United States"
                                                                                  "Central America"
                                                                                  "Ontario"
                                                                                  )
                                           )
                                ;South America
                                (territory "Argentina" 0 "null" (list "Brazil"
                                                                      "Peru"
                                                                      )
                                           )
                                (territory "Brazil" 0 "null" (list "Peru"
                                                                   "Venezuela"
                                                                   "Argentina"
                                                                   "North Africa"
                                                                   )
                                           )
                                (territory "Peru" 0 "null" (list "Argentina"
                                                                 "Venezuela"
                                                                 "Brazil"
                                                                 )
                                           )
                                (territory "Venezuela" 0 "null" (list "Brazil"
                                                                      "Peru"
                                                                      "Central America"
                                                                      )
                                           )
                                ;Europe
                                (territory "Great Britain" 0 "null" (list "Iceland"
                                                                          "Western Europe"
                                                                          "Scandinavia"
                                                                          "Northern Europe"
                                                                          )
                                           )
                                (territory "Iceland" 0 "null" (list "Greenland"
                                                                    "Great Britain"
                                                                    "Scandinavia"
                                                                    )
                                           )
                                (territory "Northern Europe" 0 "null" (list "Great Britain"
                                                                            "Western Europe"
                                                                            "Southern Europe"
                                                                            "Ukraine"
                                                                            )
                                          )
                                (territory "Scandinavia" 0 "null" (list "Iceland"
                                                                        "Great Britain"
                                                                        "Ukraine"
                                                                        )
                                           )
                                (territory "Southern Europe" 0 "null" (list "Northern Europe"
                                                                            "Western Europe"
                                                                            "North Africa"
                                                                            "Egypt"
                                                                            "Middle East"
                                                                            )
                                           )
                                (territory "Ukraine" 0 "null" (list "Northern Europe"
                                                                    "Scandinavia"
                                                                    "Southern Europe"
                                                                    "Ural"
                                                                    "Afghanistan"
                                                                    "Middle East"
                                                                    )
                                           )
                                (territory "Western Europe" 0 "null" (list "North Africa"
                                                                           "Great Britain"
                                                                           "Northern Europe"
                                                                           "Southern Europe"
                                                                           )
                                           )
                                ;Africa
                                (territory "Congo" 0 "null" (list "North Africa"
                                                                  "East Africa"
                                                                  "South Africa"
                                                                  )
                                           )
                                (territory "East Africa" 0 "null" (list "Egypt"
                                                                        "Congo"
                                                                        "South Africa"
                                                                        "Madagascar"
                                                                        "North Africa"
                                                                        )
                                           )
                                (territory "Egypt" 0 "null" (list "Southern Europe"
                                                                  "Middle East"
                                                                  "North Africa"
                                                                  "East Africa"
                                                                  )
                                           )
                                (territory "Madagascar" 0 "null" (list "East Africa"
                                                                       "South Africa"
                                                                       )
                                           )
                                (territory "North Africa" 0 "null" (list "Brazil"
                                                                         "Egypt"
                                                                         "Western Europe"
                                                                         "Congo"
                                                                         "East Africa"
                                                                         )
                                           )
                                (territory "South Africa" 0 "null" (list "Madagascar"
                                                                         "Congo"
                                                                         "East Africa"
                                                                         )
                                           )
                                ;Asia
                                (territory "Afganistan" 0 "null" (list "Middle East"
                                                                        "India"
                                                                        "China"
                                                                        "Ural"
                                                                        "Ukraine"
                                                                        )
                                           )
                                (territory "China" 0 "null" (list "India"
                                                                  "Siam"
                                                                  "Afghanistan"
                                                                  "Mongolia"
                                                                  "Siberia"
                                                                  "Ural"
                                                                  )
                                           )
                                (territory "India" 0 "null" (list "Siam"
                                                                  "Middle East"
                                                                  "Afghanistan"
                                                                  "China"
                                                                  )
                                           )
                                (territory "Irkutsk" 0 "null" (list "Yakutsk"
                                                                    "Kamchatka"
                                                                    "Siberia"
                                                                    "Mongolia"
                                                                    )
                                           )
                                (territory "Japan" 0 "null" (list "Mongolia"
                                                                  "Kamchatka"
                                                                  )
                                           )
                                (territory "Kamchatka" 0 "null" (list "Yakutsk"
                                                                      "Alaska"
                                                                      "Irkutsk"
                                                                      "Mongolia"
                                                                      )
                                           ) 
                                (territory "Middle East" 0 "null" (list "Egypt"
                                                                        "India"
                                                                        "Afghanistan"
                                                                        "Ukraine"
                                                                        "Southern Europe"
                                                                        )
                                           )
                                (territory "Mongolia" 0 "null" (list "China"
                                                                     "Japan"
                                                                     "Irkutsk"
                                                                     "Kamchatka"
                                                                     "Siberia"
                                                                     )
                                           )
                                (territory "Siam" 0 "null" (list "Indonesia"
                                                                 "China"
                                                                 "India"
                                                                 )
                                           )
                                (territory "Siberia" 0 "null" (list "Ural"
                                                                    "China"
                                                                    "Mongolia"
                                                                    "Irkutsk"
                                                                    "Yakutsk"
                                                                    )
                                           )
                                (territory "Ural" 0 "null" (list "Ukraine"
                                                                 "Afghanistan"
                                                                 "Siberia"
                                                                 "China"
                                                                 )
                                           )
                                (territory "Yakutsk" 0 "null" (list "Siberia"
                                                                    "Irkutsk"
                                                                    "Kamchatka"
                                                                    )
                                           )
                                ;Australia
                                (territory "Eastern Australia" 0 "null" (list "Western Australia"
                                                                              "New Guinea"
                                                                              )
                                           )
                                (territory "Indonesia" 0 "null" (list "Western Australia"
                                                                      "New Guinea"
                                                                      "Siam"
                                                                      )
                                           )
                                (territory "New Guinea" 0 "null" (list "Eastern Australia"
                                                                       "Western Australia"
                                                                       "Indonesia"
                                                                       )
                                           )
                                (territory "Western Australia" 0 "null" (list "Eastern Australia"
                                                                              "Indonesia"
                                                                              "New Guinea"
                                                                              )
                                           )
                                ;Null territory: For when territory scanning functions do not have a valid territory.
                                (territory "null" 0 404 '())
                                )
  )

;The number of armies per player
;Number -> Number
(define (army-count players)
  (cond [(equal? players 3) 35]
        [(equal? players 4) 30]
        [(equal? players 5) 25]
        [(equal? players 6) 20]
        )
  )


;SCREEN SECTION: Make screens here

;This makes a button with given parameters.
;String (button text) Number (x pos) Number (y pos) String (color) -> Image (button)
(define (button string x y color)
  (above (overlay
          (text string (/ y 2) "white")
          (rectangle x y "solid" color)
          )
         (rectangle x 2  "solid" "black")
         )
  )

;The splash banner
(define SPLASH
  (overlay (text "\n\nClick anywhere to continue" 60 "black")
           (scale 1.8 TITLESCRN)
           )
  ) 

;The player selection screen with player buttons
(define PLAYERSCRN
  (overlay
   (above
    (text "How many players will be joining us?" 48 "white")
    (button "3 players" 500 100 "red")
    (button "4 players" 500 100 "red")
    (button "5 players" 500 100 "red")
    (button "6 players" 500 100 "red")
    )
   (rectangle 1000 700 "solid" "green")
   )
  )

;HUD HELPERS
;White dots used to create the faces of dice.
(define DICECIRCLE (circle 10 "solid" "white"))

;This produces a dice face dependent on the number rolled and red/black based on the type of dice rolled
;Number(roll) String(attack/defend) -> Image(dice)
(define (dice-face number type)
  (cond [(equal? number 1)
         ;When the number to be represented by the die is 1
         (overlay
          DICECIRCLE
          (square 75 "solid" (cond [(equal? type "attack")
                                    "red"]
                                   [(equal? type "defend")
                                    "black"])))]
        [(equal? number 2)
         ;When the number to be represented by the die is 2
         (overlay/align "right" "top"
                        DICECIRCLE
                        (overlay/align "left" "bottom"
                                       DICECIRCLE
                                       (square 75 "solid" (cond [(equal? type "attack")
                                                                 "red"]
                                                                [(equal? type "defend")
                                                                 "black"]))))]
        [(equal? number 3)
         ;When the number to be represented by the die is 3
         (overlay
          DICECIRCLE
          (overlay/align "right" "top"
                         DICECIRCLE
                         (overlay/align "left" "bottom"
                                        DICECIRCLE
                                        (square 75 "solid" (cond [(equal? type "attack")
                                                                  "red"]
                                                                 [(equal? type "defend")
                                                                  "black"])))))]
        [(equal? number 4)
         ;When the number to be represented by the die is 4
         (overlay/align "right" "top"
                        DICECIRCLE
                        (overlay/align "right" "bottom"
                                       DICECIRCLE
                                       (overlay/align "left" "top"
                                                      DICECIRCLE
                                                      (overlay/align "left" "bottom"
                                                                     DICECIRCLE
                                                                     (overlay/align "left" "bottom"
                                                                                    DICECIRCLE
                                                                                    (square 75 "solid" (cond [(equal? type "attack")
                                                                                                              "red"]
                                                                                                             [(equal? type "defend")
                                                                                                              "black"])))))))]
        [(equal? number 5)
         ;When the number to be represented by the die is 5
         (overlay/align "right" "top"
                        DICECIRCLE
                        (overlay/align "right" "bottom"
                                       DICECIRCLE
                                       (overlay/align "left" "top"
                                                      DICECIRCLE
                                                      (overlay/align "left" "bottom"
                                                                     DICECIRCLE
                                                                     (overlay
                                                                      DICECIRCLE
                                                                      (overlay/align "left" "bottom"
                                                                                     DICECIRCLE
                                                                                     (square 75 "solid" (cond [(equal? type "attack")
                                                                                                               "red"]
                                                                                                              [(equal? type "defend")
                                                                                                               "black"]))))))))]
        [(equal? number 6)
         ;When the number to be represented by the die is 6
         (overlay/align "right" "top"
                        DICECIRCLE
                        ;Top-right dot
                        (overlay/align "right" "middle"
                                       DICECIRCLE
                                       ;Middle-right dot
                                       (overlay/align "right" "bottom"
                                                      DICECIRCLE
                                                      ;Bottom-right dot
                                                      (overlay/align "left" "top"
                                                                     DICECIRCLE
                                                                     ;Top-left dot
                                                                     (overlay/align "left" "middle"
                                                                                    DICECIRCLE
                                                                                    ;Middle-left dot
                                                                                    (overlay/align "left" "bottom"
                                                                                                   DICECIRCLE
                                                                                                   ;Bottom-left dot
                                                                                                   (square 75 "solid" (cond [(equal? type "attack")
                                                                                                                             "red"]
                                                                                                                            [(equal? type "defend")
                                                                                                                             "black"]
                                                                                                                            )
                                                                                                           )
                                                                                                   )
                                                                                    )
                                                                     )
                                                      )
                                       )
                        )]
        )
  )

;This assigns a designated color to each player, and is used to custom color player objects like army markers.
;System (the model which contains the player turn) -> String (color)
(define (playercolor model)
  (cond [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 0)
         "red"]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 1)
         "yellow"]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 2)
         "blue"]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 3)
         "green"]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 4)
         "purple"]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 5)
         "brown"]
        [else "white"]
        )
  )

;This shows a variable number of die on the bar.
;Dicelist (dice structs) -> Image (die)
(define (die-bar leest)
  (cond [(empty? leest) (square 0 "outline" "white")]
        [else (beside (dice-face (die-number (first leest)) 
                                 (die-type (first leest))
                                 )
                      (die-bar (rest leest))
                      )]
        )
  )

;Defines player turn box's color by turn

(define (turncolor model)
  (cond [(equal? (system-player-turn model) 0)
         "red"]
        [(equal? (system-player-turn model) 1)
         "yellow"]
        [(equal? (system-player-turn model) 2)
         "blue"]
        [(equal? (system-player-turn model) 3)
         "green"]
        [(equal? (system-player-turn model) 4)
         "purple"]
        [(equal? (system-player-turn model) 5)
         "brown"]
        [else "white"]
        )
  )
;This shows the toolbar on the bottom of the HUD.
;System (model, used to grab info) -> Image (toolbar)
(define (toolbar model)
  (beside
   (overlay
    (text (system-debug model) 16 "black")
    (square 75 "solid" (turncolor model))
    )
   (overlay
    (text "Roll" 16 "black")
    (square 75 "solid" "green"))
   (die-bar (system-dicelist model))
   (overlay
    (text (cond [(equal? (system-turn-stage model) "recruit")
                 "Recruit"]
                [(equal? (system-turn-stage model) "attack")
                 "Attack"]
                [(equal? (system-turn-stage model) "fortify")
                 "Fortify"]
                [(equal? (system-turn-stage model) "init-recruit")
                 "Initial Recruitment"]
                )
          16 "black")                                              
    (rectangle 150 75 "solid" (cond [(or (equal? (system-turn-stage model) "recruit")
                                         (equal? (system-turn-stage model) "init-recruit")
                                         )
                                     "blue"]
                                    [(equal? (system-turn-stage model) "attack")
                                     "red"]
                                    [(equal? (system-turn-stage model) "fortify")
                                     "yellow"]
                                    [else "white"]
                                    )
               ) 
    )
   (overlay
    (text "Cards" 16 "white")
    (circle 37.5 "solid" "black"))
   )
  )

(define (card-create card)
  (overlay
   (above
    (text (card-territory card) 16 "black")
    (text (card-unit card) 16 "black")
    )
   (rectangle 100 145 "solid" "white")
   )
  )


;Card-Buncher - Stack images of cards next to each other
(define (card-buncher cardleest)
  (cond [(empty? cardleest) (square 0 "solid" "white")]
        [else (beside (card-create (first cardleest)) 
                      (square 4 "solid" (make-color 128 0 0)) 
                      (card-buncher (rest cardleest))
                      )]
        )
  )

(define (who-owns? model)
  (cond
    [(not (number? (territory-owner
                           (territory-scan
                            (system-territory-selected model) (system-territory-list model)))))
     "Unclaimed!"]
    [else (string-append "Owned by Player " (number->string
                                             (+ 1 
                                                (territory-owner 
                                                 (territory-scan 
                                                  (system-territory-selected model) (system-territory-list model)))))
                         )
          ]
    )
  )



;HANDLERS
(define (render model)
  ;Render is the draw handler. It interprets various elements of the model, such as the screen the player
  ;should see at a given moment or on a given event
  ;Ex: if the screen element of the model is "splash", the "splash" screen displays.
  (cond [(equal? (system-screen model) "splash")
         ;This is the first thing the player sees, purely asthetic.
         SPLASH]
        [(equal? (system-screen model) "playerscrn")
         ;This screen chooses the amount of players.
         PLAYERSCRN]
        [(equal? (system-screen model) "gameplay")
         ;This screen is where the board and toolbar are located, and is the main screen of the game.
         (above
          (cond [(not (equal? (system-territory-selected model) "null"))
                 ;*****************************************************!!!!!!Work on null is needed.
                 (place-image (overlay
                               (above
                                (text (system-territory-selected model) 16 "black")
                                (text (who-owns? model) 12 "black")
                                (text (string-append
                                       (number->string
                                        (territory-armies
                                         (territory-scan
                                          (system-territory-selected model)
                                          (system-territory-list model))))
                                       " Armies")
                                      12
                                      "black"
                                      )    
                                )
                               (rectangle 100 50 "solid" (playercolor model))
                               )
                              (system-x model) (system-y model)
                              BOARD)]
                [else BOARD]
                )          
          (toolbar model))]
        [(equal? (system-screen model) "cards")
         (overlay
          (overlay/align "right" "top" X
                         (overlay
                          (card-buncher 
                           ;*********THIS WILL BE REPLACED BY THE CARDLIST FOR THE RESPECTIVE PLAYER************
                           (list (make-card "Rachel is nub" "3")))
                          (rectangle 700 200 "solid" (make-color 128 0 0))))
          (above
           (cond [(not (equal? (system-territory-selected model) "null"))
                  (place-image (overlay
                                (above
                                 (text (system-territory-selected model) 16 "black")
                                 (text "Player who owns" 12 "black"))
                                (rectangle 100 50 "solid" (playercolor model)))
                               (system-x model) (system-y model)
                               BOARD)]
                 [else BOARD])
           (toolbar model))
          )]
        [else model]
        )
  )

(define (mouse-handler model x y event)
  (cond [(equal? (system-screen model) "splash")
         ;If the splash screen is clicked, show the player selection screen
         (cond [(equal? event "button-down")
                (struct-copy system model
                             [screen "playerscrn"])]
               [else model])]
        [(equal? (system-screen model) "playerscrn")
         ;This function checks for how many players the user selects. It is dependent on an x and y coord, along with the
         ;button-down event.
         (cond [(equal? event "button-down")
                (cond [(and
                        (< x 750)
                        (> x 250)
                        )
                       (cond [(and
                               (<= y 274)
                               (> y 174))
                              (struct-copy system model
                                           [playerlist (list (make-player (list) (list) (army-count 3) "alive" 0)
                                                             (make-player (list) (list) (army-count 3) "alive" 1)
                                                             (make-player (list) (list) (army-count 3) "alive" 2)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 374)
                               (> y 274))
                              (struct-copy system model
                                           [playerlist (list (make-player (list) (list) (army-count 4) "alive" 0)
                                                             (make-player (list) (list) (army-count 4) "alive" 1)
                                                             (make-player (list) (list) (army-count 4) "alive" 2)
                                                             (make-player (list) (list) (army-count 4) "alive" 3)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 474)
                               (> y 374))
                              (struct-copy system model
                                           [playerlist (list (make-player (list) (list) (army-count 5) "alive" 0)
                                                             (make-player (list) (list) (army-count 5) "alive" 1)
                                                             (make-player (list) (list) (army-count 5) "alive" 2)
                                                             (make-player (list) (list) (army-count 5) "alive" 3)
                                                             (make-player (list) (list) (army-count 5) "alive" 4)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 574)
                               (> y 474))
                              (struct-copy system model
                                           [playerlist (list (make-player (list) (list) (army-count 6) "alive" 0)
                                                             (make-player (list) (list) (army-count 6) "alive" 1)
                                                             (make-player (list) (list) (army-count 6) "alive" 2)
                                                             (make-player (list) (list) (army-count 6) "alive" 3)
                                                             (make-player (list) (list) (army-count 6) "alive" 4)
                                                             (make-player (list) (list) (army-count 6) "alive" 5)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [else model]
                             )
                       ]
                      [else model]
                      )
                ] [else model]
                  )]
        [(equal? (system-screen model) "gameplay")
         ;This begins the tooltip function, which looks for an x and y coord, and modifies the territory-selected part of the
         ;model, so render knows what and where to draw in the tooltip.
         (cond
           #|[(active-near-cards? event x y)
            #;(and (not-debugging?)
                 (button-down? event)
                 (hover-near-cards? x y))
            (model-screen->cards model)]|#
                 
           [(equal? DEBUG 0)                 
            (cond [(and 
                    (equal? event "button-down")
                    (< (distance 993 910 x y) 32.5)
                    (struct-copy
                     system model
                     [screen "cards"]
                     ))]
                  [else (cond [(equal? (system-turn-stage model) "init-recruit")
                               (initial-recruit model x y event)]
                              ;Will work when recruit phase function is created
                               [(equal? (system-turn-stage model) "recruit")
                                  ;Here is the problemo:
                                  (recruit-phase model x y event)]
                              ;Will work when attack phase function is created
                              #; [(equal? (system-turn-stage model) "attack")
                                  (attack-phase model)]
                              ;Will work when fortify phase function is created
                              #; [(equal? (system-turn-stage model) "fortify")]
                              [else model]
                              )
                        ]
                  )]
           ;THIS IS USED IN DEBUG TO DISPLAY A POSN                
           [(equal? DEBUG 1)
            (struct-copy
             system model
             [debug (string-append (number->string x) " " (number->string y))]
             )]
           [else model]
           )]
        [(equal? (system-screen model) "cards")
         (if (and (in-ellipse? 953 405 989 405 973 398 x y)
                  (equal? event "button-down")
                  )
             ;Checks to see if mouse is on X and has clicked it, if so runs next function
             (struct-copy 
              system model
              [screen "gameplay"]
              )
             ;If not true, then it returns model
             model
             )]
        [else model]
        )
  )
  
;tooltip: a central function to risk that determines what territory is selected given coords
;Number (x) Number (y) System (model) -> String (territory selected)
(define (tooltip x y model)
  (cond [(< (distance x y 119 134) 10)
         "Alaska"]
          
        [(< (distance x y 232 136) 20)
         "Northwest Territory"]
          
        [(< (distance x y 467 95) 20)
          "Greenland"]
          
        [(< (distance x y 384 216) 20)
          "Quebec"]
          
        [(< (distance x y 297 218) 20)
         
          "Ontario"]
          
        [(< (distance x y 228 198) 20)
         "Alberta"]
          
        [(< (distance x y 229 297) 20)
         "Western United States"]
          
        [(< (distance x y 315 315) 20)
         "Eastern United States"]
         
        [(< (distance x y 224 372) 20)
         "Central America"]
          
        [(< (distance x y 318 480) 10)
          "Venezuela"]
          
        [(< (distance x y 417 553) 30)
          "Brazil"
          ]
        [(in-ellipse? 295 553 389 628 349 566 x y)
          "Peru"]
        [(in-ellipse? 501 228 573 309 569 243 x y)
         "Great Britain"]
        [(in-ellipse? 536 425 608 326 543 341 x y)"Western Europe"]
        [(in-ellipse? 523 172 601 170 560 146 x y)"Iceland"]
        [(in-ellipse? 623 216 713 123 641 132 x y)"Scandinavia"]
        [(in-ellipse? 605 319 705 263 635 247 x y)"Northern Europe"]
        [(in-ellipse? 617 381 706 368 664 337 x y)"Southern Europe"]
        [(in-ellipse? 572 587 647 495 552 476 x y)"North Africa"]
        [(in-ellipse? 646 480 753 487 703 454 x y)"Egypt"]
        [(in-ellipse? 652 636 748 633 707 587 x y)"Congo"]
        [(in-ellipse? 669 734 761 742 718 681 x y)"South Africa"]
        [(in-ellipse? 802 779 846 694 802 733 x y)"Madagascar"]
        [(in-ellipse? 735 611 808 598 752 523 x y)"East Africa"]
        [(in-ellipse? 754 481 875 430 797 381 x y)"Middle East"]
        [(in-ellipse? 821 327 928 306 852 261 x y)"Afganistan"]
        [(in-ellipse? 906 465 995 461 934 371 x y)"India"]
        [(in-ellipse? 934 303 1074 448 1030 348 x y)"China"]
        [(in-ellipse? 986 301 1114 294 1047 258 x y)"Mongolia"]
        [(in-ellipse? 314 692 407 709 368 624 x y)"Argentina"]
        [(in-ellipse? 1157 302 1187 306 1174 224 x y)"Japan"]
        [(in-ellipse? 975 237 1086 219 1031 167 x y)"Irkutsk"]
        [(in-ellipse? 994 123 1097 122 1050 77 x y)"Yakutsk"]
        [(in-ellipse? 702 256 851 246 779 130 x y)"Ukraine"]
        [(in-ellipse? 857 217 926 204 874 125 x y)"Ural"]
        [(in-ellipse? 1089 137 1187 189 1182 93 x y)"Kamchatka"]
        [(in-ellipse? 1000 467 1076 506 1053 448 x y)"Siam"]
        [(in-ellipse? 1027 653 1105 584 1033 574 x y)"Indonesia"]
        [(in-ellipse? 1110 566 1212 611 1173 558 x y)"New Guinea"]
        [(in-ellipse? 1066 712 1180 764 1147 706 x y)"Western Australia"]
        [(in-ellipse? 1166 653 1206 806 1235 697 x y)"Eastern Australia"]
        [(in-ellipse? 922 176 1006 153 935 59 x y)"Siberia"]
        
        
        ;More countries to come
        [else 
         "null"]
          
        )
  )
  
;territory-scan: Selects a territory struct based on a keyword given.
;String (territory-name) -> Territory (of that struct)
(define (territory-scan name leest)
  (cond [(empty? leest) (error "Territory not found!")]
        [(equal? (territory-name (first leest)) name)
         (first leest)]
        [else (territory-scan name (rest leest))]))

;(check-expect (territory-scan "Alberta" INITIAL-TERRITORY-LIST)
 ;             (make-territory "Alberta" 0 "null"))

;Update-t is for the territory-update function. It just applies the changes
(define (update-t territory name f armies owner)
  (cond [(equal? (territory-name territory) name)
         (make-territory name (f (territory-armies territory) armies) owner (territory-adjacent-territories territory))]
        [else territory])
  )

;territory-update: Updates the territory with new owner, and adds or subtracts armies
;Operator (+/-) Number (armies to subtract) String (name of territory) List (list of territories) Number (player)
(define (territory-update f armies name tlist owner)
  (local
    [(define
       (change-t territory)
       (update-t territory name f armies owner))]
    (map change-t tlist)
    )
  )

;update-player-armies: Helper function to player-update-armies that adds/subtracts armies to a player
; Player (player1) Function + or - (f) Number (armies) Number (playerpos) -> Player
(define (update-player-armies player1 f armies playerpos)
  (cond
    [(equal? (player-pos player1) playerpos)
     (struct-copy
      player player1
      [reserved-armies (f (player-reserved-armies player1) armies)])]
    [else player1]))

;player-update-armies: Function that adds or subtracts armies from a specified player reserve.
;List [Players] (playerlist) Function (f) Number (armies) Number (playerpos) -> List [Players]
(define (player-update-armies playerlist f armies playerpos)
  (local
    [(define (change-p player)
       (update-player-armies player f armies playerpos))]
    (map change-p playerlist)))

(define (make-boolean-list plist)
   (cond [(empty? plist) '()]
         [(equal? (player-reserved-armies (first plist)) 0)
         (append (list true) (make-boolean-list (rest plist))  
               
               )]
         [else (append (list false)
                     (make-boolean-list (rest plist))
                     )]
         )
   )

(check-expect (make-boolean-list (list (make-player '() '() 0 "alive" 0)))
              (list true)
              )

(define (move-on-to-recruit? plist)
  (cond [(empty? plist) true]
        [(equal? (first plist) true)
         (move-on-to-recruit? (rest plist))]
        [else false]
        )
  )

(check-expect (move-on-to-recruit? (make-boolean-list (list (make-player '() '() 0 "alive" 0)
                                                            (make-player '() '() 0 "alive" 1)
                                                            (make-player '() '() 0 "alive" 2)
                                                            )
                                                      )
                                   )
              true)

(check-expect (move-on-to-recruit? (make-boolean-list (list (make-player '() '() 0 "alive" 0)
                                                            (make-player '() '() 1 "alive" 1)
                                                            (make-player '() '() 0 "alive" 2)
                                                            )
                                                      )
                                   )
              false)


;WILL BE DEPRECATED BY JOSH'S FUNCTION. PLEASE DELETE THIS WHEN IMPLEMENTED
;(define (move-on-to-recruit? plist)
  ;(equal? (player-reserved-armies (last plist)) 0))
 ;-------------------------------------------------------------------------

;any-unclaimed-terrs?: Checks to see if there are any territories laft to claim in the init phase.
; List [Territories] -> Boolean

(define (any-unclaimed-terrs? tlist)
  (cond [(empty? tlist) #f]
        [(equal? (territory-armies (first tlist)) 0)
         #t]
        [else (any-unclaimed-terrs? (rest tlist))]
        )
  )

;initial-recruit: Adds one army to any one territory of a specific player based on territory selected
;System (model) -> System (model)
;Still requires case for when troops can no longer be placed
(define (initial-recruit model x y event)
  (cond [(not (any-unclaimed-terrs? (system-territory-list model)))
         (cond
           ;This clause checks to see if the armies are at 0 of all players (or it should, in the future)
           [(move-on-to-recruit? (system-playerlist model))

            ;If so, we move on to the recruit phase
                              (struct-copy
                               system model
                               [turn-stage "recruit"])]
           ;Otherwise, it just places the tooltip. {?}
           [else (struct-copy system model
                              [territory-selected (tooltip x y model)]
                              [x x]
                              [y y])])
                     ]
         ;This clause checks to see if the player turn has reached the end

        [(equal? (system-player-turn model) (length (system-playerlist model)))
         ;if so, we cycle back
         (struct-copy
          system model
          [player-turn 0]
          )]
        ;This clause checks to see if there is no territory selected
        [(equal? (system-territory-selected model) "null")
         (cond
           ;If so, we check again to see if we need to move on to the recruit phase
           [(move-on-to-recruit? (system-playerlist model))
                              (struct-copy
                               system model

                               [turn-stage "recruit"]
                               )]
           [else (struct-copy system model
                              [territory-selected (tooltip x y model)]
                              [x x]
                              [y y])]
           )]
        
        ;If a territory is clicked, this clause is activated
        [(and
          (equal? event "button-down")
          (not (equal? (system-territory-selected model) "null")))
          
         ;This conditional checks to see if the territory owner matches the player who is clicking

         (cond [(not
                (equal? (territory-owner (territory-scan
                                         (system-territory-selected model)
                                         (system-territory-list model)))
                       (system-player-turn model)))
                ;If so, he/she can add an army during this stage.
         (struct-copy 
          system model
          [territory-list (territory-update + 1 
                                            (territory-name (territory-scan (system-territory-selected model) (system-territory-list model))) 
                                            (system-territory-list model) 
                                            (system-player-turn model))]
          [player-turn (cond [(equal? (system-player-turn model) (= 1
                                                                    (length (system-playerlist model))
                                                                    )
                                      )
                              0]
                             [else (+ 1
                                      (system-player-turn model)
                                      )]
                             )]
          [playerlist (player-update-armies (system-playerlist model) - 1 (system-player-turn model))]
          
          )]
               ;If not, we just see the tooltip
               [else (struct-copy
                      system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)])])]
        ;If none of those apply, then we check once again for the recruit phase
        [else
         (cond
           [(move-on-to-recruit? (system-playerlist model))
                              (struct-copy
                               system model
                               [turn-stage "recruit"])]
           ;And if nothing else applies, then we go ahead and just show the tooltip.
           [else (struct-copy system model
                              [territory-selected (tooltip x y model)]
                              [x x]
                              [y y])])]
        ))
  

;RECRUITMENT PHASE

(define (count-territories-of-player playerno tlist)
  (cond [(empty? tlist) 0]
        [(equal? (territory-owner (first tlist)) playerno)
         (+ 1 (count-territories-of-player playerno (rest tlist)))]
        [else (count-territories-of-player playerno (rest tlist))]
        )
  )

;(define (factor-continent-bonuses tlist) *** I'm lazy, this is gonna require a lot of cases

(check-expect (count-territories-of-player "null" INITIAL-TERRITORY-LIST)
              42)

(define (armies-to-add model)
  (+
   (count-territories-of-player (system-player-turn model) (system-territory-list model))
   0 ;Replaced mlater with continent bonuses!
   )
  )
   
;da recruit phase m8
(define (recruit-phase model x y event)
  (struct-copy
   system model
   [playerlist (player-update-armies (system-playerlist model) + (armies-to-add model) (system-player-turn model))]))

(big-bang (make-system 
           ;No players at first, updated upon player selection
           (list)
           ;Turn starts at 0, first player
           0
           ;Initial phase is init-recruit, changes upon completion of phases
           "init-recruit"
           ;First screen displayed is splash, changes upon events in-game
           "splash"
           ;Initial die list is one of random rolled dice.
           (list (make-die (roll-die "die1") "attack")
                 (make-die (roll-die "die2") "defend")
                 (make-die (roll-die "die3") "defend")
                 (make-die (roll-die "die4") "attack")
                 (make-die (roll-die "die5") "attack")
                 )
           ;Territory selected is initially null, and remains such unless a territory is selected
           "null"
           ;Initial Territory List is known as INITIAL-TERRITORY-LIST, found near the header
           INITIAL-TERRITORY-LIST
           ;Debug coordinates
           "null state"
           ;Mouse x coordinate
           0
           ;Mouse y coordinate
           0)
          (to-draw render 1250 1200)
          (on-mouse mouse-handler)
          )

(test)