{
    'name': 'Customer Feedback',
    'version': '19.0.1.0.0',
    'category': 'Customer',
    'summary': 'Collect and manage customer feedback',
    'description': 'Allows company to collect customer feedback with ratings and status tracking',
    'author': 'Himesh',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/customer_feedback_view.xml',
    ],
    'installable': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
