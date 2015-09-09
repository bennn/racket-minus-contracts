#lang racket/base

(provide
  backup-dir
  overridden-files
  patch-file
  ;; --
  debug
  recompile
  ;; --
  infer-rkt-dir
  parse-rkt-dir
  read-rkt-dir
  ;; --
  save-backups
  restore-backups
)

(require
  (only-in racket/list last)
  (only-in racket/string string-split)
  (only-in racket/system system))

;; =============================================================================
;; Constants

(define backup-dir "./_backup")

(define overridden-files
  '("racket/collects/racket/contract/private/base.rkt"
    "racket/collects/racket/contract/private/provide.rkt"))

(define patch-file "ignore-contracts.patch")

;; -----------------------------------------------------------------------------

(define-syntax-rule (debug v? msg)
  (when v?
    (displayln (string-append "[INFO] " msg))))

(define-syntax-rule (recompile rkt-dir)
  (parameterize ([current-directory rkt-dir])
    (system "env PLT_SETUP_OPTIONS='-D' make")))

;; -----------------------------------------------------------------------------

;; Prompt user to enter a path-string to their Racket install.
(define (read-rkt-dir)
  (printf "Enter the full path to your Racket install:\n")
  (define rkt (read-line))
  (when (eof-object? rkt)
    (raise-user-error 'config "Got EOF, shutting down."))
  (parse-rkt-dir rkt))

;; Try to guess the correct racket installation
(define (infer-rkt-dir)
  (define p (find-executable-path "racket"))
  (define s (and p (path->string p)))
  (define m (and s (regexp-match (regexp "^(.*)/racket/bin/racket$") s)))
  (and m (cadr m)))

;; Ensure that the path-string "looks like" a Racket install
(define (parse-rkt-dir dir)
  (if (or (not dir) (not (directory-exists? dir)))
    (begin
      (when dir (printf "Warning: directory '~a' does not exist\n" dir))
      #f)
    (and (for/and ([o-file (in-list overridden-files)])
           (or (file-exists? (string-append dir "/" o-file))
               (and (printf "Warning: file '~a' does not exist under directory '~a'\n" o-file dir)
                    #f)))
         dir)))

;; -----------------------------------------------------------------------------

(define (copy-backups rkt-dir mode)
  (for ([o-file (in-list overridden-files)])
    (define orig (string-append rkt-dir "/" o-file))
    (define bk (string-append backup-dir "/" (last (string-split o-file "/"))))
    (case mode
     [(save) (copy-file orig bk #t)]
     [(restore) (copy-file bk orig #t)]
     [else (error 'copy-backups (format "Unknown mode '~a'" mode))])))

(define (save-backups rkt-dir)
  (unless (directory-exists? backup-dir)
    (make-directory backup-dir))
  (copy-backups rkt-dir 'save))

(define (restore-backups rkt-dir)
  (copy-backups rkt-dir 'restore))
