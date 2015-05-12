#lang racket
(require picturing-programs)
(require test-engine/racket-tests)

;Dice functions to be called when dice are rolled in-game

;roll-die: anything -> die
;Rolls a die that returns a value 1-6. The input doesn't matter.
(define (roll-die null)
  (+ 1
     (random 5)
     )
  )

;roll-dice: number(armies defending/attacking) -> listof-numbers
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

;find-greatest: listof-numbers -> listof-numbers
;Returns the greatest value in a given list of numbers or the given value, whichever is greater.
(define (find-greatest value lon)
  (cond [(empty? lon) value]
        [(> (first lon) value) (find-greatest (first lon) (rest lon))]
        [else (find-greatest value (rest lon))]
        )
  )

(check-expect (find-greatest 0 (list 2 3 4))
              4)
(check-expect (find-greatest 5 (list 2 3 6))
              6)
(check-expect (find-greatest 0 (list 1))
              1)
(check-expect (find-greatest 6 '())
              6)

(test)