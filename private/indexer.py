from elasticsearch import Elasticsearch
import sys
import ipdb
import os
import shutil
from pprint import pprint
from subprocess import call
from git import Repo
import re
import base64
import json
import requests
from pygments import highlight
from pygments.lexers import get_lexer_for_filename
from pygments.formatters import HtmlFormatter

INDEX_NAME=sys.argv[1]
TYPE_NAME=sys.argv[2]
TYPE_NAME_FUNC=sys.argv[3]
ELASTICSEARCH_URL=sys.argv[4]
REPO=sys.argv[5]
PRIVATE_PATH=sys.argv[6]
BRANCH=sys.argv[7]
ACCESS_TOKEN=sys.argv[8]

PREVIEW_SIZE = 50
FULL_SIZE = 20000

es = Elasticsearch([ELASTICSEARCH_URL])

def pygmentize(filename, filestring):
	lexer = get_lexer_for_filename(filename)
	formatter = HtmlFormatter(cssclass="source", linespans="line")
	f = open("test.html", 'w')
	result = highlight(filestring, lexer, formatter)
	return result

def get_paths(path, repo_url):
	for root, dirs, files in os.walk(path, topdown=False):
		#implement ignoring many files here
		full_root = root
		root = root.split(path)[1]
		if root and (root[0] == "."):
			continue
		for name in files:
			if name and (name[0] == '.' or '.' not in name):
				continue
			path_name = os.path.join(root, name)
			full_path_name = os.path.join(full_root, name)
			functions = []
			with open(full_path_name, 'r') as f:
				read_data = f.read(FULL_SIZE)
				preview = ""
				content = ""
				line_number = 0
				f.seek(0)
				for line in f:
					if line_number <= PREVIEW_SIZE:
						preview += line
					content += line
					line_number += 1
					function_name = find_function(line)
					if function_name:
						if function_name.startswith("self."):
							function_name = function_name[5:]
						functions.append({"function_name":function_name, "line_number":line_number})
				try:
					content = pygmentize(name, content)
					preview = pygmentize(name, preview)
				except Exception as e:
					continue
			body = {"path":path_name, "name":name, "body":content, "body_preview":  preview, "repo_url" : repo_url, "branch":BRANCH }
			ret = es.index(index=INDEX_NAME, doc_type=TYPE_NAME, body=body)
			file_id = ret[u'_id']
			for function in functions:
				body = {"function_name":function["function_name"], "line_number":function["line_number"], "path":path_name, "repo_url" : repo_url, "branch":BRANCH}
				es.index(index=INDEX_NAME, doc_type=TYPE_NAME_FUNC, body=body, parent=file_id)

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

def clone_repo(repo_dir):
	if ACCESS_TOKEN != "nothing":
		clone_private_repo(repo_dir, "https://api.github.com/repos/"+ REPO + "/contents?ref=" + BRANCH + "&access_token=" + ACCESS_TOKEN, "dir")
	else:
		repo_url = "https://github.com/" + REPO
		call(["git", "clone", "-b", BRANCH, repo_url, repo_dir])
		shutil.rmtree(repo_dir + "/.git")

def clone_private_repo(current_path, contents_url, type_path):
	response = requests.get(contents_url).text
	response = json.loads(response)
	if type_path == "file":
		f = open(current_path, "w")
		try:
			f.write(base64.b64decode(response["content"]))
			f.close()
		except Exception as e:
			f.close()
			os.remove(current_path)
	else:
		if not os.path.exists(current_path):
			os.mkdir(current_path)
		for file in response:
			contents_url = "https://api.github.com/repos/" + REPO + "/contents/" + file["path"] + "?ref=" + BRANCH + "&access_token=" + ACCESS_TOKEN
			clone_private_repo(current_path + "/" + file["name"], contents_url, file["type"])


def main():
	repo_dir = PRIVATE_PATH + "/" + REPO.split("/")[1]
	clone_repo(repo_dir)
	get_paths(repo_dir, REPO)

if __name__ == '__main__':
	main()