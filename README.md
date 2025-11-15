# Setup Tool

这是一个用于初始化 Ubuntu 系统的 Bash 脚本，能够自动完成开发环境的安装与配置。脚本支持静默模式、卸载模式，并通过日志记录操作。

## 特性

- 支持安装常用编程工具和开发环境
- 安装并配置 `oh-my-zsh`、`oh-my-tmux`、`neovim` (可选)
- 支持静默模式和卸载功能

## 使用方法

### 1. 克隆仓库获取工具

```bash
git clone https://github.com/storious/ubuntu-setup-tool.git
```

### 2. 运行脚本

默认情况下，脚本将以详细模式运行，输出到终端并记录在一个日志文件中（文件名为当前日期）。

```bash
bash common.sh
```

你可以通过 --help 选项来查看可用的命令和参数。

```bash
bash common.sh --help
```

### 3. 可选参数

--help, -h: 显示帮助信息。
--quiet, -q: 以静默模式运行脚本（只输出错误信息到终端，标准输出记录到日志文件）。
--uninstall: 卸载脚本安装的软件和配置。

### 4. 示例

详细模式执行初始化

```bash
bash common.sh
```

静默模式执行初始化

```bash
bash common.sh --quiet
```

卸载安装的软件和配置

```bash
bash common.sh --uninstall
```

安装并配置neovim
```bash
bash nvim_setup.sh
```

### 5. 日志记录

每次运行脚本，都会将输出日志保存在以当前日期命名的 .log 文件中。日志文件会记录脚本的每个操作步骤，便于排查问题。

```bash
# 日志文件示例
2025-11-10.log
```

## 脚本功能

1. 更新系统及安装 curl:
脚本会自动运行 apt update，并安装 curl 工具。
2. 安装编程工具:
自动安装常用的开发工具和 CLI 工具，包括 build-essential, vim, tmux, zsh, tldr 等。
3. 安装并配置 Oh-My-Zsh:
将 oh-my-zsh 安装到用户的 home 目录，并切换默认 Shell 为 zsh。
4. 配置 Oh-My-Tmux:
脚本会将 tmux 配置文件复制到用户目录，完成终端管理工具的设置。
5. 卸载功能:
支持卸载脚本安装的软件和配置，包括 oh-my-zsh、oh-my-tmux。
6. 安装并配置neovim (version >= 0.12)
附带简单配置(nvim-tree.treesitter)，支持文件浏览(mini.files)和代码补全(blink.cmp)，开启lsp管理(mason)，支持lua

## 注意事项

- 该脚本需要 sudo 权限执行，以安装和卸载系统软件。
- 默认安装的开发环境包括了 zsh, tmux 等工具，如果你不需要某些工具，可以自行修改脚本。
- 如有neovim需要，运行`nvim_setup.sh`
- 在执行脚本前，请确保系统已更新并有足够的磁盘空间。

## 参考项目
- [NekoBytes-TheMissing](https://github.com/E1PsyCongroo/NekoBytes-TheMissing)

- [nvim-lite](https://github.com/Youthdreamer/nvim-lite)

## 许可

该项目遵循 MIT License。
