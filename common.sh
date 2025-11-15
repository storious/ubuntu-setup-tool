#!/usr/bin/env bash

# define color
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# define the log level
INFO="[INFO]"
WARNING="[WARNING]"
ERROR="[ERROR]"

# generate log file 
LOG_FILE="$(date +'%Y-%m-%d').log"

# define log print function
log_info() {
    echo -e "${GREEN}${INFO} $1${RESET}" | tee -a "$LOG_FILE" >&2
}

log_warning() {
    echo -e "${YELLOW}${WARNING} $1${RESET}" | tee -a "$LOG_FILE" >&2
}

log_error() {
    echo -e "${RED}${ERROR} $1${RESET}" | tee -a "$LOG_FILE" >&2
}

# default mode --verbose
VERBOSE=true

# help menu
usage() {
    echo "usage: $0 [option]"
    echo ""
    echo "option:"
    echo "  --help, -h         show the help message"
    echo "  --quiet, -q        quiet mode, without command output"
    echo "  --uninstall        uninstall app or config"
    echo ""
    echo "example:"
    echo "  $0                 execute initialize"
    echo "  $0 --quiet         initialize in quiet mode"
    echo "  $0 --uninstall     uninstall app or config"
}

# define command in quiet or verbose mode
run_command() {
    if [ "$VERBOSE" = true ]; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

install_package() {
    local package="$1"
    if dpkg -l | grep -q "^ii  $package "; then
        log_info "$package has installed, skipped"
    else
        log_info "installing $package..."
        # use DEBIAN_FRONTEND=noninteractive avoid interactive tip
        run_command sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$package"
        log_info "$package installed successful"
    fi
}

init() {
    # initialize
    log_info "Initializing script"
    run_command sudo apt-get update -q

    # install curl
    log_info "installing curl"
    install_package "curl"

    # update apt 
    log_info "update apt"
    run_command sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q

    log_info "installing dev environment and basic cli tool" 
    packages=(
	    ssh
        build-essential
        vim
        gcc-doc
        gdb
        wget
        ripgrep
        valgrind
        bear
        git
        tldr
        tmux
        zsh
    )
    # loop install all packages
    for package in "${packages[@]}"; do
        install_package "$package"
    done

    # start ssh service
    log_info "starting the ssh server"
    run_command sudo systemctl enable --now ssh

    log_info "installing oh-my-zsh"
    # ensure the target directory exist
    run_command mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    run_command mkdir -p "$HOME/.oh-my-zsh/custom/themes"

    # check the directory 
    if [ -d "$(pwd)/pkg/ohmyzsh" ]; then
        run_command cp -r "$(pwd)/pkg/ohmyzsh/." "$HOME/.oh-my-zsh"
    else
        log_warning "source $(pwd)/pkg/ohmyzsh not found, skipped oh-my-zsh copy"
    fi

    if [ -d "$(pwd)/pkg/zsh-plugins" ]; then
        run_command cp -r "$(pwd)"/pkg/zsh-plugins/* "$HOME/.oh-my-zsh/custom/plugins"
    else
        log_warning "source $(pwd)/pkg/zsh-plugins skipped, skipped plugin copy"
    fi

    if [ -d "$(pwd)/pkg/zsh-themes" ]; then
        run_command cp -r "$(pwd)"/pkg/zsh-themes/* "$HOME/.oh-my-zsh/custom/themes"
    else
        log_warning "source $(pwd)/pkg/zsh-themes not found, skipped theme copy"
    fi

    if [ -f "$(pwd)/config/.zshrc" ]; then
        run_command cp "$(pwd)/config/.zshrc" "$HOME/.zshrc"
    else
        log_warning "config $(pwd)/config/.zshrc not found, skipped"
    fi

    log_info "switching default Shell to zsh"
    # don't need sudo，chsh only modify current user shell
    run_command chsh -s "$(which zsh)"
    log_warning "oh-my-zsh installation finished, please chose theme. sign again or run `zsh` command."

    # config vim
    log_info "config vim"
    if [ -f "$(pwd)/config/.vimrc" ]; then
        run_command cp "$(pwd)/config/.vimrc" "$HOME/.vimrc"
    else
        log_warning "config $(pwd)/config/.vimrc not found, skipped"
    fi

    # install oh-my-tmux
    log_info "using oh-my-tmux config tmux"
    run_command mkdir -p "$HOME/.config/tmux"
    if [ -f "$(pwd)/config/.tmux/.tmux.conf" ]; then
        run_command cp "$(pwd)/config/.tmux/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
    else
        log_warning "config $(pwd)/config/.tmux/.tmux.conf not found, skipped"
    fi
    if [ -f "$(pwd)/config/.tmux/.tmux.conf.local" ]; then
        run_command cp "$(pwd)/config/.tmux/.tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local"
    else
        log_warning "config $(pwd)/config/.tmux/.tmux.conf.local not fount, skipped"
    fi

    # finished
    log_info "cleaning the unused packages"
    run_command sudo apt-get autoremove --purge -y -qq
    log_info "environment has initialized"
    log_info "uninstall `oh-my-zsh` `oh-my-tmux`, enter bash $0 --uninstall"
}


uninstall() {
    log_info "uninstalling oh-my-zsh"
    # check uninstall script if existence
    if [ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]; then
        run_command bash "$HOME/.oh-my-zsh/tools/uninstall.sh"
    else
        log_warning "oh-my-zsh uninstall script not found, try manual operating"
        run_command rm -rf "$HOME/.oh-my-zsh"
        run_command rm -f "$HOME/.zshrc"
    fi

    log_info "removing oh-my-tmux"
    if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
        run_command mv "$HOME/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf.bak"
    fi
    if [ -f "$HOME/.config/tmux/tmux.conf.local" ]; then
        run_command mv "$HOME/.config/tmux/tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local.bak"
    fi
    log_info "uninstall successfully config has backup as .bak file."
}

# check arguments 
while [[ $# -gt 0 ]]; do
    case $1 in
    --help | -h)
        usage
        exit 0
        ;;
    --quiet | -q)
        VERBOSE=false
        shift
        ;;
    --uninstall)
        uninstall
        exit 0
        ;;
    *)
        log_error "unknown option: $1"
        usage
        exit 1 
        ;;
    esac
done

# if no flag, default execute init 
init
