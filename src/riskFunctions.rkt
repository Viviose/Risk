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
- between?: number(query) number(min) number(max) -> boolean
    - Given a number to compare, and two numbers which represent bounds to compare, returns true if number is in bounds.
|#

(require "matdes.rkt")
#|
A sub-module for graphic design purposes that align with Material Design.

Provided by matdes.rkt:
**Functions**
- textc: String (text) Number (size in pt) String/Color (color)
    - Creates an image of text with the specifications in the Roboto style.
- shadow-circle: Number (radius)
    - Builds a gradient shadow in a circular shape.
    - Dependent on color functions in the module.
**Objects**
- DICE-BUTTON
    - A new, material inspired button for rolling the dice.
- CARD-BUTTON
    - The same as above, only for cards.
- SUBMIT-BUTTON
    - The card button morphs into this button.
|#

(require "sys-lists.rkt")
;Module that contains all of the list variables necessary for the system, as well as the structs territory and card.
;Struct definitions can be found in sys-lists.rkt, here in the struct definition portion of the file, or in the project wiki.

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
(define TITLESCRN (scale .6 (bitmap "imgs/titlescreen.jpg")))

;System struct (Holds all game information and statuses)
(define-struct system (playerlist player-turn
                                  turn-stage 
                                  screen 
                                  dicelist
                                  territory-selected 
                                  territory-list 
                                  debug 
                                  x y 
                                  card-list 
                                  cardsets-redeemed 
                                  territory-attacking 
                                  territory-attacked 
                                  armies-attacking 
                                  slider-store)
  #:transparent)

;Player struct (Holds the information of each player)
;[Player] :  Number (armies) Number(pos)
(define-struct player (reserved-armies pos)
  #:transparent) 

#|
Definition of structs as seen in sys-lists.rkt.
Redefinition of these structs here can crash the program, and as thus they should be left commented out.

;Card struct (Holds the information for each card)
;[Card]: String(unit-name) String(territory-name) number(card-id) [Maybe number(owner-id)] string(card-state)-> card
(define-struct card (unit territory id owner state)
  #:transparent)

;Territory Struct (Holds the information of each territory)
;[territory]: string(armies) number(armies) string(owner) [List String] -> territory
(define-struct territory (name armies owner adjacent-territories)
  #:transparent)

|#

(define-struct slider (image armies)
  #:transparent)


;The 'X' image for closing things
(define X (scale .5 (bitmap "imgs/close.png")))

;The number of armies per player
;Number -> Number
(define (army-count players)
  (cond [(equal? players 3) 35]
        [(equal? players 4) 30]
        [(equal? players 5) 25]
        [(equal? players 6) 20]
        )
  )

;SLIDER CONSTANT:
(define SLIDER-OFFSET 1000)


;SCREEN SECTION: Make screens here

;This makes a button with given parameters.
;String (button text) Number (x pos) Number (y pos) String (color) -> Image (button)
(define (button string x y color)
  (above (overlay
          (textc string (/ y 2) "black")
          (rectangle x y "solid" color)
          )
         (rectangle x 2  "solid" "black")
         )
  )

;The splash banner
(define SPLASH
  (overlay (overlay
            (textc "Click anywhere to continue" 60 "white")
            (rectangle 700 100 "solid" (make-color 26 35 126 150)))
           (scale 1.8 TITLESCRN)
           )
  ) 

;The player selection screen with player buttons
(define PLAYERSCRN
  (overlay
   (above
    (textc "How many players will be joining us?" 48 "white")
    (button "3 players" 500 100 (make-color 255 235 59))
    (button "4 players" 500 100 (make-color 255 235 59))
    (button "5 players" 500 100 (make-color 255 235 59))
    (button "6 players" 500 100 (make-color 255 235 59))
    )
   (rectangle 1000 700 "solid" (make-color 27 94 32))
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
         (make-color 198 40 40)]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 1)
         (make-color 253 216 53)]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 2)
         (make-color 0 131 143)]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 3)
         (make-color 56 142 60)]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 4)
         (make-color 69 39 160)]
        [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                  (system-territory-list model)
                                                  )
                                  )
                 5)
         (make-color 121 85 72)]
        [else "white"]
        )
  )

;SLIDER.RKT FUNCTIONS MOVED HERE
;_________________________________________________________________________________________________________________
(define SLIDER-WIDTH 210)

(define SLIDER-BAR
  (rectangle SLIDER-WIDTH 10 "solid" "green"))

(define SLIDER-HEAD
  (flip-vertical (triangle 20 "solid" "red")))

#|
SAMPLE IMPLEMENTATION!
(define (render model)
  (place-image
   SLIDER-HEAD
   (posn-x model)
   (posn-y model)
   SLIDER-BAR)
  )

(define (mousey model x y event)
  (cond [(equal? event "drag")
         (struct-copy
          posn model
          [x x]
          [y 5])]
        [else model]))

(big-bang (posn 0 0)
          (to-draw render)
          (on-mouse mousey))
|#

(define (numberbar armies selected)
  (above
   
   (beside
    (overlay
     (textc "0" 12  "black")
     (rectangle (/ SLIDER-WIDTH 5) 0 "solid" (make-color 0 0 0 0)))
    (overlay 
     (textc (number->string (round (/ armies 4))) 12 "black")
     (rectangle (/ SLIDER-WIDTH 5) 0 "solid" (make-color 0 0 0 0)))
    (overlay
     (textc (number->string (round (/ armies 2))) 12 "black")
     (rectangle (/ SLIDER-WIDTH 5) 0 "solid" (make-color 0 0 0 0)))
    (overlay
     (textc (number->string (round (/ (* 3 armies) 4))) 12 "black")
     (rectangle (/ SLIDER-WIDTH 4) 0 "solid" (make-color 0 0 0 0)))
    (overlay
     (textc (number->string armies) 12 "black")
     (rectangle (/ SLIDER-WIDTH 4) 0 "solid" (make-color 0 0 0 0))))
   (textc (number->string selected) 16 "black")))
  


(define (calc-armies bar-width max-armies x)
  (min
   (round 
   (*
    (/
     x
     bar-width)
    max-armies))
   max-armies))
    
;This is what you call to implement the slider. It returns a slider
;struct. You get the image from calling (slider-image ...) and
;the number of armies it's on with (slider-armies ...)
(define (create-slider armies x y selected)
  (make-slider
   (above
    (place-image SLIDER-HEAD
                x
                y
                SLIDER-BAR)
    (numberbar armies selected))
    (calc-armies SLIDER-WIDTH armies x)))

;Slider needs a way to check if 
;_____________________________________________________________________________________________________

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
         (make-color 244 67 54)]
        [(equal? (system-player-turn model) 1)
         (make-color 255 235 59)]
        [(equal? (system-player-turn model) 2)
         (make-color 33 150 243)]
        [(equal? (system-player-turn model) 3)
         (make-color 0 230 118)]
        [(equal? (system-player-turn model) 4)
         (make-color 123 31 162)]
        [(equal? (system-player-turn model) 5)
         (make-color 255 145 0)]
        [else "white"]
        )
  )
