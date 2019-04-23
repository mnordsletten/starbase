# Starbase

A barebones service that is mainly used for building [NaCl](https://github.com/includeos/nacl). The repo also contains a Dockerfile that will be used to build services.

## Conan
This starbase service configures it's dependencies using [Conan](conan.io). The `conanfile.txt` contains the list of versioned dependencies that it relies upon. 

## Building the Dockerfile
In order to build the Docker container use the following code:
```
docker build \
  --build-arg CREATED="$(git log -1 --format=%cd --date=iso8601-strict)" \
  --build-arg VERSION=<version> \
  --build-arg REVISION=<git code revision> \
  -t includeos/starbase .
```

The Docker image uses the [OCI image format](https://github.com/opencontainers/image-spec) to label the container.

## Build a service
In order to build a service using the Docker container created above the following files should be supplied:
- `nacl.txt` - NaCl configuration code.
- `config.json` - Configuration of the uplink that the Starbase should use.

Then run the following code:

```
docker run -v $PWD:/files -u $(id -u):$(id -g) includeos/starbase
```
