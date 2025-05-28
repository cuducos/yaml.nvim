FROM debian:bookworm-slim AS neovim
ARG NVIM_VERSION
ENV NVIM_VERSION=${NVIM_VERSION:-stable}
ENV BUILD_REQUIREMENTS "cmake curl gcc gettext git ninja-build unzip"
RUN apt-get update && \
    apt-get install -y ${BUILD_REQUIREMENTS} && \
    git clone --branch ${NVIM_VERSION} https://github.com/neovim/neovim && \
    cd neovim && \
    make install && \
    rm -rf ../neovim && \
    apt-get remove -y ${BUILD_REQUIREMENTS} && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

FROM rust:slim-bookworm AS tree-sitter-cli
RUN cargo install tree-sitter-cli

FROM debian:bookworm-slim
COPY --from=neovim /usr/local/share/nvim /usr/local/share/nvim
COPY --from=neovim /usr/local/lib/nvim /usr/local/lib/nvim
COPY --from=neovim /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=tree-sitter-cli /usr/local/cargo/bin/tree-sitter /usr/local/bin/tree-sitter

RUN apt-get update && \
    apt-get install -y curl fzf g++ git && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -ms /bin/bash yaml

USER yaml
WORKDIR /home/yaml/
RUN mkdir -p .config/nvim/
ADD tests/init.lua .config/nvim/init.lua
ADD . .

CMD ["nvim", "tests/sample.yaml"]
