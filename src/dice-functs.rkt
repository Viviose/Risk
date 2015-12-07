;__________________________________________________________________________________________________________________

#lang racket
(require picturing-programs)
(require test-engine/racket-tests)
(require "graph.rkt")

;All functions defined in this file and provided here can be accessed by other files upon request.
(provide roll-die roll-dice sort-rolls produce-rolls tally-deaths create-dice-list)

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

;produce-rolls: number(attacking armies) number(defending armies) -> [Listof [Listof Numbers]]
;Creates a list that contains two lists of attack and defense dice.
(define (produce-rolls attackers defenders)
  (list (roll-dice attackers)
        (roll-dice defenders)
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
  (list (tally-deaths-a/d (list (sort-rolls (first roll-list)) (sort-rolls (second roll-list))) <=)
        (tally-deaths-a/d (list (sort-rolls (first roll-list)) (sort-rolls (second roll-list))) >)
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

;get-attack-deaths: [Listof [Listof Numbers]] -> number
;Takes in a list containing all the dice rolls from tally deaths and returns the first number in the list of deaths.
(define (get-attack-deaths roll-list)
  (first (tally-deaths roll-list))
  )

;get-defense-deaths: [Listof [Listof Numbers]] -> number
;Takes in a list containing all the dice rolls from tally deaths and returns the second number in the list of deaths.
(define (get-defense-deaths roll-list)
  (second (tally-deaths roll-list))
  )

;Die struct functions to create compatibility with animation functions in main methods

;create-attack-dice: [Listof [Listof Numbers]] -> die
;Creates a die that uses the results of produce-rolls to create a die with type "attack".
(define (create-attack-dice roll-list)
  (cond [(empty? (first roll-list)) '()]
        [else (cons (make-die (first (first roll-list))
                              "attack")
                    (create-attack-dice (list (rest (first roll-list))
                                              (second roll-list)
                                              )
                                        )
                    )]
        )
  )

;Testing Suite for create-attack-dice
(check-expect (create-attack-dice (list (list 6 5 4)
                                        (list 2 3)
                                        )
                                  )
              (list (make-die 6 "attack")
                    (make-die 5 "attack")
                    (make-die 4 "attack")
                    )
              )
(check-expect (create-attack-dice (list (list 5 4)
                                        (list 3)
                                        )
                                  )
              (list (make-die 5 "attack")
                    (make-die 4 "attack")
                    )
              )
(check-expect (create-attack-dice (list (list 3)
                                        '()
                                        )
                                  )
              (list (make-die 3 "attack")
                    )
              )
(check-expect (create-attack-dice (list '()
                                        '()
                                        )
                                  )
              '()
              )
;End Testing Suite

;create-defense-dice: [Listof [Listof Numbers]] -> [List die]
;Creates a die that uses the results of produce-rolls to create a die with type "defend".
(define (create-defense-dice roll-list)
  (cond [(empty? (second roll-list)) '()]
        [else (cons (make-die (first (second roll-list))
                              "defend")
                    (create-defense-dice (list (first roll-list)
                                               (rest (second roll-list))
                                               )
                                         )
                    )]
        )
  )

;Testing Suite for create-attack-dice
(check-expect (create-defense-dice (list (list 6 5 4)
                                         (list 2 3)
                                         )
                                   )
              (list (make-die 2 "defend")
                    (make-die 3 "defend")
                    )
              )
(check-expect (create-defense-dice (list (list 5 4)
                                         (list 3)
                                         )
                                   )
              (list (make-die 3 "defend")
                    )
              )
(check-expect (create-defense-dice (list '()
                                         '()
                                         )
                                   )
              '()
              )
;End Testing Suite

;create-die-list: [Listof [Listof Numbers]] -> [Listof Die]
;Creates a list of die that represent the values of either attacking or defending die and their numerical values
(define (create-dice-list roll-list)
  (append (create-attack-dice roll-list)
          (create-defense-dice roll-list)
          )
  )

;Testing Suite for create-die-list
(check-expect (create-dice-list (list (list 3 2)
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
(define (create-rand-roll attackers defenders)
  (list (create-attack-dice (produce-rolls attackers defenders))
        (create-defense-dice (produce-rolls attackers defenders))
        )
  )

(test)