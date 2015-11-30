#lang racket
;Required libraries allow for access to Racket animation library and test engine library.
(require picturing-programs)
(require test-engine/racket-tests)

;Provides access to all defined functions and variables in this file to other files.
;Currently, this will include the following functions:
#| - distance   |#
(provide between? distance slope calc-angle in-ellipse?)

;between?: number(query) number(min) number(max) -> boolean
;Checks to see if a number is within a specified bound.
(define (between? query min max)
  (and (< query max)
       (> query min)
       )
  )

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
(define (degrees-atan ratio)
  (radians->degrees (atan ratio))
  )

;slope: Number (x1) + Number (y1) + Number (x2) + Number (y2) -> Number (slope)
(define (slope x1 y1 x2 y2)
  (/
   (- y2 y1)
   (- x2 x1)
   )
  )


;calc-angle: number() number() number() number() -> number(angle in degrees)
(define (calc-angle x1 y1 x2 y2)
  (real->int (atan 
              (slope x1 y1 x2 y2))
             )
  )


(check-expect (calc-angle 0 0 -7 0)
              0)

(define (h x1 x2)
  (/
   (+ x1 x2)
   2))

(define (k y1 y2)
  (/
   (+ y1 y2)
   2))

;in-ellipse?: number(x1) number(y1) number(x2) number(y2) number(x3) number(y3) number(mouse-x) number(mouse-y) -> boolean
;Determines whether a given point is inside of a defined ellipse.
(define (in-ellipse? 
         ;rightmost coord pair
         x1
         y1
         ;leftmost coord pair
         x2
         y2
         ;center top coord pair
         x3
         y3
         ;mouse posn
         x
         y)
  (<= (+ ;The first piece for X
         (/ (sqr (+
                  (* (- x (h x1 x2))
                     (cos
                      (calc-angle x1 y1 x2 y2)
                      )
                     )
                  (* (- y (k y1 y2))
                     (sin
                      (calc-angle x1 y1 x2 y2)
                      )
                     )
                  )
                 )
            ;a
            (sqr
             (/
              (distance x1 y1 x2 y2)
              2
              ))
            )
       ;The second piece for y
         (/ (sqr (-
                  (* (- y (k y1 y2))
                     (cos (calc-angle x1 y1 x2 y2)
                          )
                     )
                  (* (- x (h x1 x2))
                     (sin (calc-angle x1 y1 x2 y2)
                          )
                     )
                  )
                 )
        ;b
            (sqr
             (distance 
              (h x1 x2)
              (k y1 y2)
              x3
              y3
              )
             )
            )
         )
      ;1 is value of comparison of the point compared to the ellipse.
      ;If the point is not within a distance less than or equal to 1 of the ellipse, the function will return false.
      1
      )
  )

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



(test)