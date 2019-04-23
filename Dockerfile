FROM ubuntu:18.04 as base

ARG clang_version=6.0
RUN apt-get update && \
    apt-get -y install \
    clang-$clang_version \
    cmake \
    nasm \
    python3-minimal \
    curl \
    git && \
    rm -rf /var/lib/apt/lists/*

# Install and configure Conan
ARG conan_version=1_14_3
RUN curl -Lo conan.deb https://dl.bintray.com/conan/installers/conan-ubuntu-64_$conan_version.deb && \
    dpkg --install conan.deb && \
    rm conan.deb
RUN conan config install https://github.com/includeos/conan_config.git && \
    conan config set general.default_profile=clang-$clang_version-linux-x86_64

WORKDIR /service
COPY conanfile.txt .
RUN conan install -if build .
COPY . .
WORKDIR /service/build
RUN apt-get update && apt-get install -y python-pip && pip install pystache antlr4-python2-runtime
RUN . ./activate.sh && cmake .. && cmake --build .

VOLUME /files
CMD cp /files/* /service && \
    . ./activate.sh && \
    cmake .. && \
    cmake --build . -- -j && \
    cp starbase /files
