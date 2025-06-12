#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "🚫 Запусти скрипт от рута: sudo bash install.sh"
  exit 1
fi

touch ~/.hushlogin
if [ "$SUDO_USER" == "admin" ] || [ "$USER" == "admin" ]; then
  echo "🔥 Продолжаем установку под пользователем admin..."

  echo "🔗 Клонирую dotfiles..."
if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/metamorphos1ss/dotfiles.git ~/dotfiles
fi

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
    mkdir -p ~/.local/share/zinit
    git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git

elif [[ "$os_type" == "Linux" ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "Ты на VPS."
#создаем пользователя

            if ! id "admin" &>/dev/null; then
              adduser --disabled-password --gecos "" admin
              usermod -aG sudo admin
            fi

            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | \
              tee /etc/apt/sources.list.d/docker.list > /dev/null

            echo "🧹 Обновляем систему..."
            apt update -y && apt upgrade -y
            echo "📦 Устанавливаю пакеты через apt..."
            apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git neovim fzf bat fd-find delta python3 python3-pip zsh curl ca-certificates gnupg lsb-release openssh-server ufw

            if ! command -v fd &> /dev/null; then
                ln -s $(which fdfind) /usr/local/bin/fd
            fi

            echo "⚙️ Устанавливаю Zinit..."
            mkdir -p /home/admin/.local/share/zinit
            git clone https://github.com/zdharma-continuum/zinit /home/admin/.local/share/zinit/zinit.git
            chown -R admin:admin /home/admin/.local

            # 🚩 ДОБАВЛЯЕМ ПУБЛИК SSH КЛЮЧ
            echo "🔑 Настраиваю SSH ключи..."
            mkdir -p /home/admin/.ssh
            curl -s https://raw.githubusercontent.com/metamorphos1ss/dotfiles/main/key.pub > /home/admin/.ssh/authorized_keys
            chmod 700 /home/admin/.ssh
            chmod 600 /home/admin/.ssh/authorized_keys
            chown -R admin:admin /home/admin/.ssh

            # 🚩 ОБНОВЛЯЕМ SSHD_CONFIG
            echo "🔧 Настраиваю sshd_config..."
            sed -i '/^Port /d' /etc/ssh/sshd_config
            echo "Port 2289" >> /etc/ssh/sshd_config
            sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            sed -i '/^PubkeyAuthentication /d' /etc/ssh/sshd_config
            echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
            sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

            # 🚩 РЕСТАРТИМ SSH
            echo "🔄 Перезапускаю SSH..."
            systemctl restart sshd ssh.socket ssh.service ssh

            echo "🛡️ Настраиваю firewall (UFW)..."
            ufw default deny incoming
            ufw default allow outgoing
            ufw allow 2289/tcp
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw --force enable

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
