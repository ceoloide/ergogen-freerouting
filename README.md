# ergogen-freerouting

A minimal Docker image to run [Ergogen](https://github.com/ergogen/ergogen) and [Freerouting](https://github.com/freerouting/freerouting)

Prebuilt Docker images are available on [Docker Hub under ceoloide/ergogen-freerouting](https://hub.docker.com/repository/docker/ceoloide/ergogen-freerouting/general).

## Image tags

Versioned tags follow `k<KiCad>_e<Ergogen>_f<Freerouting>`. Ergogen
development builds add the commit they were built from, e.g. `e4.3.0-568d7ae`
is the head of the [`v4.3.0` branch of ceoloide/ergogen](https://github.com/ceoloide/ergogen/tree/v4.3.0)
at commit `568d7ae`.

| Tag | KiCad | Ergogen | Freerouting |
|---|---|---|---|
| `k10_e4.2.1_f2.6.0` | 10.0.4 | 4.2.1 | 2.6.0 |
| `k9_e4.2.1_f2.6.0` | 9.0.7 | 4.2.1 | 2.6.0 |
| `k10_e4.3.0-568d7ae_f2.6.0` | 10.0.4 | 4.3.0 (`568d7ae`) | 2.6.0 |
| `k9_e4.3.0-568d7ae_f2.6.0` | 9.0.7 | 4.3.0 (`568d7ae`) | 2.6.0 |

Moving tags:

| Tag | Points to |
|---|---|
| `stable` | `k10_e4.2.1_f2.6.0` (latest Ergogen release) |
| `latest`, `k10_latest` | `k10_e4.3.0-568d7ae_f2.6.0` |
| `k9_latest`, `dev` | `k9_e4.3.0-568d7ae_f2.6.0` |

All images include KiBot 1.9.1, Node.js 24 and Java 25. Older tags (Freerouting
2.5.0 and earlier, and Freerouting snapshot builds) remain on Docker Hub but are
no longer updated.

## How to use the prebuilt Docker image

If you don't want to build your own local image, you can use the [one hosted on Docker Hub](https://hub.docker.com/repository/docker/ceoloide/ergogen-freerouting/general), for example:

```shell
docker run --rm -v $(pwd):/tmp/ergogen -w /tmp/ergogen ceoloide/ergogen-freerouting:stable ergogen .
```

The image is based on `ghcr.io/inti-cmnb/kicad<version>_auto`, Ergogen is installed as a global NPM package, and Freerouting is located here:

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

While the `--rm` flag cleans up the container after running. Note that the output is created in your local directory and will remain available after Docker completes the run.

## How to build

To build the images locally, you can use the `create_docker_image.sh` script. This script builds all image variants locally. Add `--push` to publish them to Docker Hub.

```shell
./create_docker_image.sh
# Publish the built variants:
./create_docker_image.sh --push
```

For each KiCad version (9 and 10 by default) it builds two images, and applies
the moving tags listed above:

- `k<KiCad>_e<Ergogen stable>_f<Freerouting>`, e.g. `k10_e4.2.1_f2.6.0`
- `k<KiCad>_e<Ergogen snapshot>-<commit>_f<Freerouting>`, e.g. `k10_e4.3.0-568d7ae_f2.6.0`

The Ergogen snapshot URL may point at a branch: the script resolves it to the
branch's current head commit, installs that commit, and puts it in the tag.

KiCad 9 builds use the `1.9.1-1_k9.0.7_d13.2` base image because
`kicad9_auto:latest` currently points at a missing amd64 image upstream.

### Advanced build options

You can also provide command-line arguments to the script to override the default versions and URLs:

```shell
./create_docker_image.sh \
  --kicad-versions="9 10" \
  --kicad9-base-tag=<kicad9_auto tag> \
  --kicad10-base-tag=<kicad10_auto tag> \
  --ergogen-stable-version=<version> \
  --ergogen-snapshot-url=<git url>#<branch or commit> \
  --ergogen-snapshot-version=<version label> \
  --freerouting-version=<version>
```

For example, to build only KiCad 10 images with a different stable version of Ergogen:
```shell
./create_docker_image.sh --kicad-versions=10 --ergogen-stable-version=4.2.0
```

### Manual build

If you want to build a single image manually, you can use the `docker build` command with build arguments. For example, to reproduce `k10_e4.3.0-568d7ae_f2.6.0`:

```shell
docker build . \
  --build-arg KICAD_VERSION=10 \
  --build-arg ERGOGEN_VERSION=snapshot \
  --build-arg ERGOGEN_SNAPSHOT_URL=https://github.com/ceoloide/ergogen#568d7ae684ca914f8d200dd773b7fc26373a546e \
  --build-arg FREEROUTING_VERSION=2.6.0 \
  -t my-custom-image
```

For KiCad 9, also pass `--build-arg KICAD_BASE_TAG=1.9.1-1_k9.0.7_d13.2`.

To use a Freerouting development build, set `FREEROUTING_VERSION=snapshot`
and pass either a nightly image with `--build-arg FREEROUTING_SNAPSHOT_IMAGE=ghcr.io/freerouting/freerouting:nightly@sha256:<digest>`
or a jar with `--build-arg FREEROUTING_SNAPSHOT_URL=<url>`. Pin nightly images
by digest; old nightlies are deleted from GHCR.

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
