#!/usr/bin/env python3

import json
import getopt
import sys

def main(argv):
   input_file = ''
   output_file = ''
   entity_ids_file = ''

   try:
      opts, args = getopt.getopt(argv, "hi:o:e:", ["input=", "output=", "entityids="])
   except getopt.GetoptError:
      print('Usage: filter_json.py -i <input_file> -o <output_file> -e <entity_ids_file>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
            print('Usage: filter_json.py -i <input_file> -o <output_file> -e <entity_ids_file>')
            sys.exit()
      elif opt in ("-i", "--input"):
            input_file = arg
      elif opt in ("-o", "--output"):
            output_file = arg
      elif opt in ("-e", "--entityids"):
            entity_ids_file = arg

   if not input_file or not output_file or not entity_ids_file:
      print('Usage: filter_json.py -i <input_file> -o <output_file> -e <entity_ids_file>')
      sys.exit(2)

   # Leggi gli entityID dal file di testo
   with open(entity_ids_file, 'r', encoding='utf-8') as f:
      entity_ids_to_keep = [line.strip() for line in f]

   # Leggi il file JSON
   with open(input_file, 'r', encoding='utf-8') as file:
      data = json.load(file)

   # Filtra le entry mantenendo solo quelle con entityID presenti nella lista
   filtered_data = [entry for entry in data if entry['entityID'] in entity_ids_to_keep]

   # Scrivi i dati filtrati in un nuovo file JSON
   with open(output_file, 'w', encoding='utf-8') as file:
      json.dump(filtered_data, file, ensure_ascii=False, indent=4)

   print(f"Il file JSON è stato filtrato e salvato come '{output_file}'")

if __name__ == "__main__":
   main(sys.argv[1:])