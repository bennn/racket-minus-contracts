#lang racket/base

;; TODO

(require
  "common.rkt"
  (only-in racket/system system))

;; =============================================================================

;; Get the source for the Racket directory,
;; save original contract files,
;; apply patch,
;; recompile the contract directory.
(module+ main
  (require racket/cmdline)
  ;; --
  (define *rkt* (make-parameter #f))
  (define *verbose* (make-parameter #t))
  ;; --
  (command-line
   #:program "contract-remover"
   #:once-each
   [("-q" "--quiet")  "Run quietly" (*verbose* #f)]
   [("-r" "--racket") r-param "Directory containing Racket source to modify." (*rkt* r-param)]
   #:args ()
   (begin
     (define v? (*verbose*))
     (debug v? "Searching for racket installation...")
     (define rkt-dir
       (or (parse-rkt-dir (*rkt*))
           (and v? (read-rkt-dir))
           (infer-rkt-dir)))
     (unless rkt-dir
       (raise-user-error 'setup "Error: could not find a Racket install. Goodbye."))
     (debug v? (format "Found Racket directory '~a', copying backup files..." rkt-dir))
     (save-backups rkt-dir)
     (debug v? (format "Saved backup files to '~a' directory. Applying patch..." backup-dir))
     (unless (file-exists? patch-file)
       (raise-user-error 'setup (format "Error: could not find patch file '~a'. Goodbye." patch-file)))
     (define patch (string-append (path->string (current-directory)) "/" patch-file))
     (and
       (parameterize ([current-directory rkt-dir])
         (system (string-append "git apply -v " patch)))
       (debug v? "Patch succeeded! Recompiling 'contract.rkt'")
       (recompile rkt-dir)))))
