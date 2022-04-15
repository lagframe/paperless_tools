import requests
import sys
import re
import config

document_id = sys.argv[1]
filename = sys.argv[2]

api_url = config.paperless+"/api/documents/"+document_id+"/"

tags = []

for match in config.matching:
    pattern = re.compile(match["regex"])

    if pattern.search(filename):
        tags.append(match["tag_id"])

patch = {"tags": tags}

if patch:
    headers = {
        "Accept": "application/json; version=2",
        "Authorization": "Token " + config.token
    }

    response = requests.patch(api_url, json=patch, headers=headers)
