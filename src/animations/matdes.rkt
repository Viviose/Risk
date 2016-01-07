#lang racket
(require picturing-programs)
(require "graph.rkt")
(provide DICE-BUTTON CARD-BUTTON SUBMIT-BUTTON SLIDER-WARN textc)

(define DICE-ICO (bitmap "imgs/diceico.png"))
(define CARD-ICO (bitmap "imgs/cardico.png"))
(define SUBMIT-ICO (bitmap "imgs/submitico.png"))

;The custom roboto fonted text function:
;textc: Prints a text image with the defined font below
;String (text to disp.) Number (height of text) String/Color (color of text) -> Image (text)
(define (textc string size color)
  (text/font string
             size
             color
             "Roboto Light"
             'default
             'normal
             'normal
             #f)
  )

(define (r x y)
  128)
(define (g x y)
  128)
(define (b x y)
  128)

(define (alph x y radius)
  (cond
    [(<= (distance x y radius radius) radius)
    (real->int (- 255
                  (max 40
                       (* 230 (/ (distance x y radius radius)
                                 radius)
                          )
                       )
                  )
               )]
    [else 0])
  )

(define (shadow-circle radius)
  (local
    [(define (a x y)
      (alph x y radius)
       )]
    (build4-image
     (* 2 radius)
     (* 2 radius)
     r g b a)
    )
  )

;(shadow-circle 100)

(define DICE-BUTTON
   (overlay
    (scale .5 DICE-ICO)
    (circle 37.5 "solid" (make-color 255 179 0))
    (shadow-circle 50)
    )
  )

(define CARD-BUTTON
  (overlay
   (scale .5 CARD-ICO)
   (circle 37.5 "solid"(make-color 98 24 129))
   (shadow-circle 50)
   )
  )

(define SUBMIT-BUTTON
  (overlay
   (scale .5 SUBMIT-ICO)
   (circle 37.5 "solid"(make-color 98 24 129))
   (shadow-circle 50)
   )
  )

(define SLIDER-WARN
  (overlay
   (textc "Make sure to select your armies with the slider before attacking!" 12 "black")
   (rectangle 375 75 "solid" "green")))
;Color will change
