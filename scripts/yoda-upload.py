# pip install python-irodsclient

import irods
from irods.session import iRODSSession
import json
import os
irods.__version__

with open('C:/Users/Moope001/.irods/passwd_fsw.txt', 'r') as f:
    passwd = f.readline().strip()
    
with open(os.path.expanduser("C:/Users/Moope001/.irods/irods_environment_fsw.json"), "r") as f:
    ienv = json.load(f)
session = iRODSSession(**ienv, password=passwd)

irods_base_dir = '/nluu10p/home/research-hear-hear-child-participation/data/'

data_objects = [os.path.abspath(os.path.join("data", file)).replace("\\", "/") for file in os.listdir("data")] # works!

for object in data_objects:
        # Get the local file name from the absolute path
        local_file = os.path.basename(object)
        
        # Construct the destination path in iRODS
        irods_dest_path = os.path.join(irods_base_dir, local_file)

        # Upload the file to iRODS
        session.data_objects.put(object, irods_dest_path)
      
        
# -------------

# coll = session.collections.get("/"+ session.zone + "/home/")
# print(coll.subcollections)

# files = os.listdir("data") # step 1
# data_objects = [os.path.abspath(os.path.join("data", file)) for file in files] # step 2
# data_objects = [os.path.abspath(os.path.join("data", file)) for file in os.listdir("data")] # works! but with windows paths
 
# session.data_objects.put("C:/Users/Moope001/OneDrive - Universiteit Utrecht/Documents/programming/hear-hear/data/ouders_2023-09-25.csv", "/nluu10p/home/research-hear-hear-child-participation/data/ouders_2023-09-25.csv")
