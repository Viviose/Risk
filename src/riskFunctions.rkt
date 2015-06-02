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

|#

(require picturing-programs)
;Picturing-Programs library contains all functions necessary for drawing images.
;All references can be found at this location by default: (file:///C:/Program%20Files/Racket/doc/picturing-programs/index.html)
;It can also be found by looking up the picturing-programs module at the Racket Help Desk.

(require test-engine/racket-tests)
;test-engine/racket-tests library contains all functions necessary for testing functions, such as check-expect, test, and check-random.

;__________________________________________________________________________________________________________________________________________________

(define BOARD (scale .6 (bitmap "imgs/board.png")))
(define TITLESCRN (bitmap "imgs/titlescreen.jpg"))

;System struct (Holds a list of players and kee  ps tracks of whose turn it is)
;[System] : List (player structs) Number (0-5, depending on the player), String (what screen to show)
(define-struct system (playerlist player-turn turn-stage screen dicelist territory-selected debug x y)
  #:transparent)

;Player struct (Holds the information of each player)
;[Player] : List (card structs) List (strings) Number (armies) String (status)
(define-struct player (cardlist territories-owned reserved-armies status)
  #:transparent) 

;Card struct (Holds the information for each card)
;[Card]: String (unit name) String (territory value)
(define-struct card (unit territory)
  #:transparent)

;The 'X' image for closing things
(define X (scale .5 (bitmap "imgs/close.png")))

;The number of armies per player
;Number -> Number
(define (army-count players)
  (cond [(equal? players 3) 35]
        [(equal? players 4) 30]
        [(equal? players 5) 25]
        [(equal? players 6) 20]))


;SCREEN SECTION: Make screens here

;This makes a button with given parameters.
;String (button text) Number (x pos) Number (y pos) String (color) -> Image (button)
(define (button string x y color)
  (above
   (overlay
    (text string (/ y 2) "white")
    (rectangle x y "solid" color))
   (rectangle x 2  "solid" "black")))

;The splash banner
(define SPLASH
  (overlay
   (text "\n\nClick anywhere to continue" 60 "black")
   (scale 1.8 TITLESCRN)
   )) 

;The player selection screen with player buttons
(define PLAYERSCRN
  (overlay
   
   (above
    (text "How many players will be joining us?" 48 "white")
    (button "3 players" 500 100 "red")
    (button "4 players" 500 100 "red")
    (button "5 players" 500 100 "red")
    (button "6 players" 500 100 "red"))
   (rectangle 1000 700 "solid" "green")))

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
;THIS SHOULD BE CHANGED TO BE DEPENDENT ON THE NUMBER, NOT THE MODEL, MY B. IT WILL BE A PROBLEM LATER ON.
;System (the model which contains the player turn) -> String (color)
(define (playercolor model)
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
         "brown"]))

;This shows a variable number of die on the bar.
;Dicelist (dice structs) -> Image (die)
(define (die-bar leest)
  (cond [(empty? leest) (square 0 "outline" "white")]
        [else (beside (dice-face (die-number (first leest)) (die-type (first leest)))
                      (die-bar (rest leest)))]))

;This shows the toolbar on the bottom of the HUD.
;System (model, used to grab info) -> Image (toolbar)
(define (toolbar model)
  (beside
   (overlay
    (text (system-debug model) 16 "black")
    (square 75 "solid" (playercolor model)
            )
    )
   (overlay
    (text "Roll" 16 "black")
    (square 75 "solid" "green"))
   (die-bar (system-dicelist model)
            )
   (overlay
    (text (system-turn-stage model) 16 "black")
                                                      
    (rectangle 150 75 "solid" (cond [(equal? (system-turn-stage model) "Recruit")
                                              "blue"]
                                             [(equal? (system-turn-stage model) "Attack")
                                              "red"]
                                             [(equal? (system-turn-stage model) "Fortify")
                                              "yellow"]
                                             [else "white"])) 
   )
   
   (overlay
    (text "Cards" 16 "white")
    (circle 37.5 "solid" "black"))
  ))



(define (card-create card)
  (overlay
   (above
    (text (card-territory card) 16 "black")
    (text (card-unit card) 16 "black"))
   (rectangle 100 145 "solid" "white")))


;Card-Buncher - Stack images of cards next to each other
(define (card-buncher cardleest)
  (cond [(empty? cardleest) (square 0 "solid" "white")]
        [else (beside (card-create (first cardleest)) (square 4 "solid" (make-color 128 0 0)) (card-buncher (rest cardleest)))]))
  

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
                 (place-image (overlay
                               (above
                                (text (system-territory-selected model) 16 "black")
                                (text "Player who owns" 12 "black"))
                               (rectangle 100 50 "solid" "orange"))
                              (system-x model) (system-y model)
                              
                              BOARD)]
                [else BOARD])
                              
                       
           
          (toolbar model))]
        [(equal? (system-screen model) "cards")
          (overlay
           (overlay/align "right" "top" X
            (overlay
             (card-buncher 
              ;*********THIS WILL BE REPLACED BY THE CARDLIST FOR THE RESPECTIVE PLAYER************
              (list (make-card "Test Territory" "3")))
             (rectangle 700 200 "solid" (make-color 128 0 0))))
           (above
            
          (cond [(not (equal? (system-territory-selected model) "null"))
                 (place-image (overlay
                               (above
                                (text (system-territory-selected model) 16 "black")
                                (text "Player who owns" 12 "black"))
                               (rectangle 100 50 "solid" "orange"))
                              (system-x model) (system-y model)
                              
                              BOARD)]
                [else BOARD])
          (toolbar model))
           )]))


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
                        (> x 250))
                       (cond [(and
                               (<= y 274)
                               (> y 174))
                              (struct-copy system model
                                           [playerlist '((make-player (list) (list) (army-count 3) "alive")
                                                         (make-player (list) (list) (army-count 3) "alive")
                                                         (make-player (list) (list) (army-count 3) "alive")
                                                         )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 374)
                               (> y 274))
                              (struct-copy system model
                                           [playerlist '((make-player (list) (list) (army-count 4) "alive")
                                                         (make-player (list) (list) (army-count 4) "alive")
                                                         (make-player (list) (list) (army-count 4) "alive")
                                                         (make-player (list) (list) (army-count 4) "alive")
                                                         )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 474)
                               (> y 374))
                              (struct-copy system model
                                           [playerlist '((make-player (list) (list) (army-count 5) "alive")
                                                         (make-player (list) (list) (army-count 5) "alive")
                                                         (make-player (list) (list) (army-count 5) "alive")
                                                         (make-player (list) (list) (army-count 5) "alive")
                                                         (make-player (list) (list) (army-count 5) "alive")
                                                         )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 574)
                               (> y 474))
                              (struct-copy system model
                                           [playerlist '((make-player (list) (list) (army-count 6) "alive")
                                                         (make-player (list) (list) (army-count 6) "alive")
                                                         (make-player (list) (list) (army-count 6) "alive")
                                                         (make-player (list) (list) (army-count 6) "alive")
                                                         (make-player (list) (list) (army-count 6) "alive")
                                                         (make-player (list) (list) (army-count 6) "alive")
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
        
         (cond [
                (not
                 (equal? event "button-down"))
                (tooltip x y model)
                ]
               [else
                (cond [(< (distance 993 910 x y) 32.5)
                 (struct-copy
                  system model
                  [screen "cards"])]
                [else model])])]
                                                       
         ;THIS IS USED IN DEBUG TO DISPLAY A POSN                
        ; (struct-copy
         ; system model
          ;[debug (string-append (number->string x) " " (number->string y))])]
         
        
        
        
        [else model]))
      
