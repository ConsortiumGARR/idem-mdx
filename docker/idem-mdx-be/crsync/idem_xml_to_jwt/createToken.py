#!/usr/bin/env python3

import jwt
import json
import pem
import sys
import requests

with open('/opt/idem_xml_to_jwt/idem-mdx-service-key.pem', 'r') as rsa_priv_file:
    key = rsa_priv_file.read()

data1 = open('/opt/idem_xml_to_jwt/idem-prod-eds.json')
data2 = open('/opt/idem_xml_to_jwt/edugain2idem-eds.json')
data3 = open('/opt/idem_xml_to_jwt/idem-test-eds.json')
data4 = open('/opt/idem_xml_to_jwt/edugain2idem-eds-nologo.json')

json1 = json.load(data1)
json2 = json.load(data2)
json3 = json.load(data3)
json4 = json.load(data4)

idptoken1 = jwt.encode({'data': json1}, key, algorithm="RS256")
idptoken2 = jwt.encode({'data': json2}, key, algorithm="RS256")
idptoken3 = jwt.encode({'data': json3}, key, algorithm="RS256")
idptoken4 = jwt.encode({'data': json4}, key, algorithm="RS256")

f1 = open('/opt/pyff/idem/idem-token', 'w')
f1.write(idptoken1)

f2 = open('/opt/pyff/edugain/edugain2idem-token', 'w')
f2.write(idptoken2)

f3 = open('/opt/pyff/idem-test/idem-test-token', 'w')
f3.write(idptoken3)

f4 = open('/opt/pyff/edugain/edugain2idem-token-nologo', 'w')
f4.write(idptoken4)
