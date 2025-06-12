#!/bin/bash

set -e

echo "🔥 Начинаем установку..."

os_type="$(uname -s)"

if [[ "$os_type" == "Darwin" ]]; then
    echo "Ты на macOS"

    # Проверяем, есть ли brew
    if ! command -v brew &> /dev/null; then
        echo "🍺 Устанавливаю Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Ставим нужные пакеты через brew
    echo "📦 Устанавливаю пакеты через brew..."
    brew install git gh nvim fzf bat fd git-delta python zsh

    # Устанавливаем zinit
    echo "⚙️ Устанавливаю Zinit..."
    mkdir -p ~/.local/share/zinit
    git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git

elif [[ "$os_type" == "Linux" ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "Ты на VPS."

            echo "🧹 Обновляем систему..."
            sudo apt update && sudo apt upgrade -y

            echo "📦 Устанавливаю пакеты через apt..."
            sudo apt install -y git neovim fzf bat fd-find delta python3 python3-pip zsh curl

            # Debian/Ubuntu иногда fd называется по-другому
            if ! command -v fd &> /dev/null; then
                sudo ln -s $(which fdfind) /usr/local/bin/fd
            fi

            # Устанавливаем zinit
            echo "⚙️ Устанавливаю Zinit..."
            mkdir -p ~/.local/share/zinit
            git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git
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

# Клонируем dotfiles
echo "🔗 Клонирую dotfiles..."
git clone https://github.com/metamorphos1ss/dotfiles.git ~/dotfiles

# Символические ссылки
echo "🔗 Линкую конфиги..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.lua ~/.config/nvim/init.lua

# Установка lazy.nvim
LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ ! -d "$LAZY_PATH" ]; then
    echo "📦 Установка lazy.nvim..."
    git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
fi


# Финалочка
echo "✅ Установка завершена. Перезапусти shell, если ты не полный дебил."
