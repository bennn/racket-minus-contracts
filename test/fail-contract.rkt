#lang racket/base

(require racket/contract)

(define (to-fail! x) #f)

(define/contract (g x)
  (-> any/c to-fail!) ;; "g promised to-fail!"
  #t)

(g 1)
