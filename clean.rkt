#lang racket/base

;; Script to undo changes made by the `setup.rkt` script.
;; - Restores backup files
;; - Rebuilds Racket

(require
  "common.rkt"
  (only-in racket/system system))

;; =============================================================================

(module+ main
  (require racket/cmdline)
  ;; --
  (define *rkt* (make-parameter #f))
  (define *verbose* (make-parameter #t))
  ;; --
  (command-line
   #:program "contract-remover-cleaner"
   #:once-each
   [("-q" "--quiet")  "Run quietly" (*verbose* #f)]
   [("-r" "--racket") r-param "Directory containing Racket source to modify." (*rkt* r-param)]
   #:args ()
   (begin
     (unless (directory-exists? backup-dir)
       (raise-user-error 'clean "Cannot clean, backup directory does not exist"))
     (define v? (*verbose*))
     (debug v? "Searching for racket installation...")
     (define rkt-dir
       (or (parse-rkt-dir (*rkt*))
           (and v? (read-rkt-dir))
           (infer-rkt-dir)))
     (unless rkt-dir
       (raise-user-error 'setup "Error: could not find a Racket install. Goodbye."))
     (debug v? (format "Found Racket directory '~a', replacing backed-up files..." rkt-dir))
     (restore-backups rkt-dir)
     (debug v? "Replaced files. Recompiling ...")
     (cond
      [(file-exists? ignore-some-patchfile)
       (system (format "rm ~a" ignore-some-patchfile))
       (recompile rkt-dir contract.rkt)
       (debug v? (format "Successfully recompiled: ~a" rkt-dir))]
      [else
       (recompile rkt-dir)
       (debug v? (format "Successfully recompiled ~a" rkt-dir))]))))
