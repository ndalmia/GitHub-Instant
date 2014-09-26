INDEX_NAME = "github"
TYPE_NAME = "repo"
TYPE_NAME_FUNC = "function"
ELASTICSEARCH_URL = "http://localhost:9200"
PREVIEW_SIZE = 2000
FULL_SIZE = 10000

from elasticsearch import Elasticsearch
import sys
import ipdb
import os
from pprint import pprint
import re

es = Elasticsearch([ELASTICSEARCH_URL])

def get_paths(path, repo_url):
	for root, dirs, files in os.walk(path, topdown=False):
		#implement ignoring many files here
		full_root = root
		root = root.split(path)[1]
		if root and root[0] == ".":
			continue
		for name in files:
			if name and name[0] == '.':
				continue
			path_name = os.path.join(root, name)
			full_path_name = os.path.join(full_root, name)
			with open(full_path_name, 'r') as f:
				read_data = f.read(FULL_SIZE)
				line_number = 0
				f.seek(0)
				for line in f:
					line_number += 1
					function_name = find_function(line)
					if function_name:
						body2 = {"path": path_name, "function_name": function_name, "line_number":line_number, "repo_url" : repo_url}
						es.index(index=INDEX_NAME, doc_type=TYPE_NAME_FUNC, body=body2)
			body = {"path":path_name, "name":name, "body":read_data, "body_preview": read_data[:PREVIEW_SIZE], "repo_url" : repo_url }
			es.index(index=INDEX_NAME, doc_type=TYPE_NAME, body=body)

# def read_in_chunks(file_object, chunk_size=1024):
#     """Lazy function (generator) to read a file piece by piece.
#     Default chunk size: 1k."""
#     while True:
#         data = file_object.read(chunk_size)
#         if not data:
#             break
#         yield data

def find_function(line):
	regex = re.compile("\sdef\s(.+)\s")
	function_name = regex.findall(line)
	if function_name:
		if '(' in function_name[0]:
			return function_name[0].split('(')[0]
		else:
			return function_name[0].split(" ")[0]
	else:
		return None

def main():
	path = '/home/dev/location_apis.dev/'
	repo_url = "https://github.com/loconsolutions/housing.regions.service"
	get_paths(path, repo_url)

if __name__ == '__main__':
	main()