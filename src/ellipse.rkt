#lang racket
(require picturing-programs)
(require "graph.rkt")

(define (build-ellipse x y)
  (cond [(equal?
          (in-ellipse? 450 200 250 200 350 100 x y)
          #t)
         "black"]
        [else "green"]))

(build-image 700
             400
             build-ellipse)