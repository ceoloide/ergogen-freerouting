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

To build the images locally, you can use the `create_docker_image.sh` script. This script will build and push all the different image variants to Docker Hub.

```shell
./create_docker_image.sh
```

This will create the following images:
- `ceoloide/ergogen-freerouting:4.1.0_2.1.0` (stable/stable)
- `ceoloide/ergogen-freerouting:latest` (same as stable/stable)
- `ceoloide/ergogen-freerouting:4.1.0_snapshot` (stable/snapshot)
- `ceoloide/ergogen-freerouting:snapshot_2.1.0` (snapshot/stable)
- `ceoloide/ergogen-freerouting:snapshot` (snapshot/snapshot)

### Advanced build options

You can also provide command-line arguments to the script to override the default versions and URLs:

```shell
./create_docker_image.sh \
  --ergogen-stable-version=<version> \
  --ergogen-snapshot-url=<url> \
  --freerouting-stable-version=<version> \
  --freerouting-snapshot-url=<url>
```

For example, to build with a different stable version of Ergogen:
```shell
./create_docker_image.sh --ergogen-stable-version=4.2.0
```

### Manual build

If you want to build a single image manually, you can use the `docker build` command with build arguments. For example, to build an image with snapshot versions of both tools:

```shell
docker build . \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg FREEROUTING_VERSION=snapshot \
  -t my-custom-image
```

## Automated Workflow

This repository contains a GitHub Actions workflow to automate the building and pushing of Docker images. The workflow is located at `.github/workflows/manual-build.yml`.

### Running the Workflow

You can run the workflow manually from the "Actions" tab of the GitHub repository.

1.  Navigate to the **Actions** tab.
2.  In the left sidebar, click on the **Manual Docker Build** workflow.
3.  Click the **Run workflow** dropdown button.
4.  You can accept the default versions or specify your own.
5.  Click the green **Run workflow** button.

### Workflow Authentication

For the workflow to be able to push images to Docker Hub, it needs to be authenticated. This is done using GitHub Secrets.

**Step 1: Create a Docker Hub Access Token**

1.  Log in to your [Docker Hub account](https://hub.docker.com/).
2.  Go to **Account Settings** and click **Personal access tokens**.
3.  Give the token a name (e.g., `github-actions-token`) and `Read, Write, Delete` permissions.
4.  Click **Generate** and copy the token. You will not see it again.

**Step 2: Add Credentials to GitHub Secrets**

1.  In your GitHub repository, go to **Settings** > **Secrets and variables** > **Actions**.
2.  Click **New repository secret** and add the following two secrets:
    *   **Name:** `DOCKERHUB_USERNAME`
        **Value:** Your Docker Hub username.
    *   **Name:** `DOCKERHUB_TOKEN`
        **Value:** The access token you copied from Docker Hub.

Once these secrets are configured, the workflow will be able to log in to Docker Hub and push the images.
