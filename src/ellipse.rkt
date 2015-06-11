#lang racket
(require picturing-programs)
(require "graph.rkt")
(define BOARD (bitmap "imgs/board.png"))


(define (pix-color x1 y1 x2 y2 x3 y3 x y c)
  (cond [(equal?
          (in-ellipse? x1 y1 x2 y2 x3 y3 x y)
          #t)
         "black"]
        [else c]))
         


(define (ellipse-skew x1 y1 x2 y2 x3 y3)
  (local
    [(define (xy x y c)
       (pix-color x1 y1 x2 y2 x3 y3 x y c))]
             (map-image
              xy
              BOARD)))