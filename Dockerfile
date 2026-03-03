FROM ghcr.io/zeroclaw-labs/zeroclaw:v0.1.7 AS zeroclaw

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        findutils \
        gh \
        git \
        grep \
        jq \
        less \
        openssh-client \
        procps \
        sed \
        tini \
    && rm -rf /var/lib/apt/lists/*

COPY --from=zeroclaw /usr/local/bin/zeroclaw /usr/local/bin/zeroclaw

RUN mkdir -p /zeroclaw-data /workspace \
    && chown -R 65534:65534 /zeroclaw-data /workspace

WORKDIR /workspace
USER 65534:65534

ENTRYPOINT ["/usr/bin/tini", "--", "zeroclaw"]
CMD ["gateway"]
