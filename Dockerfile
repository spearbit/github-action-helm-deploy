FROM alpine:3.19

ENV HELM_DOWNLOAD_URL="https://get.helm.sh/helm-v3.18.3-linux-amd64.tar.gz"
ENV SOPS_DOWNLOAD_URL="https://github.com/getsops/sops/releases/download/v3.10.2/sops-v3.10.2.linux.amd64"

# Install base packages and AWS CLI
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq \
    bash \
    nodejs \
    yarn \
    git \
    gcompat \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip \
    && curl -sL -o /usr/local/bin/sops ${SOPS_DOWNLOAD_URL} \
    && chmod +x /usr/local/bin/sops \
    && curl -L ${HELM_DOWNLOAD_URL} | tar xvz \
    && mv linux-amd64/helm /usr/bin/helm \
    && chmod +x /usr/bin/helm \
    && rm -rf linux-amd64 \
    && helm plugin install https://github.com/jkroepke/helm-secrets --version v4.6.5

COPY . /usr/src

RUN ["yarn", "--cwd", "/usr/src", "install"]

ENTRYPOINT ["node", "--experimental-modules", "/usr/src/index.js"]
