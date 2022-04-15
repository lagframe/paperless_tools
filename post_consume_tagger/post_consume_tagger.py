import requests
import sys
import re
import config

document_id = sys.argv[1]
filename = sys.argv[3] 

api_url = config.paperless+"/api/documents/"+document_id+"/"

headers = {
    "Accept": "application/json; version=2",
    "Authorization": "Token " + config.token
}

tags = False

for match in config.matching:
    pattern = re.compile(match["regex"])

    if pattern.search(filename):
        r = requests.get(api_url, "", headers=headers)
        r_dictionary = r.json()
        tags = r_dictionary["tags"]
        tags.append(match["tag_id"])

if tags:
    patch = {"tags": tags}
    print("Updating Tags: " + tags)
    response = requests.patch(api_url, json=patch, headers=headers)
