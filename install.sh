#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "🚫 Запусти скрипт от рута: sudo bash install.sh"
  exit 1
fi

if [ "$SUDO_USER" == "admin" ] || [ "$USER" == "admin" ]; then
  echo "🔥 Продолжаем установку под пользователем admin..."

  echo "🔗 Клонирую dotfiles..."
  git clone https://github.com/metamorphos1ss/dotfiles.git ~/dotfiles

  echo "🔗 Линкую конфиги..."
  ln -sf ~/dotfiles/.zshrc ~/.zshrc
  ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
  ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
  mkdir -p ~/.config/nvim
  ln -sf ~/dotfiles/init.lua ~/.config/nvim/init.lua

  LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
  if [ ! -d "$LAZY_PATH" ]; then
      echo "📦 Установка lazy.nvim..."
      git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
  fi

  chsh -s $(which zsh)

  echo "✅ Установка завершена. Перезапусти shell."
  exit 0
fi


echo "🔥 Начинаем системную установку..."

os_type="$(uname -s)"

if [[ "$os_type" == "Darwin" ]]; then
    echo "Ты на macOS"

    if ! command -v brew &> /dev/null; then
        echo "🍺 Устанавливаю Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "📦 Устанавливаю пакеты через brew..."
    brew install git gh nvim fzf bat fd git-delta python zsh

    echo "⚙️ Устанавливаю Zinit..."
    mkdir -p ~/.loca[48;25;80;425;640tl/share/zinit
    git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git

elif [[ "$os_type" == "Linux" ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "Ты на VPS."

            adduser admin
            usermod -aG sudo admin

            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | \
              tee /etc/apt/sources.list.d/docker.list > /dev/null

            echo "🧹 Обновляем систему..."
            apt update -y && apt upgrade -y
            echo "📦 Устанавливаю пакеты через apt..."
            apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git neovim fzf bat fd-find delta python3 python3-pip zsh curl ca-certificates gnupg lsb-release

            if ! command -v fd &> /dev/null; then
                ln -s $(which fdfind) /usr/local/bin/fd
            fi

            echo "⚙️ Устанавливаю Zinit..."
            mkdir -p /home/admin/.local/share/zinit
            git clone https://github.com/zdharma-continuum/zinit /home/admin/.local/share/zinit/zinit.git
            chown -R admin:admin /home/admin/.local

            echo "➡ Переключаюсь под пользователя admin и продолжаю установку..."
            sudo -u admin -i bash "$0"
            exit 0
        else
            echo "Linux, но не Ubuntu — иди нахуй со своим дистрибутивом."
            exit 1
        fi
    else
        echo "Linux, но хрен пойми какой"
        exit 1
    fi
else
    echo "Хуй пойми что у тебя за система — $os_type. Пиздуй разбирайся."
    exit 1
fi
