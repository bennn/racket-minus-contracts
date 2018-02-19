# read this as "ignore all"
all:
	racket setup.rkt

# TODO
# # i.e., ignore-some
# some:
# 	racket setup.rkt -q $@

clean:
	racket clean.rkt
