# Zsh dotfiles

`completion-cache.zsh` keeps Oh My Zsh's generated completion dump under
`~/.cache/zsh/`. It is deliberately a small, credential-free fragment rather
than a copy of the machine's complete `~/.zshrc`.

Install it on this laptop with:

```sh
mkdir -p ~/.config/zsh
ln -s ~/work/code/personal/env/dotfiles/zsh/completion-cache.zsh \
  ~/.config/zsh/completion-cache.zsh
```

Then source `~/.config/zsh/completion-cache.zsh` immediately before
`source $ZSH/oh-my-zsh.sh` in `~/.zshrc`.
