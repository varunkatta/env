#! /bin/sh

#set up zshrc
#git clone git@github.com:varunkatta/oh-my-zsh.git $HOME/.oh-my-zsh

zshdir=$HOME/oh-my-zsh

if [ -e $HOME/.zshrc ]
then
cp $HOME/.zshrc $HOME/.zshrc.orig
fi
cp $zshdir/templates/zshrc.zsh-template $HOME/.zshrc

#set up sym links
ln -s $HOME/env/dotfiles/dotemacs $HOME/.emacs
ln -s $HOME/env/dotfiles/screenrc $HOME/.screenrc

#emacs set up
cd $HOME/env/submodules/magit
make
