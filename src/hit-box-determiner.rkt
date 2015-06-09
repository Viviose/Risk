#lang racket/gui
(require picturing-programs)
(require test-engine/racket-tests)
(define BOARD (scale .6 (bitmap "imgs/board.png")))

;TO DO: Writing the list-of-ellipses into a file
;       draw handler
;       mouse handler

(define-struct posn (x y))
;because apparently this wasn't already a thing

(define-struct masterGuy (status current-ellipse list-of-ellipses))
;status is whether or not the current-ellipse is ready for use
;current-ellipse is the ellipse currently viewed on-screen
;list-of-ellipses holds all ellipses until it's ready to be written to a file

(define-struct custom-ellipse (point-1 point-2 point-3))
;point-1 is the left point of an ellipse
;point-2 is the right point
;point-3 is the top center point

(define empty-ellipse (make-custom-ellipse empty empty empty))
(define empty-model (make-masterGuy #f empty-ellipse `()))

(define variablecarrier empty-model)
;will be used later to save the model when using a gui

;BEGIN TICK HANDLER
;on each tick, evaluates whether the current-ellipse is ready or not for establishing, as put in status
(define (ticker model)
  (cond [(equal? empty (custom-ellipse-point-1 (masterGuy-current-ellipse model))) (not-ready model)]
        [(equal? empty (custom-ellipse-point-2 (masterGuy-current-ellipse model))) (not-ready model)]
        [(equal? empty (custom-ellipse-point-2 (masterGuy-current-ellipse model))) (not-ready model)]
        [else (make-masterGuy #t (masterGuy-current-ellipse model) (masterGuy-list-of-ellipses model))]))

;resets an old model to ready-no
(define (not-ready model)
  (make-masterGuy #f (masterGuy-current-ellipse model) (masterGuy-list-of-ellipses model)))

;END TICK HANDLER

;BEGIN KEY HANDLER

;when three points are chosen, if you press enter, it's entered into the list, along with a GUI defined name
;whenever you press x, all points are reset, list is maintained
;whenever you press w, animation quits and a file is created with the list
(define (keyer model key)
  (cond [(equal? key #\return) (check-readiness model)]
        [(equal? key #\x) (reset-model model)]
        [(equal? key #\w) (write-list-to-file model)]))
         
;When enter is pressed, if all points are there, pulls up a gui to attach a string to the ellipse
(define (check-readiness model)
  (cond [(masterGuy-status model) (enter-model model)]
        [else model]))

;pulls up gui to attach a name to each ellipse
(define myFrame
  (new frame% 
       [label ""]))

(define msg
  (new message%
       [parent myFrame]
       [label "Write the name of the country here"]))

(define text-fielder
  (new text-field%
       [parent myFrame]
       [label "Name"]))

(define hpanel
  (new horizontal-panel%
       [parent myFrame]))

;from the Gui, adds the coordinates and the name from the Gui to the list-of-ellipses
(define (update-model value)
  (make-masterGuy #f 
                  empty-ellipse 
                  (append 
                   (masterGuy-list-of-ellipses variablecarrier) 
                   (make-posn 
                    (masterGuy-current-ellipse variablecarrier) 
                    value))))

(define (add-to-list object action)
  (begin
    (update-model (send text-fielder get-value))
    (send myFrame show #f)))

(define okayButton
  (new button%
       [parent hpanel]
       [label "OK"]
       [callback add-to-list]))

(define (cancel-point object action)
  (send myFrame show #f))

(define cancelButton
  (new button%
       [parent hpanel]
       [label "Cancel"]
       [callback cancel-point]))

;end GUI

;opens the GUI and sets the variablecarrier var to remember the model while the GUI is open
(define (enter-model model)
  (begin
    (send myFrame show #t)
    (set! variablecarrier model)))

;sets a model to empty
(define (reset-model model)
  (make-masterGuy #f empty-ellipse (masterGuy-list-of-ellipses model)))

(define (write-list-to-file model)
  "red")

;END KEY HANDLER

;BEGIN DRAW HANDLER

;END DRAW HANDLER

;BEGIN MOUSE HANDLER

;END MOUSE HANDLER

;(big-bang empty-model
;          (on-tick ticker)
;          (on-draw drawer)
;          (on-mouse clicker)
;          (on-key keyer))