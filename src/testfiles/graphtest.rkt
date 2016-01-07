#lang racket
(require "../graph.rkt")
(require picturing-programs)
(require test-engine/racket-tests)

(check-expect (in-ellipse? 0 0 -6 5 -1 4 1 0)
              #f)
(check-expect (in-ellipse? 0 0 -6 5 -1 4 0 0)
              #f)
(check-expect (in-ellipse? 2 0 -2 0 0 1 0 0)
              #t)

(check-expect (in-ellipse? 2 -2 -2 2 1 1 0 0)
              #t)

(check-expect (in-ellipse? -2000 -2000 -1000 1000 500 500 0 0)
              #t)

;Works A-OK here, with a non origin centered ellipse!
(check-expect (in-ellipse? 3 -2 -1 2 2 1 0 0)
              #t)

;Not here though?? Actual test case. Not good.
(check-expect (in-ellipse? 689 578 552 480 647 495 610 518)
              #t)

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

(test)
