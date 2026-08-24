# Personal environment

This repository contains personal command-line utilities, dotfiles, editor
configuration, and a reproducible macOS development bootstrap.

## macOS bootstrap

The supported way to install development tools on a Mac is the declarative
bootstrap layer in [`bootstrap/`](bootstrap/README.md). Start with the core
profile and add only the profiles a project needs:

```sh
./bootstrap/doctor.sh
./bootstrap/install.sh core
./bootstrap/install.sh native-build local-ai
```

The installer does not install Homebrew or Xcode Command Line Tools itself.
Install those deliberately first, then use the profiles. See
[`bootstrap/manual/README.md`](bootstrap/manual/README.md) for the few
interactive setup steps.

## Legacy configuration

`bin/`, `tools/`, `dotfiles/`, `emacs/`, and the Git submodules are retained
as historical personal configuration. The macOS bootstrap does not modify or
install them. Modernizing that configuration is a separate migration.
