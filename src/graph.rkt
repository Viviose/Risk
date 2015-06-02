#lang racket
;Required libraries allow for access to Racket animation library and test engine library.
(require picturing-programs)
(require test-engine/racket-tests)

;Provides access to all defined functions and variables in this file to other files.
;Currently, this will include the following functions:
#|

- distance

|#
(provide (all-defined-out))

;distance: number(x1) number(y1) number(x2) number(y2) -> number(distance between coordinates)
;Takes in four numbers, which represent the x and y coordinates of two different coordinate pairs, and finds distance
;  between them.
(define (distance x y static-x static-y)
  (sqrt (+ (sqr (- static-x x))
           (sqr (- static-y y))
           )
        )
  )

;Ellipse distance links
;http://math.stackexchange.com/questions/76457/check-if-a-point-is-within-an-ellipse
;http://math.stackexchange.com/questions/108270/what-is-the-equation-of-an-ellipse-that-is-not-aligned-with-the-axis