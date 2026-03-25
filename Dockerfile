FROM odoo:18

USER root

WORKDIR /app

COPY . .

USER odoo
