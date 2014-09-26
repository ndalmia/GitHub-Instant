Routes
--

/
Hello, welcome to Github code search
Enter the github repo url in the link bar. 


/:github_repo_url
* Check if github_repo_url is indexed in ES. 
	If so, present search bar. 
	Else, call for indexing and ask user to refresh (Maybe put it in Resque)

From JS:
--

First hit :
	10.1.1.224:3005/search?repo_name=housing-rails&q=broker.rb
Will return:
	A list of items with each item:
		* filename
		* path
		* body_preview

If you begin to scroll:
	10.1.1.224:3005/show?doc_id=1234
Will return:
	Full body.

To get functions:
	10.1.1.224:3005/functions?doc_id=1234
Will return:
	A list of strings with the format:
		<functionname_linenumber>




