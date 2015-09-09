#lang racket/base

(module t typed/racket/base
  (define N 42)
  (: is-N? (-> Integer Boolean))
  (define (is-N? n)
    (equal? n N))

  (provide is-N?))

(require 't)
(is-N? #t)
