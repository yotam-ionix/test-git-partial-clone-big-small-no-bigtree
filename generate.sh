#!/usr/bin/env bash
rm -rf .git

set -eux

# Use random bytes to make it uncompressible on the wire, requires Python 3.9.
# https://stackoverflow.com/questions/32329381/generating-random-string-of-seedable-data/66018128#66018128
randbytes() (
  python -c 'import random;import sys;random.seed(int(sys.argv[1]));sys.stdout.buffer.write(random.randbytes(int(sys.argv[2])))' "$@"
)

rm -rf small* big*

make_small() (
  n="$1"
  dir="$2"
  rm -rf "$dir"
  mkdir -p "$dir"
  randbytes 0 $n > tmp
  cd "$dir"
  split -a4 -b1 -d ../tmp ''
  cd ..
  rm tmp
)
n=1000
make_small $n small
make_small $n small2

make_big() (
  n="$1"
  dir="$2"
  i=0
  while [ $i -lt 10 ]; do
    randbytes "$i" 10000000 > "${dir}${i}"
    i=$(($i + 1))
  done
)
n=10
make_big "$n" 'big'
mkdir -p 'big'
make_big "$n" 'big/'

## big_tree
#mkdir -p big_tree
#cd big_tree
#python -c 'import random
#import sys
#import os
#import string
#random.seed(0)
#for i in range(1, 50000):
#    open(("".join(random.choices(string.ascii_uppercase + string.digits, k=200))), "a").close()
#'
#cd ..

date='2000-01-01T00:00:00+0000'
email=''
name='a'
export GIT_AUTHOR_DATE="$date"
export GIT_AUTHOR_EMAIL="$email"
export GIT_AUTHOR_NAME="$name"
export GIT_COMMITTER_DATE="$date"
export GIT_COMMITTER_EMAIL="$email"
export GIT_COMMITTER_NAME="$name"
git init
git add .
git commit -m 0
git remote add origin git@github.com:cirosantilli/test-git-partial-clone-big-small-no-bigtree.git
