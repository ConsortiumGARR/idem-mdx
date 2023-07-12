#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import xml.etree.cElementTree as ET
from operator import itemgetter
from collections import OrderedDict

import sys, getopt
import json

# Get MDUI EntityID
def getEntityID(EntityDescriptor, namespaces):
    return EntityDescriptor.get('entityID')

# Get MDUI DisplayName
def getDisplayNames(EntityDescriptor,namespaces,entType='idp'):

    displayName_list = list()
    if (entType.lower() == 'idp'):
       displayNames = EntityDescriptor.findall("./md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName", namespaces)
    #if (entType.lower() == 'sp'):
    #   displayNames = EntityDescriptor.findall("./md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName", namespaces)

    for dispName in displayNames:
        displayName_dict = dict()
        displayName_dict['value'] = dispName.text
        displayName_dict['lang'] = dispName.get("{http://www.w3.org/XML/1998/namespace}lang")
        displayName_list.append(displayName_dict)

    return displayName_list

# Get MDUI Logos
def getLogos(EntityDescriptor,namespaces,entType='idp'):

    logos_list = list()
    if (entType.lower() == 'idp'):
       logo_urls = EntityDescriptor.findall("./md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo", namespaces)
    #if (entType.lower() == 'sp'):
    #   logo_urls = EntityDescriptor.findall("./md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo", namespaces)

    for logo in logo_urls:
        logo_dict = dict()
        logo_dict['value'] = logo.text
        logo_dict['width'] = logo.get("width")
        logo_dict['height'] = logo.get("height")
        logo_dict['lang'] = logo.get("{http://www.w3.org/XML/1998/namespace}lang")
        logos_list.append(logo_dict)

    return logos_list



def main(argv):
   try:
      # 'm:o:hd' means that 'm' and 'o' needs an argument(confirmed by ':'), while 'h' and 'd' don't need it
      opts, args = getopt.getopt(sys.argv[1:], 'm:o:hd', ['metadata=','output=','help','debug' ])
   except getopt.GetoptError as err:
      print (str(err))
      print ("The DiscoFeed JSON content will be put in the output file")
      sys.exit(2)

   inputfile = None
   outputfile = None
   idp_outputfile = None

   for opt, arg in opts:
      if opt in ('-h', '--help'):
         print ("The DiscoFeed JSON content will be put in the output file")
         sys.exit()
      elif opt in ('-m', '--metadata'):
         inputfile = arg
      elif opt in ('-o', '--output'):
         outputfile = arg
      elif opt == '-d':
         global _debug
         _debug = 1
      else:
         print ("The DiscoFeed JSON content will be put in the output file")
         sys.exit()

   namespaces = {
      'xml':'http://www.w3.org/XML/1998/namespace',
      'md': 'urn:oasis:names:tc:SAML:2.0:metadata',
      'mdrpi': 'urn:oasis:names:tc:SAML:metadata:rpi',
      'shibmd': 'urn:mace:shibboleth:metadata:1.0',
      'mdattr': 'urn:oasis:names:tc:SAML:metadata:attribute',
      'saml': 'urn:oasis:names:tc:SAML:2.0:assertion',
      'ds': 'http://www.w3.org/2000/09/xmldsig#',
      'mdui': 'urn:oasis:names:tc:SAML:metadata:ui'
   }

   if inputfile == None:
      print ("Metadata file is missing!\n")
      sys.exit()

   if outputfile == None:
      print ("Output file is missing!\n")
      sys.exit()


   tree = ET.parse(inputfile)
   root = tree.getroot()
   idp = root.findall("./md:EntityDescriptor[md:IDPSSODescriptor]", namespaces)

   idps = dict()

   list_eds = list()
   list_idp = list()

   for EntityDescriptor in idp:

      #ecs = "NO EC SUPPORTED"

      # Get entityID
      entityID = getEntityID(EntityDescriptor,namespaces)

      # Get MDUI DisplayName
      displayName_list = getDisplayNames(EntityDescriptor,namespaces,'idp')

      # Get MDUI Logos
      logos_list = getLogos(EntityDescriptor,namespaces,'idp')

      #if (len(logos_list) != 0):
      #   logo_flag = 'Logo presente'

      eds = OrderedDict([
        ('entityID',entityID),
        ('DisplayNames',displayName_list),
        ('Logos', logos_list)
      ])

      list_eds.append(eds)


   result_eds = open(outputfile, "w",encoding=None)
   result_eds.write(json.dumps(sorted(list_eds,key=itemgetter('entityID')),sort_keys=False, indent=4, ensure_ascii=False))
   result_eds.close()


if __name__ == "__main__":
   main(sys.argv[1:])

