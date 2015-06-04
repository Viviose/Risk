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

(check-expect (calc-angle 3 -1 4 -2)
             -45)

(check-expect (calc-angle 0 0 -6 5)
              -40)



;in-ellipse?: number(x1) number(y1) number(x2) number(y2) number (rx) number (ry) -> boolean
;Determines whether 
;Mouse is second coordinate pair, static point is first pair.
;r-x and r-y are the vertical and horizontal length of the ellipse.
;The angle-of-skew is used to calculate points if an ellipse is not aligned within an axis.

;NOTE TO SELF: Replace h-k for x2 y2 with the top point of triangle
#|(define (in-ellipse? x1 y1 x2 y2 mousex mousey r-x r-y)
  (<=
   (+
    (/
     (sqr
      (-
       (+
        (* mousex
           (cos (calc-angle x1 y1 x2 y2)
                )
           )
        (* mousey
           (sin (calc-angle x1 y1 x2 y2)
                )
           )
        )
       x2
       )
      )
     (sqr r-x)
     )
    (/
     (sqr
      (-
       (-
        (* mousey
           (cos (calc-angle x1 y1 x2 y2)
                )
           )
        (* mousex
           (sin (calc-angle x1 y1 x2 y2)
                )
           )
        )
       y2
       )
      )
     (sqr r-y)
     )
    )
   1
   )
  )

;Check expects are coming for this, it just needs some polishing with IRL math
|#


(define (h x1 x2)
  (/
   (+ x1 x2)
   2))

(define (k y1 y2)
  (/
   (+ y1 y2)
   2))


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
  (<=
   (+
    ;The first piece for X
    (/
     (sqr
       (+
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
    (/
     (sqr
       (-
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
   1
   )
  )

   (check-expect (in-ellipse? 0 0 -6 5 -1 4 1 0)
                 #f)
(check-expect (in-ellipse? 0 0 -6 5 -1 4 0 0)
                 #t)
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