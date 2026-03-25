FROM odoo:18

USER root

# Install extra dependencies (if needed)
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working dir
WORKDIR /mnt/extra-addons

# Copy only custom modules (IMPORTANT)
COPY ./odoo18 /mnt/extra-addons
COPY ./odoo19 /mnt/extra-addons

# Fix permissions
RUN chown -R odoo:odoo /mnt/extra-addons

USER odoo
