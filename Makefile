# read this as "ignore all"
all:
	racket setup.rkt -q

# TODO
# # i.e., ignore-some
# some:
# 	racket setup.rkt -q $@

clean:
	racket clean.rkt -q
