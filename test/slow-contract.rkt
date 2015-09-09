#lang racket/base

(require racket/contract)

(define (slow-predicate x)
  (sleep 2)
  #t)

(define/contract (f x)
  (-> slow-predicate slow-predicate)
  x)

(define (main)
  (printf "Checking contract....\n")
  (f 42)
  (printf "Done!\n"))

(time (main))
