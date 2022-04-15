# IMPORTANT
# 
# Make your changes and rename this file to "config.py"

# PAPERLESS SERVER
#
# For example: "http://127.0.0.1:8000"
paperless = ""

# AUTH TOKEN
#
# You can create / find your token in the paperless admin frontend (http://HOSTNAME:PORT/admin/authtoken/tokenproxy/).
token = ""

# FILENAME TAG MATCHING RULES
# 
# insert the regex and the corresponding tag id line by line. 
# To find your tag_ids, visit (browser): http://HOSTNAME:PORT/api/tags/
matching = [
    # { "regex": "^basti", "tag_id": 3 },
    # { "regex": "^christine", "tag_id": 3 },
    # { "regex": "bank", "tag_id": 11 },
]
