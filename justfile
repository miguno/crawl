project_dir := justfile_directory()
linux_distro := shell("source /etc/os-release && echo $ID")
crawl_console_binary := project_dir + "/crawl-ref/source/crawl-console"
crawl_tiles_binary := project_dir + "/crawl-ref/source/crawl-app"

# print available just recipes
[group('project-agnostic')]
default:
    @just --list --justfile {{justfile()}}

# evaluate and print all just variables
[group('project-agnostic')]
just-vars:
    @just --evaluate

# print system information such as OS and architecture
[group('project-agnostic')]
system-info:
    @echo "architecture: {{arch()}}"
    @echo "os: {{os()}}"
    @echo "os family: {{os_family()}}"

# install dependencies after a fresh project checkout
[group('development')]
install-dependencies:
    #!/usr/bin/env bash
    # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
    # `-u`: Errors if a variable is referenced before being set
    # `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
    set -uo pipefail

    if [ ! "{{os()}}" = "linux" ]; then
        echo "ERROR: The operating system {{os()}} is not supported yet."
        exit 1
    fi

    if [ ! "{{linux_distro}}" = "fedora" ]; then
        echo "ERROR: The Linux distribution {{linux_distro}} is not supported yet."
        exit 1
    fi

    echo "Installing base dependencies on {{linux_distro}}"
    sudo dnf install ccache gcc gcc-c++ make bison flex ncurses-devel compat-lua-devel sqlite-devel zlib-devel pkgconfig python3-yaml

    echo "Installing dependencies for tiles builds on Fedora"
    sudo dnf install SDL2-devel SDL2_image-devel libpng-devel freetype-devel dejavu-sans-fonts dejavu-sans-mono-fonts advancecomp pngcrush

    echo "== Installing/updating mise =="
    if ! command -v mise &>/dev/null; then
      echo "ERROR: 'mise' command not found. Is mise installed? (https://github.com/jdx/mise)"
      exit 1
    fi
    mise trust --quiet
    mise install

    echo "== Installing Python and project dependencies =="
    pip install pyyaml

# alias for 'build-linux-app'
[group('development')]
build: build-linux-app

# build DCSS as console Linux binary (ASCII mode)
[group('development')]
build-linux-console:
    @echo "== Building DCSS as console binary (ASCII mode) =="
    (cd crawl-ref/source && make -j4 && cp crawl {{crawl_console_binary}}) || exit 1
    @echo
    @echo "Run the '{{crawl_console_binary}}' binary to launch DCSS in console mode."

# build DCSS as app with tiles support
[group('development')]
build-linux-app:
    @echo "== Building DCSS as app with tiles support =="
    (cd crawl-ref/source && make -j4 TILES=y && cp crawl {{crawl_tiles_binary}}) || exit 1
    @echo
    @echo "Run the '{{crawl_tiles_binary}}' binary to launch DCSS in app mode."

# run DCSS as console Linux binary (ASCII mode)
[group('app')]
run-linux-console:
    {{crawl_console_binary}}

# run DCSS as app with tiles support
[group('app')]
run-linux-app:
    {{crawl_tiles_binary}}
