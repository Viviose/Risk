;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)
(require "animations/graph.rkt")

;All functions defined in this file and provided here can be accessed by other files upon request.

(provide (all-defined-out))


;Die struct is provided to other files here
(provide (struct-out die)
         (struct-out roll)
         )

;__________________________________________________________________________________________________________________

;die: number(roll value) string(attack or defend type) -> die
;Stores values for die that are used in rolls.
(define-struct die (number type) #:transparent)

;roll: [List die(attack)] [List die(defend)] -> roll
;Stores two lists, one filled with attack die and one with defense die.
(define-struct roll (attack defend) #:transparent)

;Dice functions to be called when dice are rolled in-game
;roll-die: anything -> die
;Rolls a die that returns a value 1-6. The input doesn't matter.
(define (roll-die null)
  (+ 1
     (random 5)
     )
  )

;roll-dice: number(armies defending/attackin) -> [Listof Numbers]
;Creates a list of numbers that contains a value for each of the dice rolled.
;Can take in any number.
(define (roll-dice armies)
  (cond [(equal? 0 armies) empty]
        [else (cons
               (roll-die "roll-who-cares-which")
               (roll-dice (- armies 1))
               )]
        )
  )

;sort-rolls: [Listof Numbers] -> [Listof Numbers]
;Sorts a list of numbers so that the greatest numbers will be at the front of the list, with the least at the end.
;I.E. (sort-rolls (list 1 2 3)) -> (list 3 2 1)
(define (sort-rolls lon)
  (cond [(empty? lon) '()]
        [else (cons (find-sup-inf > 0 lon)
                    (sort-rolls (remove-max-or-min > lon))
                    )]
        )
  )



;random-roll: number(attacking armies) number(defending armies) -> roll
;Creates a roll struct that contains two lists of attack and defense dice.
(define (random-roll attackers defenders)
  (roll (sort-rolls (roll-dice attackers))
        (sort-rolls (roll-dice defenders))
        )
  )

;Implements find-sup-inf: function(comparison operator) number(comparison value) [Listof Numbers] -> Number
;determine-deaths: string(attack/defend) roll(die lists) -> number
;Takes in a roll struct and a string to determine which deaths to count, and returns the amount of deaths sustained.
(define (determine-deaths type roll)
  (cond [(or (empty? (roll-attack roll)
                     (roll-defend roll)
                     )
            )]
        #|[]|#
        [else (print "placeholder")]
        )
  )
  #|
  (cond [(equal? type "attack")]
        [(equal? type "defend")]
        [else (error "determine-deaths: Type parameter given is not 'attack' or 'defend.'")]
  )|#
#|)|#

;defines easily editable constants for dice rendering
;default dice size in pixels
(define DICESIZE 75)
;the amount of pixels from the sides
(define DOTSPACING 5)
;the default dice circle
(define DICECIRCLE (circle 9 "solid" "white"))
;the rounded size of the corners
(define CORNERSIZE 10)
;the positions of the corners - used in rounded-square
(define CORNERPOSNS (list (list "right" "top")
                          (list "right" "bottom")
                          (list "left" "top")
                          (list "left" "bottom")))
;recursively (with foldl) add multiple overlay/align items to a base canvas
(define (overlay/align-foldl basecanvas item posns)
  (foldl (lambda (a result)
           (overlay/align (list-ref a 0)
                          (list-ref a 1)
                          item
                          result))
         basecanvas
         posns))
;creates a rounded square with a total size of width,
;with a corner radius of cornersize,
;mode and color as in other functions
(define (rounded-square width cornersize mode color)
  (local [(define straightlen (- width (* 2 cornersize)))
          (define basecanvas (square width "solid" "transparent"))
          (define r1 (rectangle width straightlen mode color))
          (define r2 (rectangle straightlen width mode color))
          (define cornercircle (circle cornersize mode color))
          (define cornercircles (overlay/align-foldl basecanvas cornercircle CORNERPOSNS))]
    (overlay cornercircles
             r1
             r2
             basecanvas)))
;defines the default locations of the dots on a dice for dice-render
(define DOTPOSNS (list
                   ;1
                   (list (list "center" "center"))
                   ;2
                   (list (list "right" "top")
                         (list "left" "bottom"))
                   ;3
                   (list (list "center" "center")
                         (list "right" "top")
                         (list "left" "bottom"))
                   ;4
                   (list (list "right" "top")
                         (list "right" "bottom")
                         (list "left" "top")
                         (list "left" "bottom"))
                   ;5
                   (list (list "center" "center")
                         (list "right" "top")
                         (list "right" "bottom")
                         (list "left" "top")
                         (list "left" "bottom"))
                   ;6
                   (list (list "right" "top")
                         (list "right" "bottom")
                         (list "left" "top")
                         (list "left" "bottom")
                         (list "left" "center")
                         (list "right" "center"))))
;renders the dice - intended to be able to be dropped in in place of dice-face
;number - 1-6
;type - "attack" or "defend"
;returns image of dice face
(define (render-dice number type)
  (local [(define dcolor (match type ["attack" "red"] ["defend" "black"]))
          (define basedice (rounded-square DICESIZE CORNERSIZE "solid" dcolor))
          (define dotcanvas (square (max 1 (- DICESIZE (* DOTSPACING 2))) "solid" dcolor))
          (define dicecircles (overlay/align-foldl dotcanvas DICECIRCLE (list-ref DOTPOSNS (- number 1))))]
  (overlay dicecircles
           basedice)))
