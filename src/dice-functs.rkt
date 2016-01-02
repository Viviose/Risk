;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)
(require "graph.rkt")

;All functions defined in this file and provided here can be accessed by other files upon request.

(provide roll-die roll-dice random-roll)


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


;Testing Suite for find-sup-inf
(check-expect (find-sup-inf > 0 (list 2 3 4))
              4)
(check-expect (find-sup-inf > 0 (list 2 3 6))
              6)
(check-expect (find-sup-inf > 0 (list 1))
              1)
(check-expect (find-sup-inf > 6 '())
              6)
;End Testing Suite




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

;Testing Suite for sort-rolls
(check-expect (sort-rolls (list 2 5 1))
              (list 5 2 1)
              )
(check-expect (sort-rolls (list 1 4))
              (list 4 1)
              )
(check-expect (sort-rolls (list 1))
              (list 1)
              )
;End Testing Suite

;random-roll: number(attacking armies) number(defending armies) -> roll
;Creates a roll struct that contains two lists of attack and defense dice.
(define (random-roll attackers defenders)
  (roll (sort-rolls (roll-dice attackers))
        (sort-rolls (roll-dice defenders))
        )
  )

;determine-deaths: string(attack/defend) roll(die lists) -> number
;Takes in a roll struct and a string to determine which deaths to count, and returns the amount of deaths sustained.
(define (determine-deaths type roll)
  (cond [(equal? type "attack") (compare-dice)]
        [(equal? type "defend")]
        [else (error "determine-deaths: Type parameter given is not 'attack' or 'defend.'")]
  )
)

;placeholder
(define (compare-dice) (print "placeholder"))

;attack-deaths
(test)
