#!/usr/bin/env python
# encoding: utf-8
"""
mail.py

Encapsulates the mail functionality we need for Tin Can. Starts a local SMTP
server and provides some convenience methods for sending simple messages.

Created by Drew Harry on 2011-03-09.
Copyright (c) 2011 MIT Media Lab. All rights reserved.
"""


import smtplib
import logging
import util

from email.mime.text import MIMEText

smtp_server = None

def sendmail(to, subject, body):
    global smtp_server
    
    if smtp_server==None:
        # set up a new one
        smtp_server = smtplib.SMTP(util.config.get("email", "smtp_server"))

    from_email = util.config.get("email", 'from_email')

    msg = MIMEText(body)
    
    msg['Subject'] = subject
    msg['From'] = from_email
    msg['To'] = to
    
    smtp_server.sendmail(from_email, [to], msg.as_string())
    