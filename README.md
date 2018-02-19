racket-minus-contracts
======================

A patch to prevent Racket from attaching contracts to values (`ignore-all-contracts.patch`)


Requirements
------------

1. Clone the [Racket](http://github.com/racket/racket) repository
2. Make sure the clone for 'v6.8' or newer


Usage
-----

### Option 1: use the Makefile

```
$ make
```

When prompted, enter a path to the Racket clone you want to disable contracts in.


### Option 2: use `setup.rkt`:

```
$ racket setup.rkt --racket <PATH-TO-CLONE>
```


### Option 3: manually

Apply the patchfile (`ignore-all-contracts.patch`) yourself.


Turn Contracts Back On
---

If `<PATH-TO-CLONE>` is a path to a Racket clone with contracts disabled,
 you can either run:

```
$ make clean
```

and input `<PATH-TO-CLONE>` when prompted, or run:

```
$ racket clean.rkt --racket <PATH-TO-CLONE>
```


Implementation
---

Some notes on implementation:

- the `Makefile` calls the `setup.rkt` script
- `setup.rkt` makes a backup of your files before it tries applying the patch
- if the patch succeeds, `setup.rkt` runs the Makefile in your Racket clone to re-build everything
- `clean.rkt` also recompiles the given Racket clone

Recompiling Racket is slow, but it's the fastest way to make sure contracts are fully disabled (or re-eneabled)


Advanced: Ignore a few contracts
--------------------------------
Here's the scenario:

1. You've run the contract profiler
2. You've noticed that a few contracts are very expensive.

For example, you see this output and decide that `(-> any/c boolean?)` is overly expensive.
```
Running time is 89.27% contracts
29511/33056 ms


BY CONTRACT

(-> any/c Real) @ #(struct:srcloc base-types.rkt #f #f #f 0)
  12869 ms

(-> any/c boolean?) @ #(struct:srcloc base-types.rkt #f #f #f 0)
  22447/2 ms

(-> block? block? any) @ #(struct:srcloc block.rkt 35 1 1009 7)
  5353 ms
```

Here's the solution:

1. Run `racket setup.rkt "(-> any/c boolean?)"`.

Just like that, with a string.
This recompiles your contract library to special-case contracts with that name.
Note that this feature does _not_ recompile your entire Racket install.

To undo the change, run `make clean` as before.

