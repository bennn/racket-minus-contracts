#lang racket/base

;; Script to apply a patch to a Racket install
;; - Saves the files to-be-overwritten
;; - Clobbers a few files with a patch
;; - Rebuilds Racket

(require
  "common.rkt"
  (only-in racket/string string-replace)
  (only-in racket/system system))

;; =============================================================================

;; Create a real patchfile from a template.
;; Replace "the-empty-line" with a string match
(define (compile-patchfile strs-to-ignore)
  (define TMP "#TEMPLATE-HOLE")
  (define rTMP (regexp TMP))
  (with-output-to-file ignore-some-patchfile #:exists 'replace
    (lambda ()
      (with-input-from-file patchfile-template
        (lambda ()
          (for ([ln (in-lines)])
            (if (regexp-match? rTMP ln)
                (displayln (string-replace ln TMP (format "'~s" strs-to-ignore)))
                (displayln ln))))))))


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
   #:args CTR*
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
     (define patch
       (string-append (path->string (current-directory)) "/"
         (if (null? CTR*)
             ignore-all-patchfile
             (begin (compile-patchfile CTR*) ignore-some-patchfile))))
     (unless (file-exists? patch)
       (raise-user-error 'setup (format "Error: could not find patch file '~a'. Goodbye." patch)))
     (and
       (parameterize ([current-directory rkt-dir])
         (system (string-append "git apply -v " patch)))
       (debug v? "Patch succeeded! Recompiling 'contract.rkt'")
       (recompile rkt-dir (and (not (null? CTR*))
                               contract.rkt))
       (debug v? (format "Successfully recompiled: ~a" rkt-dir))
       (debug v? (format "Run 'racket clean.rkt --racket <DIR>' to undo"))))))
