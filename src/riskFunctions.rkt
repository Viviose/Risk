#lang racket

(require picturing-programs)
(require test-engine/racket-tests)


(define board (scale .8 (bitmap "imgs/board.png")))
(define titlescrn (bitmap "imgs/titlescreen.jpg"))

;System struct (Holds a list of players and keeps tracks of whose turn it is)
;[System] : List (player structs) Number (0-5, depending on the player), String (what screen to show)
(define-struct system (playerlist player-turn turn-stage screen)
  #:transparent)

;Player struct (Holds the information of each player)
;[Player] : List (card structs) List (strings) Number (armies) String (status)
(define-struct player (cardlist territories-owned reserved-armies status)
  #:transparent) 

;Card struct (Holds the information for each card)
;[Card]: String (unit name) String (territory value)
(define-struct card (unit territory)
  #:transparent)


;The number of armies per player
;Number -> Number
(define (army-count players)
  (cond [(equal? players 3) 35]
        [(equal? players 4) 30]
        [(equal? players 5) 25]
        [(equal? players 6) 20]))


;SCREEN SECTION: Make screens here

(define (button string x y color)
  (above
   (overlay
    (text string (/ y 2) "white")
    (rectangle x y "solid" color))
   (rectangle x 2  "solid" "black")))


(define splash
  (overlay
   (text "\n\nClick anywhere to continue" 60 "black")
   (scale 1.8 titlescrn)
   )) 

(define playerscrn
  (overlay
   
   (above
    (text "How many players will be joining us?" 48 "white")
    (button "3 players" 500 100 "red")
    (button "4 players" 500 100 "red")
    (button "5 players" 500 100 "red")
    (button "6 players" 500 100 "red"))
   (rectangle 1000 700 "solid" "green")))

;HANDLERS
(define (render model)
  ;Render is the draw handler. It interprets various elements of the model, such as the screen the player
  ;should see at a given moment or on a given event
  ;Ex: if the screen element of the model is "splash", the "splash" screen displays.
  (cond [(equal? (system-screen model) "splash")
         splash]
        [(equal? (system-screen model) "playerscrn")
         playerscrn]
        [(equal? (system-screen model) "gameplay")
         board        ]))


(define (mouse-handler model x y event)
  (cond [(equal? (system-screen model) "splash")
         ;If the splash screen is clicked, show the player selection screen
         (cond [(equal? event "button-down")
                (struct-copy system model
                             [screen "playerscrn"])]
               [else model])]
        [(equal? (system-screen model) "playerscrn")
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
        [(equal? (system-screen model) "gameplay") model]
         
         [else model]))



(big-bang (make-system 
           ;Will be changed later
           (list)
           0
           "init-place"
           "splash")
          (to-draw render 1250 1200)
          (on-mouse mouse-handler))