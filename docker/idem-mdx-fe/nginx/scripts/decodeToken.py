#!/usr/bin/env python3

import jwt
import json
import pem
import sys, getopt
import requests

def main(argv):
   try:
      opts, args = getopt.getopt(sys.argv[1:], 'j:o:k:hd', ['jwt=','output=','publickey=','help','debug' ])
   except getopt.GetoptError as err:
      print (str(err))
      print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
      print ("The JSON file will be put in the output directory")
      sys.exit(2)

   inputurl = None
   outputpath = None
   publickey = None

   for opt, arg in opts:
      if opt in ('-h', '--help'):
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         print ("The JSON file will be put in the output directory")
         sys.exit()
      elif opt in ('-j', '--jwt'):
         inputurl = arg
      elif opt in ('-o', '--output'):
         outputpath = arg
      elif opt in ('-k', '--publickey'):
         publickey = arg
      elif opt == '-d':
         global _debug
         _debug = 1
      else:
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         print ("The JSON file will be put in the output directory")
         sys.exit()

   if inputurl == None:
      print ("Token file is missing!\n")
      print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
      sys.exit()

   if outputpath == None:
      print ("Output path is missing!\n")
      print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
      sys.exit()

   if publickey == None:
      print ("Public Key path is missing!\n")
      print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
      sys.exit()

   with open(publickey, 'r') as rsa_pubkey:
      pubkey = rsa_pubkey.read()

   jwt_token = requests.get(inputurl, allow_redirects=True)
   token = jwt_token.content
   decode = jwt.decode(token, pubkey, algorithms=["RS256"])

   x = decode["data"]
   json_decoded = json.dumps(x, indent = 4, ensure_ascii=False)

   result_path = open(outputpath, "w", encoding="utf-8")
   result_path.write(json_decoded)
   result_path.close()

if __name__ == "__main__":
   main(sys.argv[1:])