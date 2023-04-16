# alp linux

## test execution

### all tests
```
go test
```

### specific tests
```
(cd linux && docker build . -f test/docker-scenarios/fallback-to-password-prompt-bad-password/Dockerfile -t test --progress=plain)
```
