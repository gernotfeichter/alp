# alp linux

## code generation
This project will only compile if all source code is available.
The following procedure must be done once on a developer machine before running other go commands:
```
go generate
```

## test execution

### all tests
```
go test
```

### specific tests
```
(cd linux && docker build . -f test/docker-scenarios/fallback-to-password-prompt-bad-password/Dockerfile -t test --progress=plain)
```
