#lang racket/gui
(require picturing-programs)
(require test-engine/racket-tests)
(require "ellipse.rkt")
(define BOARD (scale .6 (bitmap "imgs/board.png")))

;For use: click to the left of the name, then to the right, then to the top
;          if generated hitbox is satisfactory, press "a"
;          to remove the current hitbox, press "x"

;When the gui is pulled up
;         type in the name of the region the hitbox is associated with

;To write to file
;         only one shot at this, do it all in one swoop
;         press "w", and all territories will be exported to Map-Positions/map-positions.txt in a one-line string format. I'm working on that.


(define (debug-display x)
  (display x))

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

(define empty-posn (make-posn -1 -1))
(define empty-ellipse (make-custom-ellipse empty-posn empty-posn empty-posn))
(define empty-model (make-masterGuy #f empty-ellipse `()))

(define (first-ready? model)
  (cond [(equal? (custom-ellipse-point-1 (masterGuy-current-ellipse model)) empty-posn) #f]
        [else #t]))

(define (second-ready? model)
  (cond [(equal? (custom-ellipse-point-2 (masterGuy-current-ellipse model)) empty-posn) #f]
        [else #t]))

(define (third-ready? model)
  (cond [(equal? (custom-ellipse-point-3 (masterGuy-current-ellipse model)) empty-posn) #f]
        [else #t]))

(define variablecarrier empty-model)
;will be used later to save the model when using a gui
(define change-to-varcarry #f)
;will be used to check variablecarrier and whether the model should be changed to that
(define render? #f)
(define render-rest? #t)
(define remember-scene "")

;BEGIN TICK HANDLER
;on each tick, evaluates whether the current-ellipse is ready or not for establishing, as put in status
(define (ticker model)
  (cond [change-to-varcarry (begin
                              (set! change-to-varcarry #f)
                              (set! render-rest? #t)
                              variablecarrier)]
        [(third-ready? model) (make-masterGuy #t (masterGuy-current-ellipse model) (masterGuy-list-of-ellipses model))]
        [else (not-ready model)]))

;resets an old model to ready-no
(define (not-ready model)
  (make-masterGuy #f (masterGuy-current-ellipse model) (masterGuy-list-of-ellipses model)))

(define ready-model (make-masterGuy #t empty-ellipse `()))

;END TICK HANDLER

;BEGIN KEY HANDLER

;when three points are chosen, if you press enter, it's entered into the list, along with a GUI defined name
;whenever you press x, all points are reset, list is maintained
;whenever you press w, animation quits and a file is created with the list
(define (keyer model key)
  (begin  
    (debug-display "in key handler")
    (cond [(equal? key "a") (check-readiness model)]
               [(equal? key "x") (reset-model model)]
               [(equal? key "w") (write-list-to-file model)]
               [else model])))
         
;When a is pressed, if all points are there, pulls up a gui to attach a string to the ellipse
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
  (begin (set! variablecarrier (make-masterGuy #f empty-ellipse 
                  (append 
                   (masterGuy-list-of-ellipses variablecarrier) 
                   (list (make-posn 
                    (masterGuy-current-ellipse variablecarrier) 
                    value)))))
         (set! change-to-varcarry #t)))

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
    (set! variablecarrier model)
    (send myFrame show #t)
    model))

;sets a model to empty
(define (reset-model model)
  (begin
    (set! render-rest? #t)
    (make-masterGuy #f empty-ellipse (masterGuy-list-of-ellipses model))))

;Turns a posn into a string in the format "(#, #)", or <quote><open parenthesis><number><comma><space><number><close parenthesis><quote>
(define (posn->string posny)
  (string-append "("
                 (number->string (posn-x posny))
                 ", "
                 (number->string (posn-y posny))
                 ")"))

;Creates a single line to be written to file
(define (location-posn-to-string loc-pos)
  (string-append "( "
                 (posn->string (custom-ellipse-point-1 (posn-x loc-pos)))
                 (posn->string (custom-ellipse-point-2 (posn-x loc-pos)))  ;The location of each item
                 (posn->string (custom-ellipse-point-3 (posn-x loc-pos)))
                 " "
                 (posn-y loc-pos)  ;The name of the location
                 " )"))

;Creates a string to be put into a file
(define (put-in-file listy)
  (cond [(empty? listy) ""]
        [else   (string-append 
                   (location-posn-to-string (first listy))
                   "\n"
                   (put-in-file (rest listy)))]))

;writes the current-ellipse-list to the file
(define (write-list-to-file model)
  (begin
    (define out (open-output-file "Map-Positions/map-positions.txt" #:replace 'update))
    (write (put-in-file (masterGuy-list-of-ellipses model)) out)
    (debug-display (put-in-file (masterGuy-list-of-ellipses model)))
    (close-output-port out)
    (stop-with model)
    model))

;END KEY HANDLER

;BEGIN DRAW HANDLER

(define rad 5)
(define point (circle rad "solid" "blue"))
(define (place-circle posny radius)
  (beside (rectangle (- (posn-x posny) radius) 0 "solid" "green") (above (rectangle 0 (- (posn-y posny) radius) "solid" "green") point)))

(define (make-text-of model)
  (above (beside (text "x:" 18 "black")
          (text (number->string (posn-x (custom-ellipse-point-1 (masterGuy-current-ellipse model)))) 18 "black")
          (text "y:" 18 "black")
          (text (number->string (posn-y (custom-ellipse-point-1 (masterGuy-current-ellipse model)))) 18 "black"))
         (beside (text "x:" 18 "black")
          (text (number->string (posn-x (custom-ellipse-point-2 (masterGuy-current-ellipse model)))) 18 "black")
          (text "y:" 18 "black")
          (text (number->string (posn-y (custom-ellipse-point-2 (masterGuy-current-ellipse model)))) 18 "black"))
         (beside (text "x:" 18 "black")
          (text (number->string (posn-x (custom-ellipse-point-3 (masterGuy-current-ellipse model)))) 18 "black")
          (text "y:" 18 "black")
          (text (number->string (posn-y (custom-ellipse-point-3 (masterGuy-current-ellipse model)))) 18 "black"))))

(define (make-model-ellipse model)
  (ellipse-skew (posn-x (custom-ellipse-point-1 (masterGuy-current-ellipse model))) 
                (posn-y (custom-ellipse-point-1 (masterGuy-current-ellipse model)))
                (posn-x (custom-ellipse-point-2 (masterGuy-current-ellipse model))) 
                (posn-y (custom-ellipse-point-2 (masterGuy-current-ellipse model)))
                (posn-x (custom-ellipse-point-3 (masterGuy-current-ellipse model))) 
                (posn-y (custom-ellipse-point-3 (masterGuy-current-ellipse model)))
  ))

(define (place-model-ellipse model)
  (beside (rectangle (posn-x (custom-ellipse-point-1 (masterGuy-current-ellipse model))) 0 "solid" "orange")
          (above (rectangle 0 (posn-y (custom-ellipse-point-3 (masterGuy-current-ellipse model))) "solid" "orange")
                 (make-model-ellipse model))))

(define (interceptor model)
  (cond [render-rest? (drawer model)]
        [else remember-scene]))

(define (drawer model)
   (cond [(and render? (third-ready? model)) 
           (begin
             (set! render? #f)
             (set! render-rest? #f)
             
             (set! remember-scene (overlay
           (make-model-ellipse model)
           (place-circle (custom-ellipse-point-1 (masterGuy-current-ellipse model)) rad)
           (place-circle (custom-ellipse-point-2 (masterGuy-current-ellipse model)) rad)
           (place-circle (custom-ellipse-point-3 (masterGuy-current-ellipse model)) rad)
           (above BOARD
                  (make-text-of model))))
             remember-scene)]
         [(second-ready? model)
          (overlay/align "left" "top"    
           (place-circle (custom-ellipse-point-1 (masterGuy-current-ellipse model)) rad)
           (place-circle (custom-ellipse-point-2 (masterGuy-current-ellipse model)) rad)
           (above BOARD
                  (make-text-of model)))]
         [(first-ready? model)
          (overlay/align "left" "top"
           (place-circle (custom-ellipse-point-1 (masterGuy-current-ellipse model)) rad)
           (above BOARD
                  (make-text-of model)))]
         [else (above BOARD
                  (make-text-of model))]))

;END DRAW HANDLER

;BEGIN MOUSE HANDLER

(define (mousey model x y event)
  (cond [(equal? event "button-down") (choose-point x y model)]
        [else model]))

(define (choose-point x y model)
  (cond [(not (first-ready? model)) (make-masterGuy 
                                     (masterGuy-status model) 
                                     (make-custom-ellipse (make-posn x y) empty-posn empty-posn) 
                                     (masterGuy-list-of-ellipses model))]
        [(not (second-ready? model)) (make-masterGuy
                                      (masterGuy-status model)
                                      (make-custom-ellipse (custom-ellipse-point-1 
                                                            (masterGuy-current-ellipse model)) 
                                                           (make-posn 
                                                                   x 
                                                                   y)
                                                           empty-posn)
                                      (masterGuy-list-of-ellipses model)
                                      )]
        [(not (third-ready? model)) (begin
                                      (set! render? #t)
                                      
                                      (make-masterGuy
                                      (masterGuy-status model)
                                      (make-custom-ellipse (custom-ellipse-point-1 
                                                            (masterGuy-current-ellipse model))
                                                           (custom-ellipse-point-2 
                                                            (masterGuy-current-ellipse model))
                                                           (make-posn x y))
                                      (masterGuy-list-of-ellipses model)))]
        [else model]))

(define (middle-x model)
  (/ (+ (posn-x (custom-ellipse-point-1 (masterGuy-current-ellipse model))) (posn-x (custom-ellipse-point-2 (masterGuy-current-ellipse model)))) 2))

;END MOUSE HANDLER

(big-bang empty-model
          (on-tick ticker)
          (on-draw interceptor)
          (on-mouse mousey)
          (on-key keyer))

(test)