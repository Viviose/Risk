#lang racket
(require "../riskFunctions.rkt")
(require "../sys-lists.rkt")
(require picturing-programs)
(require test-engine/racket-tests)

(check-expect (owns-asia? 1 DEBUG-TERRITORY-LIST)
              true)
(check-expect (owns-asia? 0 DEBUG-TERRITORY-LIST)
              false)

(test)
