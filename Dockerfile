FROM odoo:18

USER root

# Install extra dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Fix permissions for addons folder
RUN mkdir -p /mnt/extra-addons && \
    chown -R odoo:odoo /mnt/extra-addons

USER odoo

# This is a test comment by Rohan - full CI/CD flow test
