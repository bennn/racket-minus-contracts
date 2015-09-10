#lang racket/base

(require racket/contract)

(define/contract (f x)
  (-> any/c boolean?)
  2)

(define/contract (g x)
  (-> integer? boolean?)
  #t)

;; Fails unless both contracts are disabled
(f #t)
(g #t)
