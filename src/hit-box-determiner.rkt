;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname hit-box-determiner) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ())))
#lang racket
(require picturing-programs)
(define BOARD (scale .6 (bitmap "imgs/board.png")))

(define-struct masterGuy (status current-ellipse list-of-ellipses))
;status is whether or not the current-ellipse is ready for use
;current-ellipse is the ellipse currently viewed on-screen
;list-of-ellipses holds all ellipses until it's ready to be written to a file

(define-struct ellipse (point-1 point-2 point-3))
;point-1 is the left point of an ellipse
;point-2 is the right point
;point-3 is the top center point

(define empty-model (make-masterGuy "no" empty-ellipse `()))
(define empty-ellipse (make-ellipse empty empty empty))

;when three points are chosen, if you press enter, it's entered into the list, along with a GUI defined name
;whenever you press x, all points are reset, list is maintained
;whenever you press w, animation quits and a file is created with the list
(define (keyer model key)
  (cond [(equal? key #\return) (check-readiness model)]
        [(equal? key #\x) (reset-model model)]
        [(equal? key #\w) (write-list-to-file model)]))

;on each tick, evaluates whether the current-ellipse is ready or not for establishing, as put in status
(define (ticker model)
  (cond [(equal? empty (ellipse-point-1 (masterGuy-current-ellipse model))) (not-ready model)]
        [(equal? empty (ellipse-point-2 (masterGuy-current-ellipse model))) (not-ready model)]
        [(equal? empty (ellipse-point-2 (masterGuy-current-ellipse model))) (not-ready model)]
        [else (make-masterGuy "yes" (masterGuy-current-ellipse model) (masterGuy-list-of-ellipses model))]))
         
;resets an old model to ready-no
(define (not-ready model)
  (make-masterGuy "no" (masterGuy-current-ellipse model) (masterGuy-list-of-ellipses model)))

;When enter is pressed, if all points are there, pulls up a gui to attach a string to the ellipse
(define (check-readiness model)
  (cond [(equal? "yes" (masterGuy-status model)) (enter-model model)]
        [else model]))

;sets a model to empty
(define (reset-model model)
  (make-masterGuy "no" empty-ellipse (masterGuy-list-of-ellipses model)))

(define (write-list-to-file model)
  (

(big-bang empty-model
          (on-tick ticker)
          (on-draw drawer)
          (on-mouse clicker)
          (on-key keyer))