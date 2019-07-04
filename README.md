# tortuga-kit-ganglia

## Overview

This repository contains the requisite files to build a kit to enable support
to install and manage Ganglia monitoring on nodes in a [Tortuga][] environment.

## Building the kit

Change to subdirectory containing cloned Git repository and run `build-kit`.
`build-kit` is provided by the `tortuga-core` package in the [Tortuga][] source.
Be sure you have activated the tortuga virtual environment as suggested in the [Tortuga build instructions](https://github.com/UnivaCorporation/tortuga#build-instructions) before executing `build-kit`.

## Installation

Install the kit:

```shell
install-kit kit-ganglia*.tar.bz2
```

See the [Tortuga Installation and Administration Guide](https://github.com/UnivaCorporation/tortuga/blob/v6.3.1-20180512-1/doc/tortuga-6-admin-guide.md) for configuration
details.

[Tortuga]: https://github.com/UnivaCorporation/tortuga "Tortuga"