;This shows the toolbar on the bottom of the HUD.
;System (model, used to grab info) -> Image (toolbar)
(define (toolbar model)
  (beside
   (overlay
    (cond [(equal? DEBUG 0)
           (textc (string-append "Player " (number->string (+ 1 (system-player-turn model)))) 16 "black")]
          [else (textc (system-debug model) 16 "black")])
    (square 75 "solid" (turncolor model))
    )
   ;No more dice button! Woohoo!
   (cond [(equal? (system-screen model) "slider_warning" )
          SLIDER-WARN
          ]
         [else (die-bar (system-dicelist model))]
         )
   (overlay
    (textc (cond [(equal? (system-turn-stage model) "recruit")
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
   (cond [(equal? (system-screen model) "cards")
          SUBMIT-BUTTON]
         [else CARD-BUTTON]
         )
   (overlay
    (textc (string-append
            (number->string   (player-reserved-armies (select-player (system-playerlist model) (system-player-turn model))))
            (cond [(equal? (player-reserved-armies (select-player (system-playerlist model) (system-player-turn model)))
                           1)
                   " army in reserves."]
                  [else " armies in reserves."]
                  )
            )
           
          16 "orange")
          
    (rectangle 160 75 "solid" "purple"))
   (cond [(or
           (equal? (system-turn-stage model) "attack")
           (equal? (system-turn-stage model) "recruit"));Adding more later to this [BOOKMARK] 
          (slider-image (system-slider-store model))
          ]
          
         [else empty-image])
   )
  )

(define (card-create card)
  (overlay
   (above
    (textc (card-territory card) 16 "black")
    (textc (card-unit card) 16 "black")
    )
   (rectangle 100 145 "solid" "white")
   )
  )


;Card-Buncher - Stack images of cards next to each other
(define (card-buncher cardleest)
  (cond [(empty? cardleest) (empty-scene 0 0)]
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
                                                  (system-territory-selected model) (system-territory-list model))
                                                 )
                                                )
                                             )
                         )
          ]
    )
  )

;tooltip-width: Determines how wide the tooltip should be in px based off of a string
;String (name of territory) -> Number (tooltip width)
(define (tooltip-width name)
  (max
   (+
    (* 8 (string-length name))
    25)
  131)
  )

 

