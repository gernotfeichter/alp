#!/usr/bin/env bash
set -ex

# input params
new_version="$1"

# assert correct dir
[ "$(basename "$(echo "$PWD")")" != 'linux' ] && "ERROR: you need to be in the linux directory to run this command properly!" && exit 1
# assert correct branch
[ "$(git rev-parse --abbrev-ref HEAD)" != 'master' ] && "ERROR: you need to be on the master branch to run this command properly!" && exit 1

# load secrets
. github-token.sh # contains export GITHUB_TOKEN="<secret_token_here>"

# update version in main user facing (parent) README.md
sed -i "s/download\/[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*/download\/$new_version/" "../README.md"
echo -n "$new_version" > cmd/version.txt

# build
go mod tidy
go generate
go build -o alp

# test
go test --timeout "20m"

# commit
git add -A
git commit -m "chore(release) linux ${new_version}"
git push

# tag
git tag "${new_version}"

# releasee
goreleaser --clean
