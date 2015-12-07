;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)
(require "graph.rkt")

;All functions defined in this file and provided here can be accessed by other files upon request.
(provide roll-die roll-dice find-sup-inf remove-max-or-min sort-rolls produce-rolls tally-deaths create-die-list)

;Dice struct is provided to other files here
(provide (struct-out die))

;__________________________________________________________________________________________________________________

(define-struct die (number type) #:transparent)

;Dice functions to be called when dice are rolled in-game

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

;remove-max-or-min: function(comparison operator) [Listof Numbers] -> [Listof Numbers]
;Returns the given list without the first instance of its greatest or least character included.
(define (remove-max-or-min operator lon)
  (cond [(empty? lon) '()]
        [(equal? (first lon)
                 (find-sup-inf operator 0 lon)
                 )
         (rest lon)]
        [else (cons (first lon)
                    (remove-max-or-min operator (rest lon))
                    )]
        )
  )

;Testing Suite for remove-max-or-min
(check-expect (remove-max-or-min > (list 2 3 4))
              (list 2 3)
              )
(check-expect (remove-max-or-min > (list 6 2 1))
              (list 2 1)
              )
(check-expect (remove-max-or-min > (list 2 3 5 5))
              (list 2 3 5)
              )
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
               ) 
        ]
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

;produce-rolls: number(attacking armies) number(defending armies) -> [Listof [Listof Numbers]]
;Creates a list that contains two lists of attack and defense dice.
(define (produce-rolls attackers defenders)
  (list (sort-rolls (roll-dice attackers))
        (sort-rolls (roll-dice defenders))
        )
  )

;Possible streamlining of tally-death functions

;tally-deaths-a/d: [Listof [Listof Numbers]] -> Number
;Takes in a list of a list of numbers, particularly those put out by produce-rolls, and calculates the amount of deaths
;sustained by the force determined by an operator: 
;                                    (> for defense, <= for attacking) 
;as a result of number comparisons.
;Note that the input [Listof [Listof Numbers]] must be in the format [List [Attacking] [Defending]]

(define (tally-deaths-a/d roll-list operator)
  (cond [(or (empty? (first roll-list))
             (empty? (second roll-list))
             )
         0]
        [(operator (first (first roll-list)) 
            (first (second roll-list))
            )
         (+ 1
            (tally-deaths-a/d (list (rest (first roll-list))
                                  (rest (second roll-list))
                               )
                              operator
                            )
            )]
        [else (tally-deaths-a/d (list (rest (first roll-list))
                                    (rest (second roll-list))
                                    )
                                operator
                              )]
        )
  )

;Testing Suite for tally-deaths-a/d

;Subsuite for defense, denoted by the input >
(check-expect (tally-deaths-a/d (list (list 4 3)
                                      (list 5)
                                      )
                                >
                                )
              0)
(check-expect (tally-deaths-a/d (list (list 3)
                                      '()
                                      )
                                >
                                )
              0)
(check-expect (tally-deaths-a/d (list (list 5 4 3)
                                      (list 6 3)
                                      )
                                >
                                )
              1)
(check-expect (tally-deaths-a/d (list (list 6 5)
                                      (list 6 5)
                                      )
                                >
                                )
              0)

;Subsuite for attacking, denoted by the input <=
(check-expect (tally-deaths-a/d (list (list 4 3)
                                      (list 5)
                                      )
                                <=
                                )
              1)
(check-expect (tally-deaths-a/d (list (list 3)
                                      '()
                                      )
                                <=
                                )
              0)
(check-expect (tally-deaths-a/d (list (list 5 4 3)
                                      (list 6 3)
                                      )
                                <=
                                )
              1)
(check-expect (tally-deaths-a/d (list (list 6 5)
                                      (list 6 5)
                                      )
                                <=
                                )
              2)
;End Testing Suite

;tally-deaths: [Listof [Listof Numbers]] -> [Listof Numbers]
;Takes in a list containing lists of numbers and returns a list of numbers that result from a comparison of the first items in each respective list.
;The first number in the new list will represent the deaths sustained by attacking players.
;The second number in the new list will represent the deaths sustained by defending players.
;The only change is the use of tally-deaths-a/d
(define (tally-deaths roll-list)
  (list (tally-deaths-a/d roll-list <=)
        (tally-deaths-a/d roll-list >)
        )
  )

;Testing Suite for tally-deaths-redux
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
(define (create-attack-die roll-list)
  (cond [(empty? (first roll-list)) '()]
        [else (cons (make-die (first (first roll-list))
                              "attack")
                    (create-attack-die (list (rest (first roll-list))
                                             (second roll-list)
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

;create-defense-die: [Listof [Listof Numbers]] -> [List die]
;Creates a die that uses the results of produce-rolls to create a die with type "defend".
(define (create-defense-die roll-list)
  (cond [(empty? (second roll-list)) '()]
        [else (cons (make-die (first (second roll-list))
                              "defend")
                    (create-defense-die (list (first roll-list)
                                             (rest (second roll-list))
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
(define (create-die-list roll-list)
  (append (create-attack-die roll-list)
          (create-defense-die roll-list)
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

;create-rand-roll: [Listof [Listof Numbers]] -> [Listof Die]
;Creates a random list of rolled dice. Used for rolling dice in the game AKA master dice roller.
(define (create-rand-roll roll-list)
  (create-die-list (create-attack-die roll-list)
                   (create-defense-die roll-list)
                   )
  )

(test)