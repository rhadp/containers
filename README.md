# Red Hat Automotive Suite - Containers

Container images for developing, building and running workloads on the Red Hat Automotive Suite (RHAS).

All images are published to `ghcr.io/rhadp/<name>` for `linux/amd64` and `linux/arm64`.

## Images

| Image | Base | Purpose |
|---|---|---|
| `tools` | `ubi10/go-toolset` | Builds the `caib` CLI from [automotive-dev-operator](https://github.com/mickume/automotive-dev-operator). Only used as a source for the other images. |
| `runtime` | `ubi10` | Minimal image for running workloads: Python 3.14 + `uv`, `oc`, `kubectl`, `caib`, Jumpstarter, Ansible, boto3. |
| `pipeline` | `runtime` | `runtime` plus extra Python libraries (Kubernetes, GitHub/GitLab, Google Cloud, …) for CI/CD pipelines. |
| `builder` | `rhel10/s2i-core` | Full build environment: everything in `pipeline` plus GCC, CMake, Go, Rust, Node.js, `protoc`, `rpm-build`, `createrepo_c`. |
| `codespaces` | `devspaces/udi-base-rhel10` | Same toolchain as `builder`, packaged as an OpenShift Dev Spaces workspace image. Adds the helper scripts `init-workspace`, `jmp-login` and `pac-setup`. |
| `autosd` | `centos:stream10` | Minimal CentOS Stream 10 image with the AutoSD and Automotive repositories enabled. |
| `autosd-buildbox` | `centos:stream10` | `autosd` plus `rpmdevtools` and common CLI tools, with an RPM build tree in `/opt/autosd`. |

Jumpstarter is installed from the `develop` branch of [mickume/jumpstarter](https://github.com/mickume/jumpstarter). Python packages live in a virtual environment at `/venv`.

## Repository layout

```
containers/<name>/   Containerfile and build context for each image
.github/workflows/   GitHub Actions that build and push the images
scripts/             Local helper scripts
Makefile             Local builds with podman
```

## Building locally

Pulling the base images requires a login to `registry.redhat.io`.

```shell
make build-all          # all images
make runtime            # a single image
make clean              # remove locally built images
```

`REGISTRY`, `NAMESPACE`, `TAG` and `CONTAINER_TOOL` can be overridden.

Note that `runtime`, `builder`, `codespaces` and `pipeline` copy from or build on `ghcr.io/rhadp/*:latest`, not the locally built images.

## CI

[`build-all.yaml`](.github/workflows/build-all.yaml) runs on every push and pull request to `main` and builds all images. Pushes to `main` are tagged `latest`; every build is also tagged with the git version. `tools`, `runtime`, `pipeline`, `builder` and `codespaces` also have their own `build-<name>.yaml` workflow for manual runs.

## Disclaimer

This is not an officially supported Red Hat product.
