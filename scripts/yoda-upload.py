# pip install python-irodsclient

import irods
from irods.session import iRODSSession
import json
import os
irods.__version__

with open('C:/Users/Moope001/.irods/passwd.txt', 'r') as f:
    passwd = f.readline().strip()
    
with open(os.path.expanduser("C:/Users/Moope001/.irods/irods_environment.json"), "r") as f:
    ienv = json.load(f)
session = iRODSSession(**ienv, password=passwd)

# coll = session.collections.get("/"+ session.zone + "/home/")
# print(coll.subcollections)

session.data_objects.put("C:/Users/Moope001/OneDrive - Universiteit Utrecht/Documents/programming/hear-hear/data/ouders_2023-09-15.csv", "/nluu10p/home/research-hear-hear-child-participation/data/ouders_2023-09-15.csv")
