FROM odoo:18

WORKDIR /app

COPY . .

EXPOSE 8069

CMD ["odoo"]
