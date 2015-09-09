#lang racket/base

(module a racket/base
  (require racket/contract)

  (define (f x)
    (+ 2 x))

  (provide (contract-out [f (-> boolean? integer?)])))

(require 'a)
(f 1)
