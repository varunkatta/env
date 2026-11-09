# Manual setup

These steps require an interactive decision, login, or operating-system
permission, so they intentionally are not automated by the bootstrap scripts.

1. Install Xcode Command Line Tools: `xcode-select --install`.
2. Install Homebrew from [brew.sh](https://brew.sh/).
3. Authenticate GitHub when needed: `gh auth login`.
4. Enable `direnv` in the shell you use, for example
   `eval "$(direnv hook zsh)"` in `.zshrc`.
5. Let `uv` manage Python for projects. Do not install a Python runtime with
   Homebrew, `mise`, `pyenv`, or Conda for this setup.
6. Open OrbStack or Docker Desktop after installation to complete its app
   setup. Select exactly one runtime profile.

Local servers are opt-in. After installing a server profile, start it only
when you want it, for example `brew services start postgresql@17`.

## AWS authentication

If you use IAM Identity Center, follow the [AWS CLI SSO
configuration guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html),
then configure and use a named profile:

```sh
aws configure sso --profile personal
aws sso login --profile personal
aws sts get-caller-identity --profile personal
```

These commands open the interactive SSO setup or browser login as needed. Do
not add credentials to this repository.
