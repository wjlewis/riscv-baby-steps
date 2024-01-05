FROM ubuntu:latest

RUN apt-get update \
 && apt-get upgrade \
 && apt-get install -y autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev qemu-system \
 && git clone https://github.com/riscv/riscv-gnu-toolchain

RUN cd riscv-gnu-toolchain \
 && ./configure --prefix=/opt/riscv \
 && make linux

CMD ["bin/bash"]
