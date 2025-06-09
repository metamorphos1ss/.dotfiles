#!/bin/bash

set -e

echo "🔥 Начинаю установку..."

#homebrew check
if ! command -v brew &> /dev/null; then
	echo "🍺 Устанавливаю Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#cli tools
echo "📦 Устанавливаю пакеты..."
brew install git gh nvim fzf bat fd git-delta python

#apps
echo "🔧 Устанавливаю приложения..."
brew

#zinit installer
echo "⚙️ Устанавливаю Zinit..."
mkdir -p ~/.local/share/zinit
git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git

#cloning dotfiles
echo "🔗 Клонирую dotfiles..."
git clone git@github.com:metamorphos1ss/.dotfiles.git ~/.dotfiles

# Символические ссылки
echo "🔗 Линкую конфиги..."
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
mkdir -p ~/.config/nvim
ln -sf ~/.dotfiles/init.lua ~/.config/nvim/init.lua

LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ ! -d "$LAZY_PATH" ]; then
  echo "📦 Установка lazy.nvim..."
  git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
fi

# gh auth (one time manual)
echo "🔐 Авторизация GitHub через gh..."
gh auth login || true

#final 
echo "✅ Установка завершена. Перезапускаю shell:"
echo "source ~/.zshrc"