(define (tooltip x y model)
  (cond [(< (distance x y 119 134) 10)
                        (struct-copy
                         system model
                         [territory-selected "Alaska"]
                         [x x]
                         [y y])]
        [(< (distance x y 232 136) 20)
                        (struct-copy
                         system model
                         [territory-selected "Northwest Territory"]
                         [x x]
                         [y y])]
        [(< (distance x y 467 95) 20)
                        (struct-copy
                         system model
                         [territory-selected "Greenland"]
                         [x x]
                         [y y])]
        [(< (distance x y 384 216) 20)
                        (struct-copy
                         system model
                         [territory-selected "Quebec"]
                         [x x]
                         [y y])]
        [(< (distance x y 297 218) 20)
                        (struct-copy
                         system model
                         [territory-selected "Ontario"]
                         [x x]
                         [y y])]
        [(< (distance x y 228 198) 20)
                        (struct-copy
                         system model
                         [territory-selected "Alberta"]
                         [x x]
                         [y y])]
        [(< (distance x y 229 297) 20)
                        (struct-copy
                         system model
                         [territory-selected "Western US"]
                         [x x]
                         [y y])]
        [(< (distance x y 315 315) 20)
                        (struct-copy
                         system model
                         [territory-selected "Eastern US"]
                         [x x]
                         [y y])]
        [(< (distance x y 224 372) 20)
                        (struct-copy
                         system model
                         [territory-selected "Central US"]
                         [x x]
                         [y y])]
        
                       [else 
                        (struct-copy
                         system model
                         [territory-selected "null"])]))

(big-bang (make-system 
           ;Will be changed later
           (list)
           0
           "Recruit"
           "splash"
           (list (make-die (roll-die "die1") "attack")
                 (make-die (roll-die "die2") "defend")
                 (make-die (roll-die "die3") "defend")
                 (make-die (roll-die "die4") "attack")
                 (make-die (roll-die "die5") "attack"))
           "null"
           "0 0"
           0
           0)
          (to-draw render 1250 1200)
          (on-mouse mouse-handler))