#lang racket
(require picturing-programs)
(require test-engine/racket-tests)

;Providing all of the big lists to other files, namely riskFunctions.rkt
(provide INITIAL-CARD-LIST
         INITIAL-TERRITORY-LIST
         DEBUG-TERRITORY-LIST
         (struct-out card)
         (struct-out territory)
         )

;Structs

;Territory Struct (Holds the information of each territory)
;[territory]: string(armies) number(armies) string(owner) [List String] -> territory
(define-struct territory (name armies owner adjacent-territories)
  #:transparent)

;Card struct (Holds the information for each card)
;[Card]: String(unit-name) String(territory-name) number(card-id) [Maybe number(owner-id)] string(card-state)-> card
(define-struct card (unit territory id owner state)
  #:transparent)

;Initial list of all cards and their values in the game.
;[Card]: String(unit) String(territory) [Maybe-Number Owner] -> card
(define INITIAL-CARD-LIST (list
                           (card "infantry" "Afghanistan" 0 "null" "inactive")
                           (card "infantry" "Alaska" 1 "null" "inactive")
                           (card "infantry" "Alberta" 2 "null" "inactive")
                           (card "infantry" "Argentina" 3 "null" "inactive")
                           (card "artillery" "Brazil" 4 "null" "inactive")
                           (card "calvary" "Central America" 5 "null" "inactive")
                           (card "calvary" "China" 6 "null" "inactive")
                           (card "calvary" "Congo" 7 "null" "inactive")
                           (card "artillery" "East Africa" 8 "null" "inactive")
                           (card "infantry" "Eastern Australia" 9 "null" "inactive")
                           (card "artillery" "Eastern United States" 10 "null" "inactive")
                           (card "infantry" "Egypt" 11 "null" "inactive")
                           (card "calvary" "Great Britain" 12 "null" "inactive")
                           (card "calvary" "Greenland" 13 "null" "inactive")
                           (card "infantry" "India" 14 "null" "inactive")
                           (card "calvary" "Indonesia" 15 "null" "inactive")
                           (card "infantry" "Irkutsk" 16 "null" "inactive")
                           (card "infantry" "Japan" 17 "null" "inactive")
                           (card "calvary" "Kamchatka" 18 "null" "inactive")
                           (card "infantry" "Madagascar" 19 "null" "inactive")
                           (card "artillery" "Middle East" 20 "null" "inactive")
                           (card "artillery" "Mongolia" 21 "null" "inactive")
                           (card "calvary" "New Guinea" 22 "null" "inactive")
                           (card "infantry" "North Africa" 23 "null" "inactive")
                           (card "calvary" "Northern Europe" 24 "null" "inactive")
                           (card "artillery" "Northwest Territory" 25 "null" "inactive")
                           (card "calvary" "Ontario" 26 "null" "inactive")
                           (card "calvary" "Peru" 27 "null" "inactive")
                           (card "artillery" "Quebec" 28 "null" "inactive")
                           (card "artillery" "Scandinavia" 29 "null" "inactive")
                           (card "artillery" "Siam" 30 "null" "inactive")
                           (card "artillery" "Siberia" 31 "null" "inactive")
                           (card "artillery" "South Africa" 32 "null" "inactive")
                           (card "calvary" "Southern Europe" 33 "null" "inactive")
                           (card "artillery" "Ukraine" 34 "null" "inactive")
                           (card "calvary" "Ural" 35 "null" "inactive")
                           (card "artillery" "Venezuela" 36 "null" "inactive")
                           (card "artillery" "Western Australia" 37 "null" "inactive")
                           (card "infantry" "Western Europe" 38 "null" "inactive")
                           (card "infantry" "Western United States" 39 "null" "inactive")
                           (card "calvary" "Yakutsk" 40 "null" "inactive")
                           ;Two Wild Cards
                           (card "wild" "Wild Card 1" 41 "null" "inactive")
                           (card "wild" "Wild Card 2" 42 "null" "inactive")
                           )
  )

;List of all territories
;[territory]: string(armies) number(armies) string(owner) [List String] -> territory
(define INITIAL-TERRITORY-LIST (list 
                                ;North America
                                (territory "Alaska" 0 "null" (list "Northwest Territory"
                                                                   "Alberta"
                                                                   "Kamchatka")
                                           )
                                (territory "Alberta" 0 "null"(list "Ontario"
                                                                   "Northwest Territory"
                                                                   "Western United States"
                                                                   "Alaska")
                                           )
                                (territory "Central America" 0 "null" (list "Venezuela"
                                                                            "Eastern United States"
                                                                            "Western United States"
                                                                            )
                                           )
                                (territory "Eastern United States" 0 "null" (list "Western United States"
                                                                                  "Ontario"
                                                                                  "Quebec"
                                                                                  "Central America"
                                                                                  )
                                           )
                                (territory "Greenland" 0 "null" (list "Northwest Territory"
                                                                      "Ontario"
                                                                      "Quebec"
                                                                      "Iceland"
                                                                      )
                                           )
                                (territory "Northwest Territory" 0 "null" (list "Alaska"
                                                                                "Alberta"
                                                                                "Ontario"
                                                                                "Greenland"
                                                                                )
                                           )
                                (territory "Ontario" 0 "null" (list "Greenland"
                                                                    "Quebec"
                                                                    "Northwest Territory"
                                                                    "Alberta"
                                                                    "Western United States"
                                                                    "Eastern United States"
                                                                    )
                                           )
                                (territory "Quebec" 0 "null" (list "Greenland"
                                                                   "Ontario"
                                                                   "Eastern United States"
                                                                   )
                                           )
                                (territory "Western United States" 0 "null" (list "Alberta"
                                                                                  "Eastern United States"
                                                                                  "Central America"
                                                                                  "Ontario"
                                                                                  )
                                           )
                                ;South America
                                (territory "Argentina" 0 "null" (list "Brazil"
                                                                      "Peru"
                                                                      )
                                           )
                                (territory "Brazil" 0 "null" (list "Peru"
                                                                   "Venezuela"
                                                                   "Argentina"
                                                                   "North Africa"
                                                                   )
                                           )
                                (territory "Peru" 0 "null" (list "Argentina"
                                                                 "Venezuela"
                                                                 "Brazil"
                                                                 )
                                           )
                                (territory "Venezuela" 0 "null" (list "Brazil"
                                                                      "Peru"
                                                                      "Central America"
                                                                      )
                                           )
                                ;Europe
                                (territory "Great Britain" 0 "null" (list "Iceland"
                                                                          "Western Europe"
                                                                          "Scandinavia"
                                                                          "Northern Europe"
                                                                          )
                                           )
                                (territory "Iceland" 0 "null" (list "Greenland"
                                                                    "Great Britain"
                                                                    "Scandinavia"
                                                                    )
                                           )
                                (territory "Northern Europe" 0 "null" (list "Great Britain"
                                                                            "Western Europe"
                                                                            "Southern Europe"
                                                                            "Ukraine"
                                                                            )
                                          )
                                (territory "Scandinavia" 0 "null" (list "Iceland"
                                                                        "Great Britain"
                                                                        "Ukraine"
                                                                        )
                                           )
                                (territory "Southern Europe" 0 "null" (list "Northern Europe"
                                                                            "Western Europe"
                                                                            "North Africa"
                                                                            "Egypt"
                                                                            "Middle East"
                                                                            )
                                           )
                                (territory "Ukraine" 0 "null" (list "Northern Europe"
                                                                    "Scandinavia"
                                                                    "Southern Europe"
                                                                    "Ural"
                                                                    "Afghanistan"
                                                                    "Middle East"
                                                                    )
                                           )
                                (territory "Western Europe" 0 "null" (list "North Africa"
                                                                           "Great Britain"
                                                                           "Northern Europe"
                                                                           "Southern Europe"
                                                                           )
                                           )
                                ;Africa
                                (territory "Congo" 0 "null" (list "North Africa"
                                                                  "East Africa"
                                                                  "South Africa"
                                                                  )
                                           )
                                (territory "East Africa" 0 "null" (list "Egypt"
                                                                        "Congo"
                                                                        "South Africa"
                                                                        "Madagascar"
                                                                        "North Africa"
                                                                        )
                                           )
                                (territory "Egypt" 0 "null" (list "Southern Europe"
                                                                  "Middle East"
                                                                  "North Africa"
                                                                  "East Africa"
                                                                  )
                                           )
                                (territory "Madagascar" 0 "null" (list "East Africa"
                                                                       "South Africa"
                                                                       )
                                           )
                                (territory "North Africa" 0 "null" (list "Brazil"
                                                                         "Egypt"
                                                                         "Western Europe"
                                                                         "Congo"
                                                                         "East Africa"
                                                                         )
                                           )
                                (territory "South Africa" 0 "null" (list "Madagascar"
                                                                         "Congo"
                                                                         "East Africa"
                                                                         )
                                           )
                                ;Asia
                                (territory "Afghanistan" 0 "null" (list "Middle East"
                                                                        "India"
                                                                        "China"
                                                                        "Ural"
                                                                        "Ukraine"
                                                                        )
                                           )
                                (territory "China" 0 "null" (list "India"
                                                                  "Siam"
                                                                  "Afghanistan"
                                                                  "Mongolia"
                                                                  "Siberia"
                                                                  "Ural"
                                                                  )
                                           )
                                (territory "India" 0 "null" (list "Siam"
                                                                  "Middle East"
                                                                  "Afghanistan"
                                                                  "China"
                                                                  )
                                           )
                                (territory "Irkutsk" 0 "null" (list "Yakutsk"
                                                                    "Kamchatka"
                                                                    "Siberia"
                                                                    "Mongolia"
                                                                    )
                                           )
                                (territory "Japan" 0 "null" (list "Mongolia"
                                                                  "Kamchatka"
                                                                  )
                                           )
                                (territory "Kamchatka" 0 "null" (list "Yakutsk"
                                                                      "Alaska"
                                                                      "Irkutsk"
                                                                      "Mongolia"
                                                                      )
                                           ) 
                                (territory "Middle East" 0 "null" (list "Egypt"
                                                                        "India"
                                                                        "Afghanistan"
                                                                        "Ukraine"
                                                                        "Southern Europe"
                                                                        )
                                           )
                                (territory "Mongolia" 0 "null" (list "China"
                                                                     "Japan"
                                                                     "Irkutsk"
                                                                     "Kamchatka"
                                                                     "Siberia"
                                                                     )
                                           )
                                (territory "Siam" 0 "null" (list "Indonesia"
                                                                 "China"
                                                                 "India"
                                                                 )
                                           )
                                (territory "Siberia" 0 "null" (list "Ural"
                                                                    "China"
                                                                    "Mongolia"
                                                                    "Irkutsk"
                                                                    "Yakutsk"
                                                                    )
                                           )
                                (territory "Ural" 0 "null" (list "Ukraine"
                                                                 "Afghanistan"
                                                                 "Siberia"
                                                                 "China"
                                                                 )
                                           )
                                (territory "Yakutsk" 0 "null" (list "Siberia"
                                                                    "Irkutsk"
                                                                    "Kamchatka"
                                                                    )
                                           )
                                ;Australia
                                (territory "Eastern Australia" 0 "null" (list "Western Australia"
                                                                              "New Guinea"
                                                                              )
                                           )
                                (territory "Indonesia" 0 "null" (list "Western Australia"
                                                                      "New Guinea"
                                                                      "Siam"
                                                                      )
                                           )
                                (territory "New Guinea" 0 "null" (list "Eastern Australia"
                                                                       "Western Australia"
                                                                       "Indonesia"
                                                                       )
                                           )
                                (territory "Western Australia" 0 "null" (list "Eastern Australia"
                                                                              "Indonesia"
                                                                              "New Guinea"
                                                                              )
                                           )
                                ;Null territory: For when territory scanning functions do not have a valid territory.
                                (territory "null" 9001 404 '())
                                )
  )

(define DEBUG-TERRITORY-LIST
  (list 
   ;North America
   (territory "Alaska" 1 0 (list "Northwest Territory"
                                 "Alberta"
                                 "Kamchatka")
              )
   (territory "Alberta" 4  1 (list "Ontario"
                                   "Northwest Territory"
                                   "Western United States"
                                   "Alaska")
              )
   (territory "Central America" 2 2 (list "Venezuela"
                                          "Eastern United States"
                                          "Western United States"
                                          )
              )
   (territory "Eastern United States" 3 3 (list "Western United States"
                                                "Ontario"
                                                "Quebec"
                                                "Central America"
                                                )
              )
   (territory "Greenland" 4 4 (list "Northwest Territory"
                                    "Ontario"
                                    "Quebec"
                                    "Iceland"
                                    )
              )
   (territory "Northwest Territory" 5 5 (list "Alaska"
                                              "Alberta"
                                              "Ontario"
                                              "Greenland"
                                              )
              )
   (territory "Ontario" 2 1 (list "Greenland"
                                  "Quebec"
                                  "Northwest Territory"
                                  "Alberta"
                                  "Western United States"
                                  "Eastern United States"
                                  )
              )
   (territory "Quebec" 1 4 (list "Greenland"
                                 "Ontario"
                                 "Eastern United States"
                                 )
              )
   (territory "Western United States" 11 4 (list "Alberta"
                                                 "Eastern United States"
                                                 "Central America"
                                                 "Ontario"
                                                 )
              )
   ;South America
   (territory "Argentina" 0 "null" (list "Brazil"
                                         "Peru"
                                         )
              )
   (territory "Brazil" 0 "null" (list "Peru"
                                      "Venezuela"
                                      "Argentina"
                                      "North Africa"
                                      )
              )
   (territory "Peru" 0 "null" (list "Argentina"
                                    "Venezuela"
                                    "Brazil"
                                    )
              )
   (territory "Venezuela" 0 "null" (list "Brazil"
                                         "Peru"
                                         "Central America"
                                         )
              )
   ;Europe
   (territory "Great Britain" 0 "null" (list "Iceland"
                                             "Western Europe"
                                             "Scandinavia"
                                             "Northern Europe"
                                             )
              )
   (territory "Iceland" 0 "null" (list "Greenland"
                                       "Great Britain"
                                       "Scandinavia"
                                       )
              )
   (territory "Northern Europe" 0 "null" (list "Great Britain"
                                               "Western Europe"
                                               "Southern Europe"
                                               "Ukraine"
                                               )
              )
   (territory "Scandinavia" 0 "null" (list "Iceland"
                                           "Great Britain"
                                           "Ukraine"
                                           )
              )
   (territory "Southern Europe" 0 "null" (list "Northern Europe"
                                               "Western Europe"
                                               "North Africa"
                                               "Egypt"
                                               "Middle East"
                                               )
              )
   (territory "Ukraine" 0 "null" (list "Northern Europe"
                                       "Scandinavia"
                                       "Southern Europe"
                                       "Ural"
                                       "Afghanistan"
                                       "Middle East"
                                       )
              )
   (territory "Western Europe" 0 "null" (list "North Africa"
                                              "Great Britain"
                                              "Northern Europe"
                                              "Southern Europe"
                                              )
              )
   ;Africa
   (territory "Congo" 0 "null" (list "North Africa"
                                     "East Africa"
                                     "South Africa"
                                     )
              )
   (territory "East Africa" 0 "null" (list "Egypt"
                                           "Congo"
                                           "South Africa"
                                           "Madagascar"
                                           "North Africa"
                                           )
              )
   (territory "Egypt" 0 "null" (list "Southern Europe"
                                     "Middle East"
                                     "North Africa"
                                     "East Africa"
                                     )
              )
   (territory "Madagascar" 0 "null" (list "East Africa"
                                          "South Africa"
                                          )
              )
   (territory "North Africa" 0 "null" (list "Brazil"
                                            "Egypt"
                                            "Western Europe"
                                            "Congo"
                                            "East Africa"
                                            )
              )
   (territory "South Africa" 0 "null" (list "Madagascar"
                                            "Congo"
                                            "East Africa"
                                            )
              )
   ;Asia
   (territory "Afghanistan" 1 1 (list "Middle East"
                                      "India"
                                      "China"
                                      "Ural"
                                      "Ukraine"
                                      )
              )
   (territory "China" 1 1 (list "India"
                                "Siam"
                                "Afghanistan"
                                "Mongolia"
                                "Siberia"
                                "Ural"
                                )
              )
   (territory "India" 1 1 (list "Siam"
                                "Middle East"
                                "Afghanistan"
                                "China"
                                )
              )
   (territory "Irkutsk" 1 1 (list "Yakutsk"
                                  "Kamchatka"
                                  "Siberia"
                                  "Mongolia"
                                  )
              )
   (territory "Japan" 1 1 (list "Mongolia"
                                "Kamchatka"
                                )
              )
   (territory "Kamchatka" 1 1 (list "Yakutsk"
                                    "Alaska"
                                    "Irkutsk"
                                    "Mongolia"
                                    )
              ) 
   (territory "Middle East" 1 1 (list "Egypt"
                                      "India"
                                      "Afghanistan"
                                      "Ukraine"
                                      "Southern Europe"
                                      )
              )
   (territory "Mongolia" 1 1 (list "China"
                                   "Japan"
                                   "Irkutsk"
                                   "Kamchatka"
                                   "Siberia"
                                   )
              )
   (territory "Siam" 1 1 (list "Indonesia"
                               "China"
                               "India"
                               )
              )
   (territory "Siberia" 1 1 (list "Ural"
                                  "China"
                                  "Mongolia"
                                  "Irkutsk"
                                  "Yakutsk"
                                  )
              )
   (territory "Ural" 1 1 (list "Ukraine"
                               "Afghanistan"
                               "Siberia"
                               "China"
                               )
              )
   (territory "Yakutsk" 1 1 (list "Siberia"
                                  "Irkutsk"
                                  "Kamchatka"
                                  )
              )
   ;Australia
   (territory "Eastern Australia" 0 "null" (list "Western Australia"
                                                 "New Guinea"
                                                 )
              )
   (territory "Indonesia" 0 "null" (list "Western Australia"
                                         "New Guinea"
                                         "Siam"
                                         )
              )
   (territory "New Guinea" 0 "null" (list "Eastern Australia"
                                          "Western Australia"
                                          "Indonesia"
                                          )
              )
   (territory "Western Australia" 0 "null" (list "Eastern Australia"
                                                 "Indonesia"
                                                 "New Guinea"
                                                 )
              )
   ;Null territory: For when territory scanning functions do not have a valid territory.
   (territory "null" 9001 404 '())
   )
  )