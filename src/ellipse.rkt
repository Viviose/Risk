#lang racket
(require picturing-programs)
(require "graph.rkt")

(define (build-ellipse x y)
  (cond [(equal?
          (in-ellipse  x y)
          #t)
         "black"]
        [else "green"]))

(build-image 700
             400
             build-ellipse)