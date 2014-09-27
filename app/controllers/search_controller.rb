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
    query = 
    {
      "query"=>{
          "match" => {
             "path.untouched" => {
                 "query" => file,
                  "operator" => "and"
             }
          }
      },
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
      },
      "fields"=> [
         "name","path","body_preview"
        ]
    }
    render :json => query_es(query)
  end

  def functions
    repo_url = params[:repo]
    file = params[:file]
    query = params[:query]
    query =
    {
       "query" => {
           "match"=> {
              "function_name"=> {
                  "query" =>query,
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
        },
       "fields"=> [
         "function_name", "line_number"
        ]
    }
    render :json => query_es(query)
  end

  def files
    repo_url = params[:repo]
    query = params[:query]
    query =
    {
        "query"=> {
            "match"=> {
               "path"=> {
                   "query"=> query,
                    "operator"=> "and"
               }
            }
        },
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
          },
        "fields"=> [
           "name","path","body_preview"
          ]
    }
    render :json => query_es(query)
  end

  private
  def query_es(query)
    uri = URI.parse("http://"+Figaro.env["es_host"]+":"+Figaro.env["es_port"] + "/"+ES_INDEX+"/_search")
    http = Net::HTTP.new(Figaro.env["es_host"],Figaro.env["es_port"])
    Rails.logger.info query
    response = http.post(uri.path,query.to_json)
    response.body
  end
end
