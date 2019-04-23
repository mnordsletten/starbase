FROM ubuntu:18.04

ARG CREATED
ARG VERSION
ARG REVISION
LABEL org.opencontainers.image.created=$CREATED \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$REVISION \
      org.opencontainers.image.url="https://www.github.com/mnordsletten/starbase" \
      org.opencontainers.image.vendor="IncludeOS" \
      org.opencontainers.image.title="Starbase"

# Install all dependencies
ARG clang_version=6.0
RUN apt-get update && apt-get -y install \
    clang-$clang_version \
    cmake \
    nasm \
    python3-minimal \
    curl \
    git \
    python-pip && \
    pip install pystache antlr4-python2-runtime && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get remove -y python-pip && \
    apt-get autoremove -y

# Add fixuid to change permissions for bind-mounts. Set uid to same as host with -u <uid>:<guid>
RUN addgroup --gid 1000 ubuntu && \
    adduser --uid 1000 --ingroup ubuntu --home /home/ubuntu --shell /bin/sh --disabled-password --gecos "" ubuntu
RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    mkdir -p /etc/fixuid && \
    printf "user: ubuntu\ngroup: ubuntu\npaths:\n  - /starbase\n" > /etc/fixuid/config.yml

# Install and configure Conan
ARG conan_version=1_14_3
RUN curl -Lo conan.deb https://dl.bintray.com/conan/installers/conan-ubuntu-64_$conan_version.deb && \
    dpkg --install conan.deb && \
    rm conan.deb
RUN mkdir /starbase && chown ubuntu:ubuntu /starbase
USER ubuntu
RUN conan config install https://github.com/includeos/conan_config.git && \
    conan config set general.default_profile=clang-$clang_version-linux-x86_64

# Install IncludeOS using Conan and build the starbase service once
WORKDIR /starbase
COPY --chown=ubuntu:ubuntu conanfile.txt .
RUN conan install -if build .
COPY --chown=ubuntu:ubuntu . .
WORKDIR /starbase/build
RUN . ./activate.sh && cmake .. && cmake --build . -- -j && rm /tmp/*
ENTRYPOINT ["/starbase/entrypoint.sh"]

# Set up volume where user files will be mounted from
VOLUME /files
CMD cp /files/* /starbase && \
    . ./activate.sh && \
    cmake --build . -- -j 2>&1 && \
    cp starbase /files
