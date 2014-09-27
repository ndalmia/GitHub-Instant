class SearchController < ApplicationController
  ES_INDEX = "github"
  ES_TYPE = "repo"

  def index
    repo_url = params[:repo]
    repo = Repo.where(:url => repo_url)

    if repo.first
      case repo.first.status
      when "INACTIVE"
        @status = "INACTIVE"
      when "ACTIVE"
        @status = "ACTIVE"
      end
    else
      Resque.enqueue(ESIndexer, repo_url)
      @status = "INACTIVE"
    end
  end

  def file
    repo_url = params[:repo]
    file = params[:file]
    c = default_client
    @results = c.search index: ES_INDEX,
                type: ES_TYPE,
                body: {
                  query: {
                      match: {
                         "path.untouched": {
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

  def functions
    repo_url = params[:repo]
    file = params[:file]
    query = params[:query]
    c =  default_client
    @results = c.search index: ES_INDEX,
                type: ES_TYPE,
                body: {
                   "query" => {
                       "match"=> {
                          "function_name"=> {
                              "query" :query,
                               "operator" => "and"
                          }
                       }
                   },
                   "filter"=> {
                       "and"=> {
                          "filters"=> [
                              {
                                  "term"=>{
                                      "path"=> file
                                  }
                              },
                              {
                                  "term"=>{
                                      "repo_url"=> repo_url
                                  }
                              }
                            ]
                        }
                    }
                  ,fields: [
                     "function_name", "line_number"
                    ]
                }
  end

  def files
    repo_url = params[:repo_url]
    query = params[:query]
    c =  default_client
    @results = c.search index: ES_INDEX,
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
                   "filter"=> {
                       "and"=> {
                          "filters"=> [
                              {
                                  "term"=>{
                                      "repo_url"=> repo_url
                                  }
                              }
                            ]
                        }
                    }
                  ,fields: [
                     "name","path","body_preview"
                    ]
                } 
  end

  private
  def default_client
	 Elasticsearch::Client.new(hosts: [Figaro.env['es_url']])
  end
end
