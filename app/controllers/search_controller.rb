class SearchController < ApplicationController
  before_action :process_repo_param, :only => [:index]
  before_action :check_if_repo_exist, :only => [:index]
  before_action :check_if_branch_exist, :only => [:index]

  ES_INDEX = "github"

  def index
    repo = Repo.where(:url => params[:repo], :branch => params[:branch]).first
    if repo
      case repo.status
      when "INACTIVE"
        @status = "INACTIVE"
      when "ACTIVE"
        @status = "ACTIVE"
      end
    else
      Resque.enqueue(ESIndexer, params[:repo], params[:branch], @access_token)
      @status = "INACTIVE"
    end
  end

  def functions
    repo_url = params[:repo]
    branch = params[:branch]
    query_function_part = params[:query]
    query_file_part = params[:query_file_part]
    query =
    {
      "size" => 10,
      "query" => {
      "bool" => {
        "should" => [],
        "minimum_should_match" => 2,
        }
       },
       "filter"=> {
           "and"=> {
              "filters"=> [
                  {
                      "term"=>{
                          "repo_url"=> repo_url
                      }
                  },
                  {
                      "term"=>{
                          "branch"=> branch
                      }
                  }
                ]
            }
        },
       "fields"=> [
         "_parent","function_name", "line_number", "path", "repo_url"
        ]
    }

    query["query"]["bool"]["should"].push( { "match"=> { "function_name"=> { "query" => query_function_part, "operator" => "and" } } }) if query_function_part != ""
    query["query"]["bool"]["should"].push( { "match"=> { "path"=> { "query" => query_file_part, "operator" => "and" } } }) if query_file_part != ""

    results = JSON.parse(query_es(query, "function"))
    response = []
    results["hits"]["hits"].each do |hit|
      function_name = hit["fields"]["function_name"].first
      line_number = hit["fields"]["line_number"].first
      path = hit["fields"]["path"].first
      body = JSON.parse(get_file_from_id(hit["fields"]["_parent"]))["_source"]["body"]
      response.push({function_name: function_name, path: path, line_number: line_number, body: body})
    end
    render :json => response
  end

  def files
    if params[:query].include? '@'
      if params[:query][0] == '@'
        params[:query_file_part] = ""
      else
        params[:query_file_part] = params[:query][0..params[:query].index('@')-1]
      end
      params[:query] = params[:query][params[:query].index('@')+1..params[:query].length]
      functions
    else
      repo_url = params[:repo]
      branch = params[:branch]
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
                      },
                      {
                          "term"=>{
                              "branch"=> branch
                          }
                      }
                    ]
                }
            },
          "fields"=> [
             "name","path","body"
            ]
      }
      results = JSON.parse(query_es(query, "repo"))
      response = []
      results["hits"]["hits"].each do |hit|
        body = hit["fields"]["body"].first
        path = hit["fields"]["path"].first
        filename = hit["fields"]["name"].first
        response.push({body: body, path: path, filename: filename})
      end
      render :json => response
    end
  end

  private
  def query_es(query, type)
    uri = URI.parse("http://"+Figaro.env["es_host"]+":"+Figaro.env["es_port"] + "/"+ES_INDEX+"/"+type+"/_search")
    http = Net::HTTP.new(Figaro.env["es_host"],Figaro.env["es_port"])
    Rails.logger.info query
    response = http.post(uri.path,query.to_json)
    response.body
  end

  def get_file_from_id(file_id)
    type = "repo"
    uri = URI.parse("http://"+ENV["es_host"]+":"+ENV["es_port"] + "/"+ES_INDEX+"/"+type+"/"+file_id)
    http = Net::HTTP.new(Figaro.env["es_host"],Figaro.env["es_port"])
    request = Net::HTTP::Get.new(uri.request_uri)
    return http.request(request).body
  end

  def process_repo_param
    unless params[:repo]
      render "index.html.erb"
    else
      repo_url = params[:repo]
      if repo_url.include? "github.com"
        uri = URI::parse(repo_url)
        repo_url = uri.path
      end
      repo_url = repo_url[1..-1] if repo_url[0] == '/'
      repo_url = repo_url[0..-2] if repo_url[-1] == '/'
      params[:repo] = repo_url
    end
  end

  def check_if_repo_exist
    repo_url = params[:repo]
    url = "https://api.github.com/repos/" + repo_url
    url += "?access_token="+current_user.access_token if current_user
    uri = URI.parse(url)
    response = JSON.parse(Net::HTTP.get(uri))
    if response["message"] == "Not Found"
      redirect_to :root, :notice => "Repository does not exist."
    else
      @access_token = nil
      @access_token = current_user.access_token if response["private"]
    end
  end

  def check_if_branch_exist
    repo_url = params[:repo]
    params[:branch] ||= "master"
    branch = params[:branch]
    url = "https://api.github.com/repos/" + repo_url + "/branches?ref=" + branch
    url += "&access_token="+current_user.access_token if current_user
    uri = URI.parse(url)
    response = JSON.parse(Net::HTTP.get(uri))
    message = ""
    response.each do |res|
      message = "found" if res["name"] == branch
    end
    unless message == "found"
      redirect_to :root, :notice => "Branch does not exist."
    end
  end
end
