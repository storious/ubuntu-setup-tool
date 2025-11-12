#!/usr/bin/env bash

# --- 适用于 Ubuntu 24.04 的系统初始化脚本 ---
set -e # 遇到错误立即退出，防止脚本在错误状态下继续执行

# 定义颜色
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# 定义日志级别的颜色和格式
INFO="[INFO]"
WARNING="[WARNING]"
ERROR="[ERROR]"

# 生成以日期命名的日志文件名
LOG_FILE="$(date +'%Y-%m-%d').log"

# 定义带颜色输出的日志函数
log_info() {
    # 使用 >&2 将日志信息输出到标准错误，这样不会干扰被调用命令的标准输出
    echo -e "${GREEN}${INFO} $1${RESET}" | tee -a "$LOG_FILE" >&2
}

log_warning() {
    echo -e "${YELLOW}${WARNING} $1${RESET}" | tee -a "$LOG_FILE" >&2
}

log_error() {
    echo -e "${RED}${ERROR} $1${RESET}" | tee -a "$LOG_FILE" >&2
}

# 默认启用 verbose 模式
VERBOSE=true

# 帮助菜单
usage() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --help, -h         显示此帮助信息"
    echo "  --quiet, -q        静默模式，不显示命令输出"
    echo "  --uninstall        卸载已安装的软件和配置"
    echo ""
    echo "示例:"
    echo "  $0                 执行初始化"
    echo "  $0 --quiet         静默模式执行初始化"
    echo "  $0 --uninstall     卸载已安装的软件和配置"
}

# 定义静默或详细运行的命令
run_command() {
    if [ "$VERBOSE" = true ]; then
        # 详细模式：显示所有输出
        "$@"
    else
        # 静默模式：隐藏所有输出，包括错误输出。如果命令失败，set -e 会捕获
        "$@" >/dev/null 2>&1
    fi
}

# 检查并安装单个包的函数
install_package() {
    local package="$1"
    if dpkg -l | grep -q "^ii  $package "; then
        log_info "$package 已安装，跳过"
    else
        log_info "正在安装 $package..."
        # 使用 DEBIAN_FRONTEND=noninteractive 防止安装过程中弹出交互式提示
        run_command sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$package"
        log_info "$package 安装成功"
    fi
}

init() {
    # 初始化
    log_info "正在初始化脚本"
    run_command sudo apt-get update -q

    # 为 chsrc 安装 curl 测速工具
    log_info "正在安装 curl 测速工具"
    install_package "curl"

    # 更新系统
    log_info "正在更新系统"
    run_command sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q

    # 安装编程开发环境
    log_info "正在安装编程开发环境和基础 CLI 工具"
    # --- [优化点] 适用于 Ubuntu 24.04 的包列表 ---
    packages=(
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
    # 循环安装每个包并记录信息
    for package in "${packages[@]}"; do
        install_package "$package"
    done

    # 开启 ssh 服务
    log_info "正在开启 SSH 服务"
    run_command sudo systemctl enable --now ssh

    # --- [修复] 修复 oh-my-zsh 安装问题 ---
    log_info "正在安装 oh-my-zsh"
    # 确保目标目录存在，防止 cp 报错
    run_command mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    run_command mkdir -p "$HOME/.oh-my-zsh/custom/themes"

    # 检查源目录是否存在，避免 cp 报错
    if [ -d "$(pwd)/pkg/ohmyzsh" ]; then
        run_command cp -r "$(pwd)/pkg/ohmyzsh/." "$HOME/.oh-my-zsh" # 使用 /. 来复制内容而不是目录本身
    else
        log_warning "源目录 $(pwd)/pkg/ohmyzsh 不存在，跳过 oh-my-zsh 核心文件复制"
    fi

    if [ -d "$(pwd)/pkg/zsh-plugins" ]; then
        run_command cp -r "$(pwd)"/pkg/zsh-plugins/* "$HOME/.oh-my-zsh/custom/plugins"
    else
        log_warning "源目录 $(pwd)/pkg/zsh-plugins 不存在，跳过插件复制"
    fi

    if [ -d "$(pwd)/pkg/zsh-themes" ]; then
        run_command cp -r "$(pwd)"/pkg/zsh-themes/* "$HOME/.oh-my-zsh/custom/themes"
    else
        log_warning "源目录 $(pwd)/pkg/zsh-themes 不存在，跳过主题复制"
    fi

    if [ -f "$(pwd)/config/.zshrc" ]; then
        run_command cp "$(pwd)/config/.zshrc" "$HOME/.zshrc"
    else
        log_warning "配置文件 $(pwd)/config/.zshrc 不存在，跳过"
    fi

    # 切换用户默认 Shell
    log_info "正在切换默认 Shell 为 zsh"
    # 不需要 sudo，chsh 只修改当前用户的shell
    run_command chsh -s "$(which zsh)"
    log_warning "oh-my-zsh 安装完毕, 请注意配置主题样式。重新登录或运行 'zsh' 以生效。"

    # 配置 vim
    log_info "配置 vim"
    if [ -f "$(pwd)/config/.vimrc" ]; then
        run_command cp "$(pwd)/config/.vimrc" "$HOME/.vimrc"
        # 加入全局vim配置，如不需要可注释
        run_command cp "$(pwd)/config/.vimrc" "/etc/vim/vimrc"
    else
        log_warning "配置文件 $(pwd)/config/.vimrc 不存在，跳过"
    fi

    # 安装 oh-my-tmux
    log_info "正在使用 oh-my-tmux 配置 tmux"
    run_command mkdir -p "$HOME/.config/tmux"
    if [ -f "$(pwd)/config/.tmux/.tmux.conf" ]; then
        run_command cp "$(pwd)/config/.tmux/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
    else
        log_warning "配置文件 $(pwd)/config/.tmux/.tmux.conf 不存在，跳过"
    fi
    if [ -f "$(pwd)/config/.tmux/.tmux.conf.local" ]; then
        run_command cp "$(pwd)/config/.tmux/.tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local"
    else
        log_warning "配置文件 $(pwd)/config/.tmux/.tmux.conf.local 不存在，跳过"
    fi

    # 完成
    log_info "正在清理无关软件包"
    run_command sudo apt-get autoremove --purge -y -qq
    log_info "系统初始化已完成"
    log_info "如果需要卸载 oh-my-zsh oh-my-tmux, 请键入 bash $0 --uninstall"
}

uninstall() {
    log_info "正在卸载 oh-my-zsh"
    # 检查卸载脚本是否存在
    if [ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]; then
        run_command bash "$HOME/.oh-my-zsh/tools/uninstall.sh"
    else
        log_warning "oh-my-zsh 卸载脚本未找到，尝试手动删除..."
        run_command rm -rf "$HOME/.oh-my-zsh"
        run_command rm -f "$HOME/.zshrc"
    fi

    log_info "正在备份并移除 oh-my-tmux 配置"
    if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
        run_command mv "$HOME/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf.bak"
    fi
    if [ -f "$HOME/.config/tmux/tmux.conf.local" ]; then
        run_command mv "$HOME/.config/tmux/tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local.bak"
    fi
    log_info "卸载完成，配置文件已备份为 .bak 文件。"
}

# 检查参数
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
        log_error "未知选项: $1"
        usage
        exit 1 # 未知选项时退出码为1
        ;;
    esac
done

# 如果没有提供任何参数，则执行初始化
init