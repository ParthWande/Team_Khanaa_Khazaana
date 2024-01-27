from twilio.rest import Client
import requests
import certifi
from flask import Flask, request
from twilio.twiml.messaging_response import MessagingResponse

ca_bundle_path = certifi.where()
session = requests.Session()
session.verify = ca_bundle_path

# Create the Twilio client with the custom session
account_sid='ACd4c9688df25b355c3a08ee142066a2c0'
token = '2ce57dd57ca2385ca74eeca7fd99bf23'
twilio_client = Client(http_client=requests.Session())

def sms(text, number):

  message = twilio_client.messages.create(
      body=text,
      from_= '+18283733091',
      to = '+919324309587'
  )

  print(message.sid)
