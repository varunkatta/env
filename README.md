# Personal environment

This repository contains personal command-line utilities, dotfiles, editor
configuration, and a reproducible macOS development bootstrap.

It also keeps reusable, non-project-specific collaboration guidance in
[`operating-model/`](operating-model/README.md). That material captures how
technical work is planned, reviewed, handed off, and communicated without
placing personal operating preferences in an application repository.

[`CLAUDE.md`](CLAUDE.md) and [`AGENTS.md`](AGENTS.md) are thin entry points for
Claude and Codex. Both load the same canonical operating model.

## Philosophy

The bootstrap is deliberately small, declarative, and additive.

- Install a **profile** only when work requires it; this is not a single
  kitchen-sink machine image.
- Homebrew profiles declare system packages. They do not hide package lists in
  imperative installation scripts.
- `uv` owns Python versions, virtual environments, and Python tooling. This
  avoids mixing Homebrew Python, `pyenv`, Conda, `mise`, and global `pip`.
- Project dependencies belong in each project, not this machine bootstrap.
  For example, add PyTorch, MLX, Transformers, and Jupyter with `uv add` in
  the project that needs them.
- Local services, cloud tools, container runtimes, and model engines are
  explicit opt-ins.
- Changes to macOS preferences, secrets, interactive logins, and legacy
  dotfiles are intentionally not automated here.

## First-time installation

1. Install Xcode Command Line Tools:

   ```sh
   xcode-select --install
   ```

2. Install Homebrew from [brew.sh](https://brew.sh/).

3. Check the machine and bootstrap policy:

   ```sh
   ./bootstrap/doctor.sh
   ```

4. Install the core profile:

   ```sh
   ./bootstrap/install.sh core
   ```

5. Add only the capabilities you need, for example:

   ```sh
   ./bootstrap/install.sh native-build local-ai
   ./bootstrap/install.sh data backend containers-orbstack
   ```

The installer does not start database services or perform application setup.
Those remain deliberate, visible actions; see
[`bootstrap/manual/README.md`](bootstrap/manual/README.md).

## Profiles

| Profile | Use it when you need |
| --- | --- |
| `core` | Git, GitHub, modern terminal tools, shell support, and `uv` |
| `native-build` | Compilers, C/C++ extensions, numerical libraries, and local inference builds |
| `local-ai` | Ollama for straightforward local model use |
| `local-ai-advanced` | `llama.cpp` and direct GGUF experimentation |
| `data` | DuckDB, SQLite, PostgreSQL client tools, PDFs, media, OCR, and Protobuf |
| `postgres-local` | An explicit local PostgreSQL server |
| `redis-local` | An explicit local Redis server |
| `backend` | HTTP, gRPC, and WebSocket development |
| `containers-orbstack` | OrbStack as the container runtime |
| `containers-docker` | Docker Desktop as the container runtime |
| `cloud` | Kubernetes, Terraform, and AWS tooling |
| `security` | Encrypted secrets, SBOMs, and vulnerability scanning |
| `desktop` | VS Code, Ghostty, DBeaver, and a developer font |

Discover the exact profile names at any time:

```sh
./bootstrap/install.sh --list
```

The two container runtime profiles are alternatives; selecting both is
rejected.

## Rules enforced by the repository

Run the policy check locally:

```sh
./bootstrap/validate.sh
```

It is also run by the included pre-commit hook and GitHub Actions workflow.

- Homebrew profiles may not install Python, `pyenv`, Conda, or Miniconda.
- A `mise.toml` file may not manage Python.
- PostgreSQL and Redis are allowed only in their dedicated local-server
  profiles.
- The default local-AI profile may contain only Ollama; advanced inference is
  isolated in its own profile.
- Bootstrap scripts may not use `sudo` or `defaults write`.
- Pull requests that modify legacy `bin/`, `tools/`, `dotfiles/`, or `emacs/`
  paths must have a title beginning with `[legacy-migration]`.

To enable the local hook after installing the `core` profile:

```sh
uv tool install pre-commit
pre-commit install
```

For remote enforcement, configure the GitHub `Bootstrap policy` status check
as a required branch-protection check.

## Day-to-day usage

Confirm whether selected profiles match the current machine:

```sh
./bootstrap/doctor.sh core local-ai
```

For a new Python ML project, keep dependencies project-local:

```sh
uv init my-project
cd my-project
uv python pin 3.12
uv add numpy pandas scikit-learn jupyterlab
```

Install a framework only in projects that require it:

```sh
uv add torch transformers
# or, for Apple-native experimentation:
uv add mlx mlx-lm
```

## Repository layout and legacy configuration

`bootstrap/` is the supported macOS setup layer. Its package declarations are
in `bootstrap/brew/`, and its scripts only select profiles, check the machine,
or enforce policy.

`bin/`, `tools/`, `dotfiles/`, `emacs/`, and the Git submodules are retained
as historical personal configuration. The bootstrap does not modify or install
them. Modernizing that configuration is a separate migration.
