# Red Hat Automotive Suite - Containers

Containers images with tools for developers 👨‍💻👩‍💻 and to run workloads on the Red Hat Automotive Suite (RHAS). 

## Container Images

TBD

## Building the container images

Run the following command to build the images locally:

```shell
make build-all
```

Build Chain Structure

  base (UDI9)
  ├── builder
  |    └── codespaces
  runtime (UBI9)
  └── pipeline

Build on GitHub:

This repo contains [actions](https://github.com/rhadp/containers/actions), including:
* [![release latest container images](https://github.com/rhadp/containers/actions/workflows/build-all.yaml/badge.svg)](https://github.com/rhadp/containers/actions/workflows/build-all.yaml)

The workflow creates both the X86 and ARM64 versions of each container.

## Contributing

Fork the repository and submit a pull request.

## Development

A list of ideas, open issues etc related to the Red Hat Automotive Suite (RHAS) is [here](https://github.com/orgs/rhadp/projects/1).  

Also check the [Issues](https://github.com/rhadp/containers/issues) section of the this repository.

## Disclaimer

This is not an officially supported Red Hat product.
