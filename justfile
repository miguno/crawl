numCores := `sysctl -n hw.ncpu`

default:
    just --list

# install dependencies
deps:
    # Install dependencies, using DCSS's packaged dependencies
    git submodule update --init
    #git submodule sync --recursive
    #git submodule update --init --force --recursive --depth=1
    yes | pip3 install --upgrade pyyaml

# clean the project
clean:
    (cd crawl-ref/source && make clean)

# build tiles version
build-tiles: deps
    (cd crawl-ref/source && make -j{{numCores}} mac-app-tiles TILES=y)

# build console version
build-console: deps
    (cd crawl-ref/source && make -j{{numCores}})

# build default version
build: build-tiles

# run the app from the git source tree
run:
    # Alternatively, take a look at `crawl-ref/source/mac/crawl`
    crawl-ref/source/crawl

