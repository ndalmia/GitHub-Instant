namespace :one_timers do
  
  desc "Create Github index. Delete existing"
  task create_es_index: :environment do
  	delete_index
  	index_name = "github"
  	client = get_es_client
  	resp = client.indices.create index: index_name,
  				body: {
            	"mappings"=> {
				        "repo" => {
				          "properties" => {
				            "path" => {
				              "type" => "multi_field",
				              "fields" => {
				              	"name" => {
				              		"type" => "string",
				              		"search_analyzer" => "str_search_analyzer",
				              		"index_analyzer" => "str_index_analyzer"
				              		},
				              		"untouched" => {
				              			"type" => "string", 
				              			"index" => "not_analyzed"
				              		}
				              }
				            },
				            "repo_url" => {"type"=> "string", "index" => "not_analyzed"},
				            "name"=>{"type"=> "string"},
				            "body"=>{"type"=> "string"},
				            "body_preview"=>{"type" => "string"}
				        	}
				      	},
						"function"=> {
					        "properties"=>{
					            "repo_url" => {"type" => "string", "index" => "not_analyzed"},
					            "path" => {"type" => "string", "index" => "not_analyzed"},
					            "function_name" => {"type" => "string", "index" => "not_analyzed"},
					            "line_number" => {"type" => "integer"}
					        }
					    }
					},
					  "settings" => {
					    "analysis" => {
					      "analyzer" => {
					        "str_search_analyzer" => {
					          "tokenizer" => "whitespace",
					          "filter" => ["lowercase","word_delimiter"]
					        },

					        "str_index_analyzer" => {
					          "tokenizer" => "keyword",
					          "filter" => ["lowercase","word_delimiter","substring"]
					        }
					      },

					      "filter" => {
					        "substring" => {
					          "type" => "nGram",
					          "min_gram" => 2,
					          "max_gram"  => 15
					        }
					      }
				    	}
				  	}
				}
	  	puts resp
  end

	def get_es_client
		address = Figaro.env['es_url']
		Elasticsearch::Client.new(hosts: [address])
  end

  def delete_index
  	client = get_es_client
  	if client.indices.exists index: 'github'
  		client.indices.delete index: 'github'
  	end
  end

end
