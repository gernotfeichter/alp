# alp linux

## code generation
This project will only compile if all source code is available.
Note: Since version 1.1.12, the generated code was also added to git, due to not easily fixable problems with releasing for nixos,
so the following step is optional, or only required when the openapi specs change:
```
go generate
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
go test --timeout 20m
```

### specific tests
e.g.:
```
docker build . -f test/docker-scenarios/fallback-to-password-prompt-bad-password/Dockerfile -t test --progress=plain
```

## release

```
./release.sh <major>.<minor>.<patch>
```
