#lang racket
(require picturing-programs)
(require "graph.rkt")

(define (build-ellipse x y)
  (cond [(equal?
          (in-ellipse? 537 445 607 323 552 348 x y)
          #t)
         "black"]
        [else "green"]))

(build-image 700
             700
             build-ellipse)