;HANDLERS
(define (render model)
  ;Render is the draw handler. It interprets various elements of the model, such as the screen the player
  ;should see at a given moment or on a given event
  ;Ex: if the screen element of the model is "splash", the "splash" screen displays.
  (cond [(equal? (system-screen model) "splash")
         ;This is the first thing the player sees, purely aesthetic.
         SPLASH]
        [(equal? (system-screen model) "playerscrn")
         ;This screen chooses the amount of players.
         (overlay/align "left" "center"
                        (textc (string-append (number->string (system-x model)) " , " (number->string (system-y model))) 16 "black")
                        (overlay/align "center" "top"
          PLAYERSCRN
          (empty-scene 1250 1200)))]
        [(or
          (equal? (system-screen model) "gameplay")
          (equal? (system-screen model) "slider_warning")
          )
         ;This screen is where the board and toolbar are located, and is the main screen of the game.
         (above
          (cond [(not (equal? (system-territory-selected model) "null"))
                 ;*****************************************************!!!!!!Work on null is needed.
                 (place-image (overlay
                               (above
                                (textc (system-territory-selected model) 16 "black")
                                (textc (who-owns? model) 12 "black")
                                (textc (string-append
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
                               (rectangle (tooltip-width (system-territory-selected model)) 50 "solid" (playercolor model))
                               )
                              (system-x model) (system-y model)
                              BOARD)]
                [else BOARD]
                )          
          (toolbar model))]
        [(equal? (system-screen model) "cards")
          (overlay
           (overlay/align "right" "top" X
                          
                          (overlay/align "left" "center"
                                         (beside (rectangle 10 0 "solid" "black") 
                                                 (card-buncher 
                                                  (player-card-list (system-card-list model) (system-player-turn model))
                                                  )
                                                 )
                                         (rectangle 700 200 "solid" (make-color 128 0 0))
                                         )
                          )
           
           (above
            (cond [(not (equal? (system-territory-selected model) "null"))
                   (place-image (overlay
                                 (above
                                  (textc (system-territory-selected model) 16 "black")
                                  (textc "Player who owns" 12 "black"))
                                 (rectangle 100 50 "solid" (playercolor model)))
                                (system-x model) (system-y model)
                                BOARD)]
                  [else BOARD])
            (toolbar model))
          )]
        [else (error "Well, this is embarassing: render could not detect a valid screen. Contact a developer and yell at them")]
        ;Nononononono bad bad bad: render cannot return a model, only an image.
        )
  )

#| GLOBALLY:
Min y: 415
Max y: 560

Card 1:
Min x: 313
Max x: 413

Card 2:
Min x: 417 
Max x: 517

Card 3:
Min x: 521
Max x: 621

Card 4:
Min x: 625
Max x: 725

Card 5:
Min x: 729
Max x: 829

Card 6:
Min x: 833
Max x: 933
|#

;which-card? determines which card a given coordinate pair is over. This is combined with several mouse functions to act on cards.
;If the pair is not over a card, then it returns null.
;Number (x) Number (y) -> Number(card index) OR Null
(define (which-card? x y)
  (cond [(and (>= y 415) (<= y 560))
         (cond [(and (>= x 313) (<= x 413))
                0]
               [(and (>= x 417) (<= x 517))
                1]
               [(and (>= x 521) (<= x 621))
                2]
               [(and (>= x 625) (<= x 725))
                3]
               [(and (>= x 729) (<= x 829))
                4]
               [(and (>= x 833) (<= x 933))
                5]
               [else -1]
               )]
        [else -1]
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
                        (< x 875)
                        (> x 375)
                        )
                       (cond [(and
                               (<= y 274)
                               (> y 174))
                              (struct-copy system model
                                           [playerlist (list (make-player (army-count 3) "alive" 0)
                                                             (make-player (army-count 3) "alive" 1)
                                                             (make-player (army-count 3) "alive" 2)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 374)
                               (> y 274))
                              (struct-copy system model
                                           [playerlist (list (make-player (army-count 4) "alive" 0)
                                                             (make-player (army-count 4) "alive" 1)
                                                             (make-player (army-count 4) "alive" 2)
                                                             (make-player (army-count 4) "alive" 3)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 474)
                               (> y 374))
                              (struct-copy system model
                                           [playerlist (list (make-player (army-count 5) "alive" 0)
                                                             (make-player (army-count 5) "alive" 1)
                                                             (make-player (army-count 5) "alive" 2)
                                                             (make-player (army-count 5) "alive" 3)
                                                             (make-player (army-count 5) "alive" 4)
                                                             )
                                                       ]
                                           [screen "gameplay"]
                                           )
                              ]
                             [(and
                               (<= y 574)
                               (> y 474))
                              (struct-copy system model
                                           [playerlist (list (make-player (army-count 6) "alive" 0)
                                                             (make-player (army-count 6) "alive" 1)
                                                             (make-player (army-count 6) "alive" 2)
                                                             (make-player (army-count 6) "alive" 3)
                                                             (make-player (army-count 6) "alive" 4)
                                                             (make-player (army-count 6) "alive" 5)
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
                ] [else (struct-copy system model
                                     [x x]
                                     [y y])]
                  )]
        [(or
          ;ADD NEW SCREENS HERE: (whenever game is played)
          (equal? (system-screen model) "gameplay")
          (equal? (system-screen model) "slider_warning"))
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
                    (< (distance 923 925 x y) 37.5))
                    (struct-copy
                     system model
                     [screen "cards"]
                    
                     )]
                  [else (cond [(equal? (system-turn-stage model) "init-recruit")
                               (initial-recruit model x y event)]
                              ;Will work when recruit phase function is created
                              [(equal? (system-turn-stage model) "recruit")
                               (recruit-phase model x y event)]
                              ;Will work when attack phase function is created
                               [(equal? (system-turn-stage model) "attack")
                                  ;This will obviously be implemented into the attack function overall later
                                (attack-phase model x y event)]
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
         (cond [(and (<= (distance 959 418 x y) 20)
                     (equal? event "button-down")
                     )
                ;Checks to see if mouse is on X and has clicked it, if so runs next function
                (struct-copy system model
                             [screen "gameplay"]
                             )]
               ;Here, we see if a card has indeed been clicked on, and we use its index to change its state. 
               [(and (not (equal? (which-card? x y)
                                  -1)
                          )
                     (equal? event "button-down")
                     )
                (change-card-selected (which-card? x y)
                                      model
                                      )] 
                
               ;This next part is a bit more complex. Because cards can only be turned in during the recruit phase, the game will check for it here.
               ;The distance discriminator will check if the mouse is within the boundaries of the turn-in-cards button.
               ;The event discriminator will check to see if the button has been clicked.
               ;The phase discriminator will check to see if the current phase is the recruit phase.
               ;The system will check if the cards can be turned in AFTER all of these conditions are true, as it is the most specific of the conditions.
               ;This order optimizes the performance of the function.
               [(and (< (distance 923 925 x y) 37.5)
                     (equal? event "button-down")
                     (equal? (system-turn-stage model) "recruit")
                     (can-turn-in? model)
                     )
                (get-card-bonus model)]
               ;If not true, then it returns model
               [else model]
               )]
        [else model]
        )
  )

;tooltip: a central function to risk that determines what territory is selected given coords
;Number (x) Number (y) System (model) -> String (territory selected)
(define (tooltip x y model)
  (cond [(< (distance x y 119 134) 10) "Alaska"]
        [(< (distance x y 232 136) 20) "Northwest Territory"]
        [(< (distance x y 467 95) 20) "Greenland"]
        [(< (distance x y 384 216) 20) "Quebec"]
        [(< (distance x y 297 218) 20) "Ontario"]
        [(< (distance x y 228 198) 20) "Alberta"]
        [(< (distance x y 229 297) 20) "Western United States"] 
        [(< (distance x y 315 315) 20) "Eastern United States"]
        [(< (distance x y 224 372) 20) "Central America"]
        [(< (distance x y 318 480) 10) "Venezuela"]
        [(< (distance x y 417 553) 30) "Brazil"]
        ;Rest of hitboxes were created with Griffin's hitbox determiner program.
        [(in-ellipse? 295 553 389 628 349 566 x y) "Peru"]
        [(in-ellipse? 501 228 573 309 569 243 x y) "Great Britain"]
        [(in-ellipse? 536 425 608 326 543 341 x y) "Western Europe"]
        [(in-ellipse? 523 172 601 170 560 146 x y) "Iceland"]
        [(in-ellipse? 623 216 713 123 641 132 x y) "Scandinavia"]
        [(in-ellipse? 605 319 705 263 635 247 x y) "Northern Europe"]
        [(in-ellipse? 617 381 706 368 664 337 x y) "Southern Europe"]
        [(in-ellipse? 572 587 647 495 552 476 x y) "North Africa"]
        [(in-ellipse? 646 480 753 487 703 454 x y) "Egypt"]
        [(in-ellipse? 652 636 748 633 707 587 x y) "Congo"]
        [(in-ellipse? 669 734 761 742 718 681 x y) "South Africa"]
        [(in-ellipse? 802 779 846 694 802 733 x y) "Madagascar"]
        [(in-ellipse? 735 611 808 598 752 523 x y) "East Africa"]
        [(in-ellipse? 754 481 875 430 797 381 x y) "Middle East"]
        [(in-ellipse? 821 327 928 306 852 261 x y) "Afghanistan"]
        [(in-ellipse? 906 465 995 461 934 371 x y) "India"]
        [(in-ellipse? 934 303 1074 448 1030 348 x y) "China"]
        [(in-ellipse? 986 301 1114 294 1047 258 x y) "Mongolia"]
        [(in-ellipse? 314 692 407 709 368 624 x y) "Argentina"]
        [(in-ellipse? 1157 302 1187 306 1174 224 x y) "Japan"]
        [(in-ellipse? 975 237 1086 219 1031 167 x y) "Irkutsk"]
        [(in-ellipse? 994 123 1097 122 1050 77 x y) "Yakutsk"]
        [(in-ellipse? 702 256 851 246 779 130 x y) "Ukraine"]
        [(in-ellipse? 857 217 926 204 874 125 x y) "Ural"]
        [(in-ellipse? 1089 137 1187 189 1182 93 x y) "Kamchatka"]
        [(in-ellipse? 1000 467 1076 506 1053 448 x y) "Siam"]
        [(in-ellipse? 1027 653 1105 584 1033 574 x y) "Indonesia"]
        [(in-ellipse? 1110 566 1212 611 1173 558 x y) "New Guinea"]
        [(in-ellipse? 1066 712 1180 764 1147 706 x y) "Western Australia"]
        [(in-ellipse? 1166 653 1206 806 1235 697 x y) "Eastern Australia"]
        [(in-ellipse? 922 176 1006 153 935 59 x y) "Siberia"]
        ;Null territory is used as a case that preserves the stability of territory-utilizing functions in all states of the game.
        [else  "null"]
        )
  )
  
;territory-scan: Selects a territory struct based on a keyword given.
;String (territory-name) -> Territory (of that struct)
(define (territory-scan name leest)
  (cond [(empty? leest) (error "Territory not found!")]
        [(equal? (territory-name (first leest)) name)
         (first leest)]
        [else (territory-scan name (rest leest))]
        )
  )

;Update-t is for the territory-update function. It just applies the changes
(define (update-t territory name f armies owner)
  (cond [(equal? (territory-name territory) name)
         (make-territory name (f (territory-armies territory) armies) owner (territory-adjacent-territories territory))]
        [else territory])
  )

;territory-update: Updates the territory with new owner, and adds or subtracts armies
;Operator (+/-) Number (armies to subtract) String (name of territory) List (list of territories) Number (player) -> Updated Territorylist
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
  (cond [(equal? (player-pos player1) playerpos)
         (struct-copy
          player player1
          [reserved-armies (f (player-reserved-armies player1) armies)])]
        [else player1]
        )
  )

;player-update-armies: Function that adds or subtracts armies from a specified player reserve.
;List [Players] (playerlist) Function (f) Number (armies) Number (playerpos) -> List [Players]
(define (player-update-armies playerlist f armies playerpos)
  (local
    [(define (change-p player)
       (update-player-armies player f armies playerpos))]
    (map change-p playerlist)
    )
  )



;Card functions

;player-card-list: [List card] number(playerpos) -> [List card]
;Returns a list containing all the cards that a current player owns, given a list to compare and the pos of player.
(define (player-card-list card-list playerpos)
  (cond [(empty? card-list) '()]
        [(equal? (card-owner (first card-list)) playerpos)
         (cons (first card-list)
               (player-card-list (rest card-list) playerpos)
               )]
        [else (player-card-list (rest card-list) playerpos)]
        )
  )

;card-scan Selects a territory struct based on a keyword given.
;Number (id) -> Card (of that struct)
(define (card-scan id leest)
  (cond [(empty? leest) (error "Card not found!")]
        [(equal? (card-id (first leest)) id)
         (first leest)]
        [else (card-scan id (rest leest))]
        )
  )

;Update-c is for the card-update function. It just applies the changes
(define (update-c tcard id state owner)
  (cond [(equal? (card-id tcard) id)
         (struct-copy card tcard
                      [owner owner]
                      [state state])]
        [else card]
        )
  )

;Card-update is for changing aspects of a card based on an id.
;System(model) Number (id) Number (player) String (state) List [Cards] (card-list) -> Updated Cardlist
  (define (card-update model id owner state cardlist)
  (local
    [(define
       (change-c card)
       (update-c card id state owner))]
    (struct-copy system model
                 [card-list (map change-c cardlist)]
    )
  )
)

;Change-card-selected is for changing the state of a player's card to selected based off of an index number.
;Number (index) System(model) -> System(updated cardlist)

(define (change-card-selected index model)
  ;First clause is catch all for instances in which the player has no cards.
  (cond [(empty? (cards-owned (system-card-list model)
                              (system-player-turn model)
                              )
                 )
         model]
        [else (struct-copy card (list-ref (player-card-list (system-card-list model) (system-player-turn model))
                                          index
                                          )
                           [state "active"]
                           )]
        )
  )

;***Initial Recruitment Phase***

;make-boolean-list: [List player] -> [List boolean]
;Helper function for move-on-to-recruit? function
(define (make-boolean-list plist)
   (cond [(empty? plist) '()]
         [(equal? (player-reserved-armies (first plist)) 0)
         (append (list true) 
                 (make-boolean-list (rest plist))
                 )]
         [else (append (list false)
                       (make-boolean-list (rest plist))
                       )]
         )
   )

;(check-expect (make-boolean-list (list (make-player '() '() 0 "alive" 0)))
 ;             (list true)
  ;            )

;The meat of move-on-to-recruit? function.
;move-on-to-recruit-main: [List boolean] -> boolean
(define (move-on-to-recruit-main bool-list)
  (cond [(empty? bool-list) true]
        [(equal? (first bool-list) true)
         (move-on-to-recruit-main (rest bool-list))]
        [else false]
        )
  )

;(check-expect (move-on-to-recruit-main (make-boolean-list (list (make-player '() '() 0 "alive" 0)
 ;                                                           (make-player '() '() 0 "alive" 1)
  ;                                                          (make-player '() '() 0 "alive" 2)
   ;                                                         )
    ;                                                  )
     ;                              )
      ;        true)

;(check-expect (move-on-to-recruit-main (make-boolean-list (list (make-player '() '() 0 "alive" 0)
 ;                                                           (make-player '() '() 1 "alive" 1)
  ;                                                          (make-player '() '() 0 "alive" 2)
   ;                                                         )
    ;                                                  )
     ;                              )
      ;        false)

;Takes helper functions move-on-to-recruit-main and make-boolean-list and returns a boolean depending on whether or not all armies have been used 
;by all players.
;move-on-to-recruit?: system -> boolean
;Checks to see if all players have no troops left to place and if all territories are claimed. True if so, else false.
(define (move-on-to-recruit? model)
  (and (not (any-unclaimed-terrs? (system-territory-list model)))
       (move-on-to-recruit-main (make-boolean-list (system-playerlist model)))
       )
  )

;any-unclaimed-terrs?: Checks to see if there are any territories laft to claim in the init phase.
;[List Territories] -> Boolean
(define (any-unclaimed-terrs? tlist)
  (cond [(empty? tlist) #f]
        [(equal? (territory-armies (first tlist)) 0)
         #t]
        [else (any-unclaimed-terrs? (rest tlist))]
        )
  )

;select-player: [List player] number -> player
;Returns a player with a pos attribute equal to that of the given number, given a list of players.
(define (select-player playerlist pos)
  (cond [(equal? (player-pos (first playerlist))
                 pos)
         (first playerlist)]
        [else (select-player (rest playerlist) pos)]
        )
  )

;troops-to-allocate?: system -> boolean
;Checks to see if the current player has any troops in their reserves, defined as having an amount of armies greater than 0.
;True if they do, else false.
(define (troops-to-allocate? model)
  (> (player-reserved-armies (select-player (system-playerlist model) 
                                            (system-player-turn model)
                                            )
                             )
     0)
  )
     
;turn-update: system -> number
;If the current player is the last, then play will continue with the first player.
;Else, the next player is up.
(define (turn-update model)
  (if (equal? (- (length (system-playerlist model))
                 1
                 )
              (system-player-turn model)
              )
      ;True
      0
      ;False
      (+ (system-player-turn model)
         1)
      )
  )                         

;initial-recruit: Adds one army to any one territory of a specific player based on territory selected
;System (model) -> System (model)
#|
The initial recruitment phase is relatively simple, but programming it can become complicated if one loses track of what must be updated and when.
Here is a list of conditions that covers most of the occurences of things in initial-recruit.

The list of conditions for moving on to the next phase is as follows:
- All of the troops of each player have been placed.
- All territories have been claimed.

The conditions for adding troops to territories already claimed are as follows:
- All other territories must have been claimed.
- The player must have troops to allocate.
- The player must own the territory he/she is trying to fortify.

The conditions to claim a territory are as follows:
- The territory must have no troops inside of it.
- The player must have troops to allocate.

The conditions to move on to the next player are as follows:
- The current player has claimed a territory.
OR
- The current player has fortified a claimed territory (only possible once all territories have been claimed).

ALL clauses should update the x and y coordinates, as well as territory-selected using the tooltip function.
|#
(define (initial-recruit model x y event)
  ;The first clause of this conditional will check to see if it is time to move on to the next phase.
  ;Further clauses will ensure that the turn flows as it should in gameplay.
  (cond [(move-on-to-recruit? model)
         ;If the conditions for moving on to the next phase are met, then the turn-stage will be changed to recruit.
         ;The turn state will also be changed so that it is player 1's turn once recruit is started.
         (struct-copy system model
                      [turn-stage "recruit"]
                      [player-turn 0]
                      ;Update Player 1's army count to have additional armies based on recruit functions.
                      [playerlist (player-update-armies (system-playerlist model)
                                                        +
                                                        (+ (base-armycount model)
                                                           (continent-bonus-calc 0
                                                                                 (system-territory-list model)
                                                                                 )
                                                           )
                                                        0
                                                        )]
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      )]
        ;This clause checks to see if the current player has any troops to allocate.
        ;If they do not, then play will pass to the next player.
        [(not (troops-to-allocate? model))
         (struct-copy system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      [player-turn (turn-update model)]
                      )]
        ;This clause will check to see if the player is not currently hovering over a territory.
        ;If they are not (this conditional will return true in this case), then the model will simply be returned with updated default attributes.
        [(equal? (system-territory-selected model) "null")
         (struct-copy system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      )]
        ;This clause checks to see if a territory is clicked that is not equal to "null".
        ;If so, it will check to see if the player can either claim or fortify this territory.
        [(and (equal? event "button-down")
              (not (equal? (system-territory-selected model) "null"))
              )
         ;This conditional checks to see if the player selecting the territory is the owner of that territory or can claim it.
         ;If they are, they are able to fortify/claim. If not, the model is simply updated with new x and y coordinates, as well as the territory selected.
         ;The first clause checks to see if the territory is up for claim, which require the territory to be empty and the player to have troops
         ;available for allocation.
         (cond [(and (equal? (territory-armies (territory-scan (system-territory-selected model)
                                                               (system-territory-list model)
                                                               )
                                               )
                             0)
                     )
                ;If this clause is true, the player will now claim the territory.
                ;The player will place one troop inside of the territory (meaning the territory gains an army and the player loses one),
                ;and default attributes will be updated.
                ;The turn will be changed to that of the next player using turn-update, and the player's list of claimed territories is updated.
                (struct-copy system model
                             [territory-list (territory-update + 1
                                                               (territory-name (territory-scan (system-territory-selected model)
                                                                                               (system-territory-list model)
                                                                                               )
                                                                               )
                                                               (system-territory-list model)
                                                               (system-player-turn model)
                                                               )]
                             [territory-selected (tooltip x y model)]
                             [x x]
                             [y y]
                             [playerlist (player-update-armies (system-playerlist model)
                                                               - 1
                                                               (system-player-turn model)
                                                               )]
                             [player-turn (turn-update model)]
                             )]
               ;This second clause checks to see if a player can fortify a territory.
               #| In order to be able to fortify a territory:
                    - All other territories must have been claimed.
                    - The player must have troops to allocate.
                    - The player must own the territory. |#
               [(and (equal? (territory-owner (territory-scan (system-territory-selected model)
                                                              (system-territory-list model)
                                                              )
                                              )
                         (system-player-turn model)
                         )
                     (not (any-unclaimed-terrs? (system-territory-list model)))
                     )
                ;If the player can fortify a territory, then the system model will update the territory selected to include an extra troop inside of it.
                ;It will change the player turn using turn-update function, and will also update default attributes.
                (struct-copy system model
                             [territory-list (territory-update + 1
                                                               (territory-name (territory-scan (system-territory-selected model)
                                                                                               (system-territory-list model)
                                                                                               )
                                                                               )
                                                               (system-territory-list model)
                                                               (system-player-turn model)
                                                               )]
                             [playerlist (player-update-armies (system-playerlist model)
                                                               - 1
                                                               (system-player-turn model)
                                                               )]
                             [player-turn (turn-update model)]
                             [x x]
                             [y y]
                             [territory-selected (tooltip x y model)]
                             )]
               ;If a territory cannot be claimed or fortified, then the model is updated with default attributes.
               [else (struct-copy system model
                                  [x x]
                                  [y y]
                                  [territory-selected (tooltip x y model)]
                                  )]
               )]
        ;If none of these cases apply, then the system will be updated with default attributes and initial recruitment will continue.
        [else (struct-copy system model
                           [territory-selected (tooltip x y model)]
                           [x x]
                           [y y]
                           )]
        )
  )
  
;***RECRUITMENT PHASE***

#|
The following factor into the amount of armies given to players:
- Territories(# of territories / 3, where f(t) is at minimum 3 and t is the amount of territories a player owns.) **COMPLETED**
- Continent Bonuses. **COMPLETED**
- Cards **COMPLETED**
|#

;count-territories: number(playerpos) [List territory] -> number
;Checks a given territory list to see how many territories
(define (count-territories playerpos tlist)
  (cond [(empty? tlist) 0]
        [(equal? (territory-owner (first tlist)) playerpos)
         (+ 1 
            (count-territories playerpos (rest tlist))
            )]
        [else (count-territories playerpos (rest tlist))]
        )
  )

;base-armycount: number(territories owned) -> number(army)
;Takes in a model and returns the amount of troops yielded based on territories the current player owns.
(define (base-armycount model)
  (cond [(< (floor (/ (count-territories (system-player-turn model) (system-territory-list model))
                      3)
                   )
            3)
         3]
        [else (floor (/ (count-territories (system-player-turn model) (system-territory-list model))
                        3)
                     )]
        )
  )

;Begin continent bonus functions.

;owns-asia?: number(playerpos) [List(system-territory-list) territory] -> boolean
;Checks to see if the player of given playerpos owns territories that are contained in the continent of Asia.
#|
These include:
- Afghanistan
- China
- India
- Irkutsk
- Japan
- Kamchatka
- Middle East
- Mongolia
- Siam
- Siberia
- Ural
- Yakutsk
|#
(define (owns-asia? playerpos tlist)
  (and (equal? (territory-owner (territory-scan "Afghanistan" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "China" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "India" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Irkutsk" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Japan" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Kamchatka" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Middle East" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Mongolia" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Siam" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Siberia" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Ural" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Yakutsk" tlist)) playerpos)
       )
  )

(check-expect (owns-asia? 1 DEBUG-TERRITORY-LIST)
              true)
(check-expect (owns-asia? 0 DEBUG-TERRITORY-LIST)
              false)

;owns-north-america? number(playerpos) [List(system-territory-list) territory] -> boolean
;Checks to see if the player of given playerpos owns territories that are contained in the continent of North America.
#|
These include:
- Alaska
- Alberta
- Central America
- Eastern United States
- Greenland
- Northwest Territory
- Ontario
- Quebec
- Western United States
|#
(define (owns-north-america? playerpos tlist)
  (and (equal? (territory-owner (territory-scan "Alaska" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Alberta" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Central America" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Eastern United States" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Greenland" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Northwest Territory" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Ontario" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Quebec" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Western United States" tlist)) playerpos)
       )
  )

;owns-europe? number(playerpos) [List(system-territory-list) territory] -> boolean
;Checks to see if the player of given playerpos owns territories that are contained in the continent of Europe.
#|
These include:
- Great Britain
- Iceland
- Northern Europe
- Scandinavia
- Southern Europe
- Ukraine
- Western Europe
|#
(define (owns-europe? playerpos tlist)
  (and (equal? (territory-owner (territory-scan "Great Britain" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Iceland" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Northern Europe" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Scandinavia" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Southern Europe" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Ukraine" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Western Europe" tlist)) playerpos)
       )
  )

;owns-africa? number(playerpos) [List(system-territory-list) territory] -> boolean
;Checks to see if the player of given playerpos owns territories that are contained in the continent of Africa.
#|
These include:
- Congo
- East Africa
- Egypt
- Madagascar
- North Africa
- South Africa
|#
(define (owns-africa? playerpos tlist)
  (and (equal? (territory-owner (territory-scan "Congo" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "East Africa" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Egypt" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Madagascar" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "North Africa" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "South Africa" tlist)) playerpos)
       )
  )

;owns-australia? number(playerpos) [List(system-territory-list) territory] -> boolean
;Checks to see if the player of given playerpos owns territories that are contained in the continent of Africa.
#|
These include:
- Eastern Australia
- Western Australia
- Indonesia
- New Guinea
|#
(define (owns-australia? playerpos tlist)
  (and (equal? (territory-owner (territory-scan "Eastern Australia" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Western Australia" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Indonesia" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "New Guinea" tlist)) playerpos)
       )
  )

;owns-south-america?: number(playerpos) [List(system-territory-list) territory] -> boolean
;Checks to see if the player of given playerpos owns territories that are contained in the continent of Africa.
#|
These include:
- Argentina
- Brazil
- Peru
- Venezuela
|#
(define (owns-south-america? playerpos tlist)
  (and (equal? (territory-owner (territory-scan "Argentina" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Brazil" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Peru" tlist)) playerpos)
       (equal? (territory-owner (territory-scan "Venezuela" tlist)) playerpos)
       )
  )

;continent-bonus-calc: number(playerpos) [List(system-territory-list territory] -> number
;Calculates any territory bonuses given to a player. In all cases, if a player doesn't own a continent, the bonus provided from that continent = 0.
;Continent	Bonus Armies
;Asia	           7
;North America	   5
;Europe	           5
;Africa	           3
;Australia     	   2
;South America	   2
(define (continent-bonus-calc playerpos tlist)
  ;Asia bonus is worth 7 troops if a player owns the continent.
  (+ (cond [(owns-asia? playerpos tlist)
            7]
           [else 0]
           )
     ;North America bonus is worth 5 troops if a player owns the continent.
     (cond [(owns-north-america? playerpos tlist)
            5]
           [else 0]
           )
     ;Europe bonus is worth 5 troops if a player owns the continent.
     (cond [(owns-europe? playerpos tlist)
            5]
           [else 0]
           )
     ;Africa bonus is worth 3 troops if a player owns the continent.
     (cond [(owns-africa? playerpos tlist)
            3]
           [else 0]
           )
     (cond [(owns-australia? playerpos tlist)
            2]
           [else 0]
           )
     ;South America bonus is worth 2 troops if a player owns the continent.
     (cond [(owns-south-america? playerpos tlist)
            2]
           [else 0]
           )
     )
  )

;Card Redemption Functions
;Cards will work as a tandem of front-end and back-end.
;A card menu will be drawn when clicked by the player, and hitboxes will become available when the menu is pulled up.
;The screen parameter of the system struct will be string "cards".
;I.E. (equal? (system-screen system) "cards") returns true.
 
;Some card functions will be found towards the beginning of this file in order to use them in the draw handler.
;Some card functions will be found towards the middle of this file in order to use them in the mouse handler.

;cards-owned: [List card] number(playerpos) -> [List card]
;Returns the cards owned by a particular player.
(define (cards-owned card-list playerpos)
  (cond [(empty? card-list) '()]
        [(equal? (card-owner (first card-list))
                 playerpos
                 )
         (cons (first card-list)
               (cards-owned (rest card-list) playerpos)
               )]
        [else (cards-owned (rest card-list) playerpos)]
        )
  )

;num-cards-owned: [List card] number(playerpos) -> number(cards owned by specified player)
;Calculates how many cards a player owns given a list of cards and the numerical ID of the player.
(define (num-cards-owned card-list playerpos)
  (cond [(empty? card-list) 0]
        [(equal? (card-owner (first card-list))
                 playerpos
                 )
         (+ 1
            (num-cards-owned (rest card-list) playerpos)
            )]
        [else (num-cards-owned (rest card-list) playerpos)]
        )
  )

;has-wild-card?: [List card] number(playerpos) -> boolean
;Checks to see if the player has a wild card in the deck he currently possesses.
(define (has-wild-card? card-list playerpos)
  (cond [(empty? card-list) false]
        [(equal? (card-unit (first card-list))
                 "wild"
                 )
         true]
        [else (has-wild-card? (rest card-list) playerpos)]
        )
  )

;find-reg-cards: [List card] number(playerpos) -> [List card]
;Goes through a card-list and returns the cards in that list that aren't wild cards.
(define (find-reg-cards card-list playerpos)
  (cond [(empty? card-list) '() ]
        [(equal? (card-unit (first card-list))
                 "wild"
                 )
         (find-reg-cards card-list playerpos)]
        [else (cons (first card-list) 
                    (find-reg-cards card-list playerpos)
                    )]
        )
  )

;has-two-reg-cards?: [List card] number(playerpos) -> boolean
;Checks to see if the player has two regular cards of any type in his deck.
(define (has-two-reg-cards? card-list playerpos)
  (if (>= (length (find-reg-cards card-list playerpos)) 2)
      ;Has at least 2 non-wild cards
      true
      ;Doesn't
      false
      )
  )
      
;return-same-unit: [List card] number(playerpos) string(unit) -> [List card]
;Goes through a given list of cards and returns cards with the unit type specified.
(define (return-same-unit card-list playerpos unit)
  (cond [(empty? card-list) '()]
        [(equal? (card-unit (first card-list)) unit)
         (cons (first card-list)
               (return-same-unit (rest card-list) playerpos unit)
               )]
        [else (return-same-unit (rest card-list) playerpos unit)]
        )
  )

;has-three-same-unit?: [List card] number(playerpos) -> boolean
;Checks to see if a player has 3 cards of the same type in their possesion.
(define (has-three-same-unit? card-list playerpos)
  ;Will return true if conditions stated in purpose are met, else false.
  (or (>= (length (return-same-unit card-list playerpos "infantry")) 3)
      (>= (length (return-same-unit card-list playerpos "artillery")) 3)
      (>= (length (return-same-unit card-list playerpos "cavalry")) 3)
      )
  )

;has-infantry?: [List card] number(playerpos) -> boolean
;Checks to see if the player has any infantry cards.
(define (has-infantry? card-list playerpos)
  (not (empty? (return-same-unit card-list playerpos "infantry")))
  )

;has-cavalry?
(define (has-cavalry? card-list playerpos)
  (not (empty? (return-same-unit card-list playerpos "cavalry")))
  )

;has-artillery?
(define (has-artillery? card-list playerpos)
  (not (empty? (return-same-unit card-list playerpos "artillery")))
  )

;has-one-of-each-unit?: [List card] number(playerpos) -> boolean
(define (has-one-of-each-unit? card-list playerpos)
  (and (has-infantry? card-list playerpos)
       (has-cavalry? card-list playerpos)
       (has-artillery? card-list playerpos)
       )
  )

;can-turn-in?: system(model) -> boolean
;Checks to see if a player has 3 cards available and eligible to be traded in.
#|
Players CAN'T turn in cards if they don't have a set of 3 to turn in.

Players can turn in cards if one of these three cases is true:
- The player has any 2 cards and a wild card
- The player owns 3 cards of each unit type.
- The player owns 3 cards of the same unit type.

The system is being programmed to handle these cases:
- If the player has a card list of three, the system will automatically select and turn in the three cards.
- If the player has more than 3 cards, the system will only check the list of those which the player has selected.

This discriminator, however, will always check for active cards, as the system will automatically set card sets of three to active.
|#

(define (can-turn-in? system)
  ;Does the player have less than three cards?
  (cond [(< (num-cards-owned (system-card-list system) (system-player-turn system))
            3)
         false]
        ;After this point, it is known that the user has 4+ cards.
        ;This condition checks to see if the player has a wild card in possession, 
        [(and (has-wild-card? (active-card-list (system-card-list system))
                              (system-player-turn system)
                              ) 
              (has-two-reg-cards? (active-card-list (system-card-list system))
                                  (system-player-turn system)
                                  )
              )
        true]
        ;Player doesn't have a wild card, so now we check for 3 cards of the same type.
        [(has-three-same-unit? (active-card-list (system-card-list system))
                               (system-player-turn system)
                               )
         true]
        ;They don't have three of the same type, now we check for one of each.
        [(has-one-of-each-unit? (active-card-list (system-card-list system))
                                (system-player-turn system)
                                )
         true]
        ;They don't meet any conditions.
        [else false]
        )
  )

;Functions to turn in cards.
;The main function, turn-in-cards, is actually used in the mouse handler in the cards GUI, when the screen is "cards".

;cards-bonus: real(sets) -> real
;Takes in a number which states how many card sets have been turned in and returns a number that shows how many troops
;the player should receive at that point.
(define (cards-bonus sets)
  ;First set turned in is worth 4 armies.
  (cond [(equal? sets 0)
         4]
        ;Second is 6.
        [(equal? sets 1)
         6]
        ;Third is 8.
        [(equal? sets 2)
         8]
        ;Fourth is 10;
        [(equal? sets 3)
        10]
        ;Fifth is 12
        [(equal? sets 4)
         12]
        ;Sixth is 15.
        [(equal? sets 5)
         15]
        ;Every set after this is 5 more than the number gained by the last set turned in.
        ;I.E. Seventh = 20, Eighth = 25...
        [(> sets 5)
         (+ 5
            (cards-bonus (- sets 1))
            )]
        ;Otherwise, input to function must not be a number. Useful for debugging.
        [else (error "Invalid input.")]
        )
  )

;nullify-card: System Card List[Card] -> System
;Changes the given card's value to a set of null values.
(define (nullify-card model card)
  (card-update (card-id card) "null" "inactive" (system-card-list model)) 
  )

;Use with active-card-list!
;turn-in-cards: System(model) [List card](active-cards) -> {no return type}
;Searches master card list for cards in active list and resets both the active state and owner state to "inactive" and "null", respectively.
;This function, while not returning anything, will update the cardlist in the given model. (Could be modified to return a model if needed)
(define (turn-in-cards model active-cards)
   (local
     [(define
        (nullcarder card)
        (nullify-card model card)
        )]
     (for-each nullcarder active-cards)
     )
  )

;active-card-list: [List card] -> [List card]
;Takes in the system card list and returns a list of those which are active.
(define (active-card-list cardlist)
  (cond [(empty? cardlist) '()]
        [(equal? (card-state (first cardlist))
                 "active")
         (cons (first cardlist)
               (active-card-list (rest cardlist))
               )]
        [else (active-card-list (rest cardlist))]
        )
  )

;get-card-bonus: system(model) -> system
;Takes in the system model and returns a system model with the current player's updated card list that removes the cards
;that they have turned in by choosing to turn in cards.

#|
A few events happen when cards are turned in:
- The player's card list is updated with the removal of appropriate cards.
  - These cards are "turned in", meaning their owner state is reset to default.
- The player gains extra troops depending on how many sets have been turned in.
- The system increments the total set count, which tracks how many card sets have been turned in.
|#

(define (get-card-bonus model)
  (struct-copy system model
               ;Turn in cards and add troops to player's army reserves
               [card-list (turn-in-cards model 
                                         (active-card-list (system-card-list model))
                                         )]
               [playerlist (player-update-armies (system-playerlist model) 
                                                 + (cards-bonus (system-cardsets-redeemed model))
                                                 (system-player-turn model)
                                                 )]
               ;Increment set count
               [cardsets-redeemed (+ (system-cardsets-redeemed model) 1)]
               )
  )

;The Recruit Phase Method
#|
Recruit is a repeated process throughout the game, and thus must be very dynamic, just like its siblings, Attack and Fortify.
Here is the list of conditions that cover the occurences in the recruit phase.

The list of conditions for moving on to the next phase is as follows:
- The player must have no more troops to place.
|#

;move-on-to-attack?: system(model) -> boolean
;Checks to see if the game should move on to the attack phase based on the current system model.
(define (move-on-to-attack? model)
   (not (troops-to-allocate? model))
  )

#|

Simple, right?

The conditions for adding troops to territories are as follows:
- The player must have troops to allocate.
- The player must own the territory he/she is trying to fortify with troops.
- The player cannot add more troops than is in their reserves.

Card conditions are mentioned in the comments concerning the "can-turn-in?" discriminator.
Card functions are executed by the top-level mouse-handler function, and all conditions are checked there.

Events that occur during recruit:
- The User checks the card-list.
  - In this case, card functions come into play. Refer to the comments associated with each function or the repository wiki for more details.
- The User clicks on a territory to add troops.
  - The aforementioned conditions for adding troops to territories now apply.

Territory-selected and x + y coordinates must be updated in each clause.
|#
        
(define (recruit-phase model x y event)
  (cond  [(and (equal? event "drag")
               (between? x SLIDER-OFFSET 1236)
               (between? y 910 935)
               )
          (struct-copy system model
                       [slider-store (create-slider (player-reserved-armies (select-player (system-playerlist model)
                                                                                           (system-player-turn model)))
                                                    (- x SLIDER-OFFSET)
                                                    0
                                                    (slider-armies (system-slider-store model))
                                                    )]
                       [debug "Workin"]
                       [territory-selected (tooltip x y model)]
                       [x x]
                       [y y] 
                       )]         
         [(move-on-to-attack? model)
         ;If the conditions for moving on to the next phase are met, then the turn-stage will be changed to attack.
         (struct-copy system model
                      [turn-stage "attack"]
                      [territory-selected (tooltip x y model)]
                      [x x]
                      [y y]
                      )]
        ;This clause will check to see if the player is not currently hovering over a territory.
        ;If they are not (this conditional will return true in this case), then the model will simply be returned with updated default attributes.
        [(equal? (system-territory-selected model) "null")
         (struct-copy system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      )]
        ;This clause checks to see if the player is clicking on a territory and can place troops there.
        ;If they can, it will implement the slider interface to add troops.
        [(and (equal? event "button-down")
              (not (equal? (system-territory-selected model) "null"))
              )
         ;This clause checks to see if the player selecting the territory is the owner of that territory 
         ;If they are, slider functions are implemented to add troops.
         (cond [(equal? (territory-owner (territory-scan (system-territory-selected model)
                                                         (system-territory-list model)
                                                         )
                                         )
                        (system-player-turn model)
                        )
                (struct-copy system model
                             [territory-list (territory-update +
                                                               (slider-armies (system-slider-store model))
                                                               (system-territory-selected model)
                                                               (system-territory-list model)
                                                               (territory-owner (territory-scan (system-territory-selected model)
                                                                                                (system-territory-list model))))]
                             [playerlist (player-update-armies (system-playerlist model)
                                                               -
                                                               (slider-armies (system-slider-store model))
                                                               (system-player-turn model))]
                             [x x]
                             [y y]
                             )]
               ;If the territory is not owned by the user, then the model is updated with default attributes.
               [else (struct-copy system model
                                  [x x]
                                  [y y]
                                  [territory-selected (tooltip x y model)]
                                  )]
               )]
        ;Test (delete this if you want to)
         [else (struct-copy system model
                            ;[slider-store (create-slider (player-reserved-armies (select-player (system-playerlist model)
                             ;                                                              (system-player-turn model)))
                              ;                      60
                               ;                     0
                                ;                    (slider-armies (system-slider-store model))
                                 ;                   )]
                            ;(struct-copy slider (system-slider-store model)
                             ;            [
                            [territory-selected (tooltip x y model)]
                            [x x]
                            [y y]
                            )]
         )
)

;Attack Phase
#|

Time to get to the good stuff.

The attack phase and fortification phase are unique in that they require the system to keep track of two
selected territories, which may get a little complicated.

Events that occur in the attack phase:
- The player wins the game by defeating all the other players in the game (no one owns anymore territories).
- The player rolls dice to attack the player.
- The player chooses a territory to attack from and to attack.

Attack Phase must check for win conditions first, then move on to fortify conditions.

The win conditions are simple: no other players have armies left. |#

;won-game?: [List territory] [List card] number(playerpos) -> boolean
;Checks to see if all other players have no armies remaining.
(define (won-game? t-list p-list playerpos)
  (cond [(empty? p-list) true]
        ;This clause is a catch for the current player so that the algorithm doesn't check them.
        [(equal? (player-pos (first p-list))
                 playerpos)
         (won-game? t-list (rest p-list) playerpos)]
        ;This clause checks to see if players in the list are out of territories (aka if the list is NOT empty, they are still in play).
        [(not (empty? (territories-owned t-list playerpos)))
         false]
        [else (won-game? t-list (rest p-list) playerpos)]
        )
  )


#|
We shoulda defined this sucker long ago:
|#

;DEFINE CONTRACT AND PURPOSE STATEMENT
(define (select-t-scan model)
  (territory-scan (system-territory-selected model) (system-territory-list model))
  )

;territories-owned: [List territory] number(playerpos) -> [List territory]
;Takes in a list of territories and a player's ID and returns a list of territories owned by that player.
(define (territories-owned t-list playerpos)
  (cond [(empty? t-list) '()]
        [(equal? (territory-owner (first t-list))
                 playerpos)
         (cons (first t-list)
               (territories-owned (rest t-list) playerpos)
               )]
        [else (territories-owned (rest t-list) playerpos)]
        )
  )

;___
;bt-helper: [List string] territory -> boolean
;Checks to see if a territory-name is in a list of strings, true if it is.
(define (bt-helper str-list territory)
  (cond [(empty? str-list) false]
        [(equal? (first str-list)
                 (territory-name territory)
                 )
         true]
        [else (bt-helper (rest str-list)
                         territory)]
        )
  )

;borders-territory?: territory(home) territory(border) -> [List territory]
;Takes in a home country and a country to check for bordering and returns if the countries border each other.
(define (borders-territory? home border)
  (bt-helper (territory-adjacent-territories home)
             border
             )
  )
;___

;Attack Phase
(define (attack-phase model x y event)
  (cond
  ;(cond [(won-game? (system-territory-list model)
                    ;(system-playerlist model)
                   ; (system-player-turn model)
                   ; )
         ;WIN CONDITIONS
         ;for now...
        ; model]
  ;Disabling the above for debug purposes
    ;jash is puu
        [(and (equal? event "drag")
              (between? x SLIDER-OFFSET 1236)
              (between? y 800 1000)
              )
         (struct-copy system model
                      [slider-store (create-slider ;This should someday be replaced with a placeholder for the slider whilst it is not needed
                                     (player-reserved-armies (select-player (system-playerlist model)
                                                                            (system-player-turn model)
                                                                            )
                                                             )
                                     (- x SLIDER-OFFSET)
                                     0
                                     (slider-armies (system-slider-store model))
                                     )
                                    ]
                      [debug "Workin"]
                      )]
        [(and (equal? event "button-down")
              (not (equal? (system-territory-selected model) "null"))
              (equal? (system-territory-attacked model) "null")
              
              ;(equal? player-pos (territory-owner (select-t-scan model))) 
              )
         ;Why isn't this clause evaluating to true? FOUND: Issue with player-pos.
         (struct-copy system model
                      [territory-selected (tooltip x y model)]
                      [territory-attacking (system-territory-selected model)]
                      [x x]
                      [y y]
                      [screen "slider_warning"]
                      [territory-attacked "primed"]
                      [slider-store (create-slider (- (territory-armies (territory-scan (system-territory-selected model) (system-territory-list model)))
                                                      ;This signifies that it is one less than the territory's armies
                                                      1)
                                                   (- x SLIDER-OFFSET)
                                                   0
                                                   (slider-armies (system-slider-store model))
                                                   )]
                      )]
        [(and (equal? event "button-down")
              (equal? (system-territory-attacked model) "primed")
              (borders-territory? (territory-scan (system-territory-attacking model) (system-territory-list model)) (select-t-scan model))
              (not (equal? (system-territory-selected model) "null"))
              ;VVV DOESN'T WORK VVV
              (not (equal? player-pos (territory-owner (select-t-scan model))))
              )
         (struct-copy system model

                      [territory-attacked (system-territory-selected model)]

                      )]
         ;Actual attack
         ;What has to happen:
         ;P:Attacker allocates how many troops are attacking <- THIS HAS ALREADY BEEN DONE BY THE USER
         ;J:Dice are rolled, win loss stacked up <- This is what goes in this clause
         ;P:Attacker chooses how many troops move on
         ;P:Process can repeat, attacked-territory needs to be made null again.

         ;NOTE FOR JOSH: The number of armies a player has chosen is invoked like so:
         ; (slider-armies (system-slider-store model) -> Number (armies selected by slider)

             ;Dice functions, update armies, etc.

        ;'Move on to fortify' clause 
         
        [else (struct-copy system model
                           [territory-selected (tooltip x y model)]
                           [x x]
                           [y y]
                           )]
        )
  )





;KEY HANDLER
;Stop the game using the escape key at anytime.
(define (key-handler model key)
  (cond [(equal? key "escape")
         (stop-with model)]
        [(equal? key "d")
         (struct-copy system model
                      [territory-list DEBUG-TERRITORY-LIST]
                      [screen "gameplay"]
                      [turn-stage "recruit"]
                      [player-turn 0]
                      )]
        [else model]
  )
)




;Animation includes a mouse and draw handler, as well as an initial system model.
(big-bang (make-system 
           ;No players at first, updated upon player selection
           (list)
           ;Turn starts at 0, first player
           0
           ;Initial phase is init-recruit, changes upon completion of phases
           ;Can be changed for debugging purposes.
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
           ;Can be swapped out for DEBUG-TERRITORY-LIST, which can be used to debug functions involving territories, but should always be INITIAL-CARD-LIST for release builds.
           INITIAL-TERRITORY-LIST
           ;Debug coordinates
           "LMAOBOX"
           ;Mouse x coordinate
           0
           ;Mouse y coordinate
           0
           ;Initial Card List, INITIAL-CARD-LIST, holds all cards which are modified to include owners, with system owner of 404.
           ;May be changed to DEBUG-CARD-LIST for debugging purposes, but should always be INITIAL-CARD-LIST for release builds.
           INITIAL-CARD-LIST
           ;Initial value of cardsets-redeemed is zero, and increases as a set of cards is turned in.
           0
           ;Attacking territory is null too
           "null"
           ;Territory attacked is initially null, and remains such until a territory is selected for attacking
           "null"
           ;There are no armies attacking, initially
           0
           ;Slider used in attributing armies
           (create-slider 100 0 0 0)
           )
          ;Draw Handler
          (to-draw render 1250 1200)
          ;Mouse Handler
          (on-mouse mouse-handler)
          ;Key Handler
          (on-key key-handler)
          )

(test)