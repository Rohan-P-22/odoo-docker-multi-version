# pylint: disable=R0801
from odoo import models, fields


class CustomerFeedback(models.Model):
    _name = 'customer.feedback'
    _description = 'Customer Feedback'
    _order = 'date desc'

    name = fields.Char(string='Customer Name', required=True)
    email = fields.Char(string='Customer Email')
    rating = fields.Selection([
        ('1', '1 - Very Poor'),
        ('2', '2 - Poor'),
        ('3', '3 - Average'),
        ('4', '4 - Good'),
        ('5', '5 - Excellent'),
    ], string='Rating', required=True, default='3')
    feedback = fields.Text(string='Feedback Message', required=True)
    date = fields.Date(string='Date', default=fields.Date.today)
    status = fields.Selection([
        ('new', 'New'),
        ('reviewed', 'Reviewed'),
        ('resolved', 'Resolved'),
    ], string='Status', default='new')
    notes = fields.Text(string='Internal Notes')
