#lang racket
;(require picturing-programs)

(require plot)


(plot (function sin (- pi) pi))

(plot (function (λ (x) x) 2 -2))

(plot (function (λ (x ) 