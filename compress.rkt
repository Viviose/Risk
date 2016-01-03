#lang racket
(require file/zip)
(require file/tar)
(define (delifexist f)
  (cond [(file-exists? f) (delete-file f)]
        [else empty]))
(define (winzip)
  (zip "release\\Argo.zip" "dist/windows"))
(define (tuxgz)
  (tar-gzip "release/Argo.tar.gz" "dist/linux"))
(cond [(not (directory-exists? "release")) (make-directory "release")]
      [else (delifexist "release\\Argo.zip")
	    (delifexist "release/Argo.tar.gz")])
(local [(define sys (system-type))]
  (cond [(equal? sys 'windows) (winzip)]
        [else (tuxgz)]))
