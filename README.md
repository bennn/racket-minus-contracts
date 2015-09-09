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
   Clone from `http://github.com/plt/racket` and compile using the instructions
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

