#lang racket
(require picturing-programs)
(require "graph.rkt")
(require "armymodifiers.rkt")

;***Initial Recruitment Phase***

;make-boolean-list: [List player] -> [List boolean]
;Helper function for move-on-to-recruit? function
(define (make-boolean-list plist)
   (cond [(empty? plist) '()]
         [(equal? (player-reserved-armies (first plist)) 0)
         (append (list true) 
                 (make-boolean-list (rest plist))
                 )]
         [else (append (list false)
                       (make-boolean-list (rest plist))
                       )]
         )
   )

(check-expect (make-boolean-list (list (make-player '() '() 0 "alive" 0)))
              (list true)
              )

;The meat of move-on-to-recruit? function.
;move-on-to-recruit-main: [List boolean] -> boolean
(define (move-on-to-recruit-main bool-list)
  (cond [(empty? bool-list) true]
        [(equal? (first bool-list) true)
         (move-on-to-recruit-main (rest bool-list))]
        [else false]
        )
  )

(check-expect (move-on-to-recruit-main (make-boolean-list (list (make-player '() '() 0 "alive" 0)
                                                            (make-player '() '() 0 "alive" 1)
                                                            (make-player '() '() 0 "alive" 2)
                                                            )
                                                      )
                                   )
              true)

(check-expect (move-on-to-recruit-main (make-boolean-list (list (make-player '() '() 0 "alive" 0)
                                                            (make-player '() '() 1 "alive" 1)
                                                            (make-player '() '() 0 "alive" 2)
                                                            )
                                                      )
                                   )
              false)

;Takes helper functions move-on-to-recruit-main and make-boolean-list and returns a boolean depending on whether or not all armies have been used 
;by all players.
;move-on-to-recruit?: system -> boolean
;Checks to see if all players have no troops left to place and if all territories are claimed. True if so, else false.
(define (move-on-to-recruit? model)
  (and (not (any-unclaimed-terrs? (system-territory-list model)))
       (move-on-to-recruit-main (make-boolean-list (system-playerlist model)))
       )
  )

;any-unclaimed-terrs?: Checks to see if there are any territories laft to claim in the init phase.
;[List Territories] -> Boolean
(define (any-unclaimed-terrs? tlist)
  (cond [(empty? tlist) #f]
        [(equal? (territory-armies (first tlist)) 0)
         #t]
        [else (any-unclaimed-terrs? (rest tlist))]
        )
  )

;select-player: [List player] number -> player
;Returns a player with a pos attribute equal to that of the given number, given a list of players.
(define (select-player playerlist pos)
  (cond [(equal? (player-pos (first playerlist))
                 pos)
         (first playerlist)]
        [else (select-player (rest playerlist) pos)]
        )
  )

;troops-to-allocate?: system -> boolean
;Checks to see if the current player has any troops in their reserves, defined as having an amount of armies greater than 0.
;True if they do, else false.
(define (troops-to-allocate? model)
  (> (player-reserved-armies (select-player (system-playerlist model) 
                                            (system-player-turn model)
                                            )
                             )
     0)
  )
     
;turn-update: system -> number
;If the current player is the last, then play will continue with the first player.
;Else, the next player is up.
(define (turn-update model)
  (if (equal? (- (length (system-playerlist model))
                 1
                 )
              (system-player-turn model)
              )
      ;True
      0
      ;False
      (+ (system-player-turn model)
         1)
      )
  )                         

;initial-recruit: Adds one army to any one territory of a specific player based on territory selected
;System (model) -> System (model)
#|
The initial recruitment phase is relatively simple, but programming it can become complicated if one loses track of what must be updated and when.
Here is a list of conditions that covers most of the occurences of things in intial-recruit.

The list of conditions for moving on to the next phase is as follows:
- All of the troops of each player have been placed.
- All territories have been claimed.

The conditions for adding troops to territories already claimed are as follows:
- All other territories must have been claimed.
- The player must have troops to allocate.
- The player must own the territory he/she is trying to fortify.

The conditions to claim a territory are as follows:
- The territory must have no troops inside of it.
- The player must have troops to allocate.

The conditions to move on to the next player are as follows:
- The current player has claimed a territory.
OR
- The current player has fortified a claimed territory (only possible once all territories have been claimed).

ALL clauses should update the x and y coordinates, as well as territory-selected with th
|#
(define (initial-recruit model x y event)
  ;The first clause of this conditional will check to see if it is time to move on to the next phase.
  ;Further clauses will ensure that the turn flows as it should in gameplay.
  (cond [(move-on-to-recruit? model)
         ;If the conditions for moving on to the next phase are met, then the turn-stage will be changed to recruit.
         ;The turn state will also be changed so that it is player 1's turn once recruit is started.
         (struct-copy system model
                      [turn-stage "recruit"]
                      [player-turn 0]
                      [x x]
                      [y y]
                      )]
        ;This clause checks to see if the current player has any troops to allocate.
        ;If they do not, then play will pass to the next player.
        [(not (troops-to-allocate? model))
         (struct-copy system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      [player-turn (turn-update model)]
                      )]
        ;This clause will check to see if the player is not currrently hovering over a territory.
        ;If they are not (this conditional will return true in this case), then the model will simply be returned with updated default attributes.
        [(equal? (system-territory-selected model) "null")
         (struct-copy system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      )]
        ;This clause checks to see if a territory is clicked that is not equal to "null".
        ;If so, it will check to see if the player can either claim or fortify this territory.
        [(and (equal? event "button-down")
              (not (equal? (system-territory-selected model) "null"))
              )
         ;This conditional checks to see if the player selecting the territory is the owner of that territory or can claim it.
         ;If they are, they are able to fortify/claim. If not, the model is simply updated with new x and y coordinates, as well as the territory selected.
         ;The first clause checks to see if the territory is up for claim, which require the territory to be empty and the player to have troops
         ;available for allocation.
         (cond [(and (equal? (territory-armies (territory-scan (system-territory-selected model)
                                                               (system-territory-list model)
                                                               )
                                               )
                             0)
                     )
                ;If this clause is true, the player will now claim the territory.
                ;The player will place one troop inside of the territory (meaning the territory gains an army and the player loses one),
                ;and default attributes will be updated.
                ;The turn will be changed to that of the next player using turn-update, and the player's list of claimed territories is updated.
                (struct-copy system model
                             [territory-list (territory-update + 1
                                                               (territory-name (territory-scan (system-territory-selected model)
                                                                                               (system-territory-list model)
                                                                                               )
                                                                               )
                                                               (system-territory-list model)
                                                               (system-player-turn model)
                                                               )]
                             [territory-selected (tooltip x y model)]
                             [x x]
                             [y y]
                             [playerlist (player-update-armies (system-playerlist model)
                                                               - 1
                                                               (system-player-turn model)
                                                               )]
                             [player-turn (turn-update model)]
                             )]
               ;This second clause checks to see if a player can fortify a territory.
               #| In order to be able to fortify a territory:
                    - All other territories must have been claimed.
                    - The player must have troops to allocate.
                    - The player must own the territory. |#
               [(and (equal? (territory-owner (territory-scan (system-territory-selected model)
                                                              (system-territory-list model)
                                                              )
                                              )
                         (system-player-turn model)
                         )
                     (not (any-unclaimed-terrs? (system-territory-list model)))
                     )
                ;If the player can fortify a territory, then the system model will update the territory selected to include an extra troop inside of it.
                ;It will change the player turn using turn-update function, and will also update default attributes.
                (struct-copy system model
                             [territory-list (territory-update + 1
                                                               (territory-name (territory-scan (system-territory-selected model)
                                                                                               (system-territory-list model)
                                                                                               )
                                                                               )
                                                               (system-territory-list model)
                                                               (system-player-turn model)
                                                               )]
                             [playerlist (player-update-armies (system-playerlist model)
                                                               - 1
                                                               (system-player-turn model)
                                                               )]
                             [player-turn (turn-update model)]
                             [x x]
                             [y y]
                             [territory-selected (tooltip x y model)]
                             )]
               ;If a territory cannot be claimed or fortified, then the model is updated with default attributes.
               [else (struct-copy
                      system model
                      [x x]
                      [y y]
                      [territory-selected (tooltip x y model)]
                      )]
               )]
        ;If none of these cases apply, then the system will be updated with default attributes and initial recruitment will continue.
        [else (struct-copy system model
                           [territory-selected (tooltip x y model)]
                           [x x]
                           [y y]
                           )]
        )
  )