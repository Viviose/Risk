#lang racket
(require "../dice-functs.rkt")
(require picturing-programs)
(require test-engine/racket-tests)

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
