#lang racket
(require picturing-programs)
(require "graph.rkt")
(provide DICE-BUTTON CARD-BUTTON)


(define DICE-ICO (bitmap "imgs\\diceico.png"))
(define CARD-ICO (bitmap "imgs\\cardico.png"))



(define (r x y)
  128)
(define (g x y)
  128)
(define (b x y)
  128)
(define (alph x y radius)
  (cond
    [(<= (distance x y radius radius) radius)
    (real->int (- 255 (max 40(* 230 (/ (distance x y radius radius)
     radius)))))]
    [else 0]))
         
  
(define (shadow-circle radius)
  (local [
    (define (a x y)
      (alph x y radius))]
    (build4-image
   (* 2 radius)
   (* 2 radius)
   r g b a)))

;(shadow-circle 100)

(define DICE-BUTTON
  
   (overlay
    (scale .5 DICE-ICO)
    (circle 37.5 "solid" (make-color 255 179 0))
    (shadow-circle 50)))
   
   

(define CARD-BUTTON
  (overlay
   (scale .5 CARD-ICO)
   (circle 37.5 "solid"(make-color 98 24 129))
   (shadow-circle 50)))

   