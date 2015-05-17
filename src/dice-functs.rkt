;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)

;All functions defined in this file and provided here can be accessed by other files upon request.
(provide roll-die roll-dice find-sup-inf remove-max-min sort-rolls)

;Dice struct is provided to other files here
(provide (struct-out die))

;__________________________________________________________________________________________________________________

(define-struct die (number type)
  ;Transparent instance call was added by Josh Sanch on 5/14/15
  ;Didn't know if you left it out by mistake or planned on adding it later, so I left this comment for you in case you wanted to keep it opaque.
  #:transparent)

;Dice functions to be called when dice are rolled in-game

;roll-die: anything -> die
;Rolls a die that returns a value 1-6. The input doesn't matter.
(define (roll-die null)
  (+ 1
     (random 5)
     )
  )

;roll-dice: number(armies defending/attacking) -> [Listof Numbers]
;Creates a list of numbers that contains a value for each of the dice rolled.
;Must take in an armies value of 1, 2, or 3.
(define (roll-dice armies)
  (cond [(equal? armies 1) (list (roll-die "roll"))]
        [(equal? armies 2) (list (roll-die "roll1")
                                 (roll-die "roll2")
                                 )]
        [(equal? armies 3) (list (roll-die "roll1")
                                 (roll-die "roll2")
                                 (roll-die "roll3")
                                 )]
        )
  )

;find-sup-inf: function(comparison operator) number(comparison value) [Listof Numbers] -> Number
;Returns the greatest/least value in a given list of numbers or the given value, whichever is greater/lesser.
(define (find-sup-inf operator value lon)
  (cond [(empty? lon) value]
        [(operator (first lon) value) (find-sup-inf operator (first lon) (rest lon))]
        [else (find-sup-inf operator value (rest lon))]
        )
  )

(check-expect (find-sup-inf > 0 (list 2 3 4))
              4)
(check-expect (find-sup-inf > 0 (list 2 3 6))
              6)
(check-expect (find-sup-inf > 0 (list 1))
              1)
(check-expect (find-sup-inf > 6 '())
              6)

;remove-max-min: function(comparison operator) [Listof Numbers] -> [Listof Numbers]
;Returns the given list without the first instance of its greatest or least character included.
(define (remove-max-min operator lon)
  (cond [(empty? lon) '()]
        [(equal? (first lon)
                 (find-sup-inf operator 0 lon)
                 )
         (rest lon)]
        [else (cons (first lon)
                    (remove-max-min operator (rest lon))
                    )]
        )
  )

(check-expect (remove-max-min > (list 2 3 4))
              (list 2 3)
              )
(check-expect (remove-max-min > (list 6 2 1))
              (list 2 1)
              )
(check-expect (remove-max-min > (list 2 3 5 5))
              (list 2 3 5)
              )

;sort-rolls: [Listof Numbers] -> [Listof Numbers]
;Sorts a list of numbers so that the greatest numbers will be at the front of the list, with the least at the end.
;I.E. (sort-rolls (list 1 2 3)) -> (list 3 2 1)
(define (sort-rolls lon)
  (cond [(empty? lon) '()]
        [else (cons (find-sup-inf > 0 lon)
                    (sort-rolls (remove-max-min > lon))
                    )]
        )
  )

(check-expect (sort-rolls (list 2 5 1))
              (list 5 2 1)
              )
(check-expect (sort-rolls (list 1 4))
              (list 4 1)
              )
(check-expect (sort-rolls (list 1))
              (list 1)
              )

;attack-defend: number(attacking armies) number(defending armies) -> [Listof [Listof Numbers]]
;Creates a list that contains two lists of attack and defense dice.
(define (attack-defend attackers defenders)
  (list (sort-rolls (roll-dice attackers))
        (sort-rolls (roll-dice defenders))
        )
  )





(test)