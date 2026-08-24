# macOS bootstrap profiles

Each profile is a Homebrew `Brewfile`; it declares packages without embedding
installation logic. `install.sh` validates profile compatibility and then
runs `brew bundle install` for the selected profiles.

```sh
./bootstrap/doctor.sh
./bootstrap/install.sh core
./bootstrap/install.sh core native-build local-ai
```

Available profiles:

| Profile | Purpose |
| --- | --- |
| `core` | Daily terminal, Git, shell, and Python-project tooling |
| `native-build` | Native compilers and numeric libraries |
| `local-ai` | Ollama for local model use |
| `local-ai-advanced` | `llama.cpp` for direct GGUF experimentation |
| `data` | Local analytics, document, media, and schema tooling |
| `postgres-local` | Explicit local PostgreSQL server |
| `redis-local` | Explicit local Redis server |
| `backend` | HTTP, gRPC, and WebSocket clients |
| `containers-orbstack` | OrbStack container runtime |
| `containers-docker` | Docker Desktop container runtime |
| `cloud` | Kubernetes, Terraform, and AWS tools |
| `security` | Secrets, SBOM, and vulnerability tooling |
| `desktop` | Editor, terminal, database GUI, and font |

`containers-orbstack` and `containers-docker` are mutually exclusive.

## Ownership rules

- `uv` alone owns Python versions, environments, and Python tools. Do not add
  Homebrew Python, `pyenv`, Conda, or Python entries to a `mise` configuration.
- Local database servers have dedicated profiles. `data` contains clients and
  libraries only.
- `local-ai` stays limited to Ollama. Advanced inference tools get their own
  profile.
- Bootstrap scripts do not use `sudo` or change macOS preferences.
- Existing dotfiles and legacy installers are outside this bootstrap layer.

Run `./bootstrap/validate.sh` to check these rules without changing the
machine. Use `./bootstrap/doctor.sh <profile>...` to additionally check
whether requested profiles are already installed.
