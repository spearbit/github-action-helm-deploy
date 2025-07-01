FROM alpine:3.19

ENV HELM_DOWNLOAD_URL="https://get.helm.sh/helm-v3.18.3-linux-amd64.tar.gz"
ENV SOPS_DOWNLOAD_URL="https://github.com/getsops/sops/releases/download/v3.10.2/sops-v3.10.2.linux.amd64"
ENV HELM_SECRETS_PLUGIN_VERSION="v4.6.5"

# we use werf as a wrapper for helm to be able to put logs of migration jobs into the CI jobs output
ENV WERF_DOWNLOAD_URL="https://tuf.werf.io/targets/releases/2.39.1/linux-amd64/bin/werf"


# Install base packages and AWS CLI
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq \
    bash \
    nodejs \
    yarn \
    git \
    aws-cli \
    && curl -sL -o /usr/local/bin/sops ${SOPS_DOWNLOAD_URL} \
    && chmod +x /usr/local/bin/sops \
    && curl -L ${HELM_DOWNLOAD_URL} | tar xvz \
    && mv linux-amd64/helm /usr/bin/helm \
    && chmod +x /usr/bin/helm \
    && rm -rf linux-amd64 \
    && helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_PLUGIN_VERSION} \
    && curl -L ${WERF_DOWNLOAD_URL} -o /usr/bin/werf \
    && chmod +x /usr/bin/werf

COPY . /usr/src

RUN ["yarn", "--cwd", "/usr/src", "install"]

ENTRYPOINT ["node", "--experimental-modules", "/usr/src/index.js"]
