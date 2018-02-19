v6.4
===

This branch is tested to work on a clone of the Racket v6.4 release branch.

If the @${RMC} environment variable points to where you cloned _this_ repo, you can run:

```
$ git clone https://github.com/racket/racket racket-v6.4
$ cd racket-v6.4
$ git checkout v6.4
$ cd ..
$ racket ${RMC}/setup.rkt --racket racket-v6.4
```



racket-minus-contracts
======================

This repository contains a patch to remove contracts from your favorite
Racket installation.
This means that:
- Contracts will still be created
- Contracts will not be attached to values or checked

These guarantees hold for both Racket and Typed Racket.
See the `test/` folder for a few examples that fail normally, but run
successfully after the patch.

You can apply this patch manually, or run the `Makefile` to automate things.


Requirements
------------
1. A "recent" from-source Racket installation.
   Clone from [http://github.com/racket/racket](http://github.com/racket/racket) and compile using the instructions
   at that url.


Usage
-----
Via the Makefile:
- Run `make` to install the patch.
  This locates your racket installation, saves the original files, patches
  your installation, and re-builds Racket.
- Run `make clean` to undo the patch.
  This puts your original files back in place and recompiled Racket.

Via the scripts:
- Run `setup.rkt` to modify a Racket install.
  The script will prompt for a the root directory of this Racket install.
  Optionally, use the `-r` option; for example `racket setup.rkt -r /home/racket`.
- Run `clean.rkt` to bring things back to normal.
  The interface is the same as for `setup.rkt`.

Manually:
- To install:
  - Change directories to the root of your Racket install
  - Apply the patch `ignore-contracts.patch`
  - Rebuild Racket
- To uninstall:
  - Change directories to the root of your Racket install
  - Reset the changes with git: `git checkout -- .`
  - Rebuild Racket


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

