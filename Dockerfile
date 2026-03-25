FROM odoo:18

USER root

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir psycopg2-binary

USER odoo
