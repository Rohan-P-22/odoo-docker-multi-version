# pylint: disable=W0104,R0801
{
    "name": "Customer Feedback",
    "version": "19.0.1.0.0",
    "category": "Customer",
    "summary": "Collect and manage customer feedback",
    "description": "Collect customer feedback with ratings",
    "author": "Himesh",
    "depends": ["base"],
    "data": [
        "security/ir.model.access.csv",
        "views/customer_feedback_view.xml",
    ],
    "installable": True,
    "auto_install": False,
    "license": "LGPL-3",
}
