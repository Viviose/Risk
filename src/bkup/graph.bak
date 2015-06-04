#lang racket
;Required libraries allow for access to Racket animation library and test engine library.
(require picturing-programs)
(require test-engine/racket-tests)

;Provides access to all defined functions and variables in this file to other files.
;Currently, this will include the following functions:
#| - distance   |#
(provide (all-defined-out))

;distance: number(x1) number(y1) number(x2) number(y2) -> number(distance between coordinates)
;Takes in four numbers, which represent the x and y coordinates of two different coordinate pairs, and finds distance
;  between them. Works with circles.
(define (distance x1 y1 x2 y2)
  (sqrt (+ (sqr (- x2 x1))
           (sqr (- y2 y1))
           )
        )
  )

;Ellipse distance links
;http://math.stackexchange.com/questions/76457/check-if-a-point-is-within-an-ellipse
;http://math.stackexchange.com/questions/108270/what-is-the-equation-of-an-ellipse-that-is-not-aligned-with-the-axis

;degrees-asin: number(ratio) -> number(angle in degrees)
;Converts a result of asin into degrees.
(define (degrees-asin ratio)
  (radians->degrees (asin ratio))
  )

;calc-angle: number() number() number() number() -> number(angle in degrees)
(define (calc-angle x1 y1 x2 y2)
  (real->int (degrees-asin (/ 
                            ;Using a right triangle of sides a, b, and c, finds ratio between length of a and c.
                            ;a  
                            (distance x2 y2 x2 y1)
                            ;c
                            (distance x1 y1 x2 y2)
                            )
                           )
             )
  )

(check-expect (calc-angle 1 0 0 (sqrt 3))
              60)

;in-ellipse?: number(x1) number(y1) number(x2) number(y2) number(angle-of-skew in degrees) -> boolean
;Determines whether 
;Mouse is second coordinate pair, static point is first pair.
;r-x and r-y are the vertical and horizontal length of the ellipse.
;The angle-of-skew is used to calculate points if an ellipse is not aligned within an axis.
#;(define (in-ellipse? x1 y1 x2 y2 angle-of-skew r-x r-y)
  ...)

(test)