# ergogen-freerouting

A minimal Docker image to run [Ergogen](https://github.com/ergogen/ergogen) and [Freerouting](https://github.com/freerouting/freerouting)

Prebuilt Docker images are available on [Docker Hub under ceoloide/ergogen-freerouting](https://hub.docker.com/repository/docker/ceoloide/ergogen-freerouting/general).

The `:latest` tag is kept up to date with the latest stable Ergogen release, currently `4.1.0`. You can also refer to specific versions by referencing it in the tag, e.g. `:4.1.0`.

## How to use the prebuilt Docker image

If you don't want to build your own local image, you can use the [one hosted on Docker Hub](https://hub.docker.com/layers/ceoloide/ergogen-freerouting/latest/images/sha256-ba6fcdafcf791fa4d8efb2ee2bcf6141a49756598357a332720adc85c9b0b107?context=explore).

The image is based on ghcr.io/inti-cmnb/kicad8_auto, ergogen is installed as a global NPM package, and Freerouting is located here:

```shell
/opt/freerouting.jar
```

The current working directory (`$(pwd)`) is mounted into the Docker image filesystem at `/tmp/ergogen` with this part of the command:

```shell
-v $(pwd):/tmp/ergogen
```

The same directory is selected as the working directory inside the Docker image with this part of the command:

```shell
-w /tmp/ergogen
```

While the `-rm` flag cleans up the image after running. Note that the output is created in your local directory and will remain available after Docker completes the run.

## How to build

To build the image locally you can run the following command:

```shell
docker build . -t ergogen-freerouting
```
