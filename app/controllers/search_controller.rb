class SearchController < ApplicationController
  ES_URL = "localhost:9200"
  ES_INDEX = "github"
  ES_TYPE = "repo"

  def show
  	id = params[:doc_id]
  	c = default_client
  	c.get_source index: ES_INDEX, type: ES_TYPE, id: id
  end

  def get_functions
  end

  def index
  	github_url = params[:github_url]
  	c = default_client
  	results = c.search index: ES_INDEX,
              body: {
                query: { match: { repo_url: github_url } }
              }
    #if results dont exist. 
    Resque.enqueue(ESIndexer, github_url)
  end

  def search
  	github_url = params[:github_url]
  	query = params[:query]
  	c =  default_client
  	c.search index: ES_INDEX,
  		type: ES_TYPE,
	  	body: {
		    query: {
		        match: {
		           path: {
		               query: query,
		                operator: "and"
		           }
		        }
		    }
		    ,fields: [
		       "name","path","body_preview"
		    	]
		}
  end

  def default_client
	Elasticsearch::Client.new(hosts: [ES_URL])
  end
end
