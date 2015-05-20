;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)

;All functions defined in this file and provided here can be accessed by other files upon request.
(provide roll-die roll-dice find-sup-inf remove-max-min sort-rolls produce-rolls tally-deaths)

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

;Testing Suite for remove-max-min
(check-expect (remove-max-min > (list 2 3 4))
              (list 2 3)
              )
(check-expect (remove-max-min > (list 6 2 1))
              (list 2 1)
              )
(check-expect (remove-max-min > (list 2 3 5 5))
              (list 2 3 5)
              )
;End Testing Suite

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

;produce-rolls: number(attacking armies) number(defending armies) -> [Listof [Listof Numbers]]
;Creates a list that contains two lists of attack and defense dice.
(define (produce-rolls attackers defenders)
  (list (sort-rolls (roll-dice attackers))
        (sort-rolls (roll-dice defenders))
        )
  )

;tally-deaths-a: [Listof [Listof Numbers]] -> Number
;Takes in a list of a list of numbers, particularly those put out by produce-rolls, and calculates the amount of deaths
;sustained by the attacking force as a result of number comparisons.
(define (tally-deaths-a army-list)
  (cond [(or (empty? (first army-list))
             (empty? (second army-list))
             )
         0]
        [(>= (first (second army-list)) 
             (first (first army-list))
             )
         (+ 1
            (tally-deaths-a (list (rest (first army-list))
                                  (rest (second army-list))
                                  )
                            )
            )]
        [else (tally-deaths-a (list (rest (first army-list))
                                    (rest (second army-list))
                                    )
                              )]
        )
  )

;Testing Suite for tally-deaths-a
(check-expect (tally-deaths-a (list (list 4 3)
                                    (list 5)
                                    )
                              )
              1)
(check-expect (tally-deaths-a (list (list 3)
                                    '()
                                    )
                              )
              0)
(check-expect (tally-deaths-a (list (list 5 4 3)
                                    (list 6 3)
                                    )
                              )
              1)
(check-expect (tally-deaths-a (list (list 6 5)
                                    (list 6 5)
                                    )
                              )
              2)
;End Testing Suite              

;tally-deaths-d: [Listof [Listof Numbers]] -> [Listof Numbers]
;Takes in a list of a list of numbers, particularly those put out by produce-rolls, and calculates the amount of deaths
;sustained by the defending force as a result of number comparisons.
(define (tally-deaths-d army-list)
  (cond [(or (empty? (first army-list))
             (empty? (second army-list))
             )
         0]
        [(> (first (first army-list)) 
            (first (second army-list))
            )
         (+ 1
            (tally-deaths-d (list (rest (first army-list))
                                  (rest (second army-list))
                                  )
                            )
            )]
        [else (tally-deaths-d (list (rest (first army-list))
                                    (rest (second army-list))
                                    )
                              )]
        )
  )
;Testing Suite for tally-deaths-d
(check-expect (tally-deaths-d (list (list 4 3)
                                    (list 5)
                                    )
                              )
              0)
(check-expect (tally-deaths-d (list (list 3)
                                    '()
                                    )
                              )
              0)
(check-expect (tally-deaths-d (list (list 5 4 3)
                                    (list 6 3)
                                    )
                              )
              1)
(check-expect (tally-deaths-d (list (list 6 5)
                                    (list 6 5)
                                    )
                              )
              0)
;End Testing Suite 

;tally-deaths: [Listof [Listof Numbers]] -> [Listof Numbers]
;Takes in a list containing lists of numbers and returns a list of numbers that result from a comparison of the first items in each respective list.
;The first number in the new list will represent the deaths sustained by attacking players.
;The second number in the new list will represent the deaths sustained by defending players.
(define (tally-deaths army-list)
  (list (tally-deaths-a army-list)
        (tally-deaths-d army-list)
        )
  )

;Testing Suite for tally-deaths
(check-expect (tally-deaths (list (list 6 5)
                                  (list 6 6)
                                  )
                            )
              (list 2 0)
              )
;End Testing Suite

;Die struct functions to create compatibility with animation functions in main methods

;create-attack-die: [Listof [Listof Numbers]] -> die
;Creates a die that uses the results of produce-rolls to create a die with type "attack".
(define (create-attack-die army-list)
  (cond [(empty? (first army-list)) '()]
        [else (cons (make-die (first (first army-list))
                              "attack")
                    (create-attack-die (list (rest (first army-list))
                                             (second army-list)
                                             )
                                       )
                    )]
        )
  )

;Testing Suite for create-attack-die
(check-expect (create-attack-die (list (list 6 5 4)
                                       (list 2 3)
                                       )
                                 )
              (list (make-die 6 "attack")
                    (make-die 5 "attack")
                    (make-die 4 "attack")
                    )
              )
(check-expect (create-attack-die (list (list 5 4)
                                       (list 3)
                                       )
                                 )
              (list (make-die 5 "attack")
                    (make-die 4 "attack")
                    )
              )
(check-expect (create-attack-die (list (list 3)
                                       '()
                                       )
                                 )
              (list (make-die 3 "attack")
                    )
              )
(check-expect (create-attack-die (list '()
                                       '()
                                       )
                                 )
              '()
              )
;End Testing Suite

;create-defense-die: [Listof [Listof Numbers]] -> die
;Creates a die that uses the results of produce-rolls to create a die with type "defend".
(define (create-defense-die army-list)
  (cond [(empty? (second army-list)) '()]
        [else (cons (make-die (first (second army-list))
                              "defend")
                    (create-defense-die (list (first army-list)
                                             (rest (second army-list))
                                             )
                                       )
                    )]
        )
  )

;Testing Suite for create-attack-die
(check-expect (create-defense-die (list (list 6 5 4)
                                        (list 2 3)
                                       )
                                  )
              (list (make-die 2 "defend")
                    (make-die 3 "defend")
                    )
              )
(check-expect (create-defense-die (list (list 5 4)
                                        (list 3)
                                        )
                                  )
              (list (make-die 3 "defend")
                    )
              )
(check-expect (create-defense-die (list '()
                                        '()
                                        )
                                  )
              '()
              )
;End Testing Suite

;create-die-list: [Listof [Listof Numbers]] -> [Listof Die]
;Creates a list of die that represent the values of either attacking or defending die and their numerical values
(define (create-die-list army-list)
  (append (create-attack-die army-list)
          (create-defense-die army-list)
          )
  )

;Testing Suite for create-die-list
(check-expect (create-die-list (list (list 3 2)
                                     (list 2)
                                     )
                               )
              (list (make-die 3 "attack")
                    (make-die 2 "attack")
                    (make-die 2 "defend")
                    )
              )

(test)