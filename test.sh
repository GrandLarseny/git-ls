#!/bin/bash

cleanup(){
    cd "$(git rev-parse --show-toplevel)"
    git reset --hard HEAD
    git clean -df .
    exit "$1"
}

# Setup tests
git reset --hard HEAD
git clean -df .
echo '/tests/ignored/test
/tests/ignored-dir/
/tests/ignored-dir-both/
' >> .gitignore

mkdir -p tests
cd tests

mkdir -p test-staged
touch test-staged/test
git add test-staged/test

mkdir -p test-unstaged
touch test-unstaged/test

mkdir -p test-empty

mkdir -p test-both
touch test-both/staged
touch test-both/unstaged
git add test-both/staged

mkdir -p ignored
touch ignored/test

mkdir -p ignored-dir
touch ignored-dir/test

mkdir -p ignored-dir-both
touch ignored-dir-both/unstaged
touch ignored-dir-both/staged
git add -f ignored-dir-both/staged

touch staged
touch unstaged
touch ignored

git add staged

# Start testing

# Test output
result="$(git ls -b -a)"
expected=$'ignored\tEmpty
ignored-dir\tGitignored
ignored-dir-both\tStaged
staged\tStaged
test-both\tStaged
test-empty\tEmpty
test-staged\tStaged
test-unstaged\tUntracked
unstaged\tUntracked'

if [ "$result" != "$expected" ]
then
    cleanup 1
fi

# Test formatting
result="$(git ls -c -a)"
expected=$'ignored         \tEmpty
ignored-dir     \tGitignored
ignored-dir-both\tStaged
staged          \tStaged
test-both       \tStaged
test-empty      \tEmpty
test-staged     \tStaged
test-unstaged   \tUntracked
unstaged        \tUntracked'

if [ "$result" != "$expected" ]
then
    cleanup 1
fi

# Test gitignored dir contents
result="$(git ls -b -a "ignored-dir")"
expected=$'test\tGitignored'

if [ "$result" != "$expected" ]
then
    cleanup 1
fi

# Test gitignored dir with staged contents
result="$(git ls -b -a "ignored-dir-both")"
expected=$'staged\tStaged
unstaged\tGitignored'

if [ "$result" != "$expected" ]
then
    cleanup 1
fi

cleanup 0