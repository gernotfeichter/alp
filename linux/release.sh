# input params
new_version="$1"

# assert correct dir
[ "$(basename "$(echo "$PWD")")" != 'linux' ] && "ERROR: you need to be in the linux directory to run this command properly!" && exit 1
# assert correct branch
[ "$(git branch)" != 'master' ] && "ERROR: you need to be on the master branch to runt his command properly!" && exit 1

# load secrets
. release.sh

# update version in main user facing (parent) README.md
sed "s/download\/[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*/download\/$new_version/" "../README.md"

# build
go mod tidy
go generate ./...
go build -o alp

# test
go test ./...

# commit
git add -A
git commit -m "chore(release) linux ${new_version}"

# tag
git tag "${VERSION}"

# release
goreleaser --clean
git push
git push origin "${VERSION}"
