FROM hashicorp/terraform:1.6

# Install packages including Python and Google Cloud SDK dependencies
RUN apk add --no-cache \
    curl \
    wget \
    bash \
    git \
    jq \
    python3 \
    py3-pip \
    libc6-compat

# Install Google Cloud SDK the correct way (non-interactive, stable)
ENV CLOUD_SDK_VERSION=457.0.0

RUN curl -sSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz | tar -C /opt -xz \
    && ln -s /opt/google-cloud-sdk/bin/gcloud /usr/bin/gcloud \
    && /opt/google-cloud-sdk/install.sh --quiet \
    && gcloud components install alpha beta kubectl --quiet

ENV PATH="/opt/google-cloud-sdk/bin:$PATH"

# Set working directory
WORKDIR /workspace

# Copy terraform files (optional for dev-time; bind mount is preferred)
COPY . /workspace/

# Default command (use docker-compose or override as needed)
CMD ["terraform", "--help"]
