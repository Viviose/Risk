#lang racket

(require picturing-programs)
;System struct (Holds a list of players and kee  ps tracks of whose turn it is)
;[System] : List (player structs) Number (0-5, depending on the player), String (what screen to show)
(define-struct system (playerlist player-turn turn-stage screen dicelist territory-selected territory-list debug x y territory-attacked)
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

(define-struct slider (image armies)
  #:transparent)

(define-struct posn (x y)
  #:transparent)

(define SLIDER-WIDTH 100)

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

(define (numberbar armies)
  (beside
   (overlay
    (text "0" 12  "black")
    (rectangle (/ SLIDER-WIDTH 5) 0 "solid" (make-color 0 0 0 0)))
   (overlay 
    (text (number->string (/ armies 4)) 12 "black")
    (rectangle (/ SLIDER-WIDTH 5) 0 "solid" (make-color 0 0 0 0)))
   (overlay
    (text (number->string (/ armies 2)) 12 "black")
    (rectangle (/ SLIDER-WIDTH 5) 0 "solid" (make-color 0 0 0 0)))
   (overlay
    (text (number->string (/ (* 3 armies) 4)) 12 "black")
    (rectangle (/ SLIDER-WIDTH 4) 0 "solid" (make-color 0 0 0 0)))
   (overlay
    (text (number->string armies) 12 "black")
    (rectangle (/ SLIDER-WIDTH 4) 0 "solid" (make-color 0 0 0 0)))))



(define (calc-armies bar-width max-armies x)
  (*
   (/
    x
    bar-width)
   max-armies))
    
;This is what you call to implement the slider. It returns a slider
;struct. You get the image from calling (slider-image ...) and
;the number of armies it's on with (slider-armies ...)
(define (create-slider armies model)
  (make-slider
   (above
    (place-image SLIDER-HEAD
                (system-x model)
                (system-y model)
                SLIDER-BAR)
    (numberbar armies))
    (calc-armies SLIDER-WIDTH armies (system-x model))))