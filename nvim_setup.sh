#!/bin/bash

echo "--- Installing Neovim via PPA ---"

# set neovim ppa repo
sudo add-apt-repository ppa:neovim-ppa/unstable -y

# 安装 Neovim 及相关工具
sudo apt-get update
sudo apt-get install -y neovim python3-dev python3-pip

# 验证 Lua 支持
if nvim --version | grep -q "Lua"; then
    echo "✓ Neovim with Lua support installed"
else
    echo "⚠ Warning: Neovim might not have Lua support"
fi

# 创建必要的目录
mkdir -p "$HOME/.config/nvim"

# copy neovim config
cp -r "$(pwd)/config/nvim/**" "$HOME/.config/nvim"

echo "--- Neovim installation complete ---"
