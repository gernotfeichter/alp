# alp linux

## code generation
This project will only compile if all source code is available.
The following procedure must be done once on a developer machine before running other go commands:
```
go generate ./...
```

## alp init
> WARNING: The following is for development only, since it makes the alp config file world readable - very dangerous!
> However, for development, this is covenient, otherwise you would need to run some other commads as root!

You will need to swap the ip in the following command:
```
go build -o alp main.go && sudo ./alp init -t 10.0.0.3:7654 -l trace && sudo chmod o+r /etc/alp/alp.yaml
```

## alp auth
go run main.go auth -l trace

## test execution

### all tests
```
go test
```

### specific tests
e.g.:
```
docker build . -f test/docker-scenarios/fallback-to-password-prompt-bad-password/Dockerfile -t test --progress=plain
```

## release

```
export GITHUB_TOKEN="<verysecret>"
git tag <major.minor.patch>
goreleaser --clean
bump version in [README](../README.md)
```