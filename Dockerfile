# Dockerfile for Salt formula testing
# Used by tests/docker.sh to validate formulas in isolation

FROM almalinux:8

# Install Salt
RUN curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.repo \
    -o /etc/yum.repos.d/salt.repo && \
    dnf install -y salt-minion python3-pyyaml && \
    dnf clean all

# Set up Salt directories
RUN mkdir -p /srv/salt /srv/formulas /srv/pillar /etc/salt

# Configure Salt minion for local mode (masterless)
RUN echo "file_client: local" > /etc/salt/minion && \
    echo "file_roots:" >> /etc/salt/minion && \
    echo "  base:" >> /etc/salt/minion && \
    echo "    - /srv/salt" >> /etc/salt/minion && \
    echo "    - /srv/formulas" >> /etc/salt/minion && \
    echo "pillar_roots:" >> /etc/salt/minion && \
    echo "  base:" >> /etc/salt/minion && \
    echo "    - /srv/pillar" >> /etc/salt/minion

# Copy project files
COPY dist/salt/ /srv/salt/
COPY dist/formulas/ /srv/formulas/
COPY dist/pillar/ /srv/pillar/

# Copy test script
COPY tests/test_formula.sh /tmp/test_formula.sh
RUN chmod +x /tmp/test_formula.sh

# Default command
CMD ["/bin/bash"]
