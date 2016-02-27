#!/usr/bin/env bash
cd $HOME
sudo yum -y install zsh git vim
git clone git://github.com/varunkatta/oh-my-zsh.git .oh-my-zsh
ln -s .oh-my-zsh/templates/zshrc-varun .zshrc
zsh
cat zsh >> $HOME/.bashrc
ls
