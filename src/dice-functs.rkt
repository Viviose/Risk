;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)
(require "graph.rkt")

;All functions defined in this file and provided here can be accessed by other files upon request.
(provide roll-die roll-dice random-roll)

;Dice struct is provided to other files here
(provide (struct-out die))

;__________________________________________________________________________________________________________________


#|

Call create-rand-roll to form a random roll of dice in play.
Call get-attack-deaths to determine how many attacking troops have died, given a roll.
Call get-defense-deaths to determine how
|#
(define-struct die (number type) #:transparent)

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

;random-roll: number(attacking armies) number(defending armies) -> [Listof [Listof Numbers]]
;Creates a list that contains two lists of attack and defense dice.
(define (random-roll attackers defenders)
  (list (sort-rolls (roll-dice attackers))
        (sort-rolls (roll-dice defenders))
        )
  )

(test)