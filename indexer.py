
INDEX_NAME = "github"
TYPE_NAME = "repo"
ELASTICSEARCH_URL = "http://localhost:9200"
PREVIEW_SIZE = 2000
FULL_SIZE = 10000

from elasticsearch import Elasticsearch
import sys
import ipdb
import os
from pprint import pprint

es = Elasticsearch([ELASTICSEARCH_URL])



def get_paths(path):
	for root, dirs, files in os.walk(path, topdown=False):
		#implement ignoring many files here
		full_root = root
		root = root.split(path)[1]
		if root and root[0] == ".":
			continue
		print root
		for name in files:
			if name and name[0] == '.':
				continue
			path_name = os.path.join(root, name)
			full_path_name = os.path.join(full_root, name)
			function_number = []
			with open(full_path_name, 'r') as f:
				read_data = f.read(FULL_SIZE)
				for piece in read_in_chunks(f):
    				function_number.append(find_functions(piece))
			body = {"path":path_name, "name":name, "body":read_data, "body_preview": read_data[:PREVIEW_SIZE] }
			es.index(index=INDEX_NAME, doc_type=TYPE_NAME, body=body)


def read_in_chunks(file_object, chunk_size=1024):
    """Lazy function (generator) to read a file piece by piece.
    Default chunk size: 1k."""
    while True:
        data = file_object.read(chunk_size)
        if not data:
            break
        yield data

def find_functions(f):
	regex = re.compile("\sdef(.+)\s")
	regex.findall(string)
	[u' lat_lon', u' name_suggest', u' calculate_ranking', u' establishment_type', u' es_index_data', u' self.bulk_upsert record_hashes']


	r = regex.search(string)
	regex.match(string)

	# List the groups found
	r.groups()
	(u' lat_lon',)

	# List the named dictionary objects found
	r.groupdict()
	{}

	


def main():
	
	#Decide mapping of repo
	# path
	# name
	# body
	# name_suggest
	path = '/home/dev/location_apis.dev/'
	get_paths(path)


	# res = es.search(index=INDEX_NAME, 
	# 			doc_type=TYPE_NAME,
 #               	size=1037, 
 #               	body={
	# 			    "query": { 
	# 			        "regexp":{
	# 			             "region_name":"[a-z]+_[0-9]+"
	# 			        }
	# 			    }
	# 			})
	

if __name__ == '__main__':
	main()

	
	

