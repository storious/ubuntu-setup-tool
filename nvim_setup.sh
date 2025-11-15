#!/bin/bash

echo "--- Installing Neovim via PPA ---"

# set neovim ppa repo
sudo add-apt-repository ppa:neovim-ppa/unstable -y

# install Neovim and dependencies
sudo apt-get update
sudo apt-get install -y neovim python3-dev python3-pip

# verify Lua support
if nvim --version | grep -q "Lua"; then
    echo "✓ Neovim with Lua support installed"
else
    echo "⚠ Warning: Neovim might not have Lua support"
fi

# create necessary directory
mkdir -p "$HOME/.config/nvim"

# copy neovim config
cp -r "$(pwd)/config/nvim/**" "$HOME/.config/nvim"

echo "--- Neovim installation complete ---"
