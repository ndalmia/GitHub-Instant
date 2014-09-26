class ESIndexer
    include SearchHelper
    @queue = :es_upload_queue
    
    def self.es_details
        index = "github"
        type = "erpo"
        return index, type
    end

    def self.perform params
        params = params.with_indifferent_access
        repo_url = params[:repo_url]
        begin
            #Pass repo_url to python function
            # Need to write cloning in python 
        rescue
        end
    end

end

