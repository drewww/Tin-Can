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

from email.mime.text import MIMEText

smtp_server = smtplib.SMTP()

if __name__ == '__main__':
    logging.debug("about to try sending an email")

    # try sending a trivial 
    me = "foo@mit.edu"
    you = "drew.harry@gmail.com"
    
    msg = MIMEText("This is the body of the email.")
    
    msg['Subject'] = "EMAIL. IT WORKS."
    msg['From'] = me
    msg['To'] = you
    
    smtp_server.sendmail(me, [you], msg.as_string())
    