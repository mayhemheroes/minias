FROM --platform=linux/amd64 ubuntu:20.04 as builder

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential peg

ADD . /minias
WORKDIR /minias
RUN make

RUN mkdir -p /deps
RUN ldd /minias/minias | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'cp % /deps;'

FROM ubuntu:20.04 as package

COPY --from=builder /deps /deps
COPY --from=builder /minias/minias /minias/minias
ENV LD_LIBRARY_PATH=/deps
