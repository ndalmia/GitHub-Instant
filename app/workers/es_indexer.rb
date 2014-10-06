class ESIndexer
    include SearchHelper
    extend ApplicationHelper
    @queue = :es_upload_queue
    PRIVATE_PATH = "#{Rails.root}/private"
    PYTHON_INDEXER_FILE = Rails.root.join('private', 'indexer.py')
    INDEX_NAME = "github"
    TYPE_NAME = "repo"
    TYPE_NAME_FUNC = "function"
    ELASTICSEARCH_URL = "#{Figaro.env["es_host"]}:#{Figaro.env["es_port"]}"
    
    def self.es_details
        index = "github"
        type = "repo"
        return index, type
    end

    def self.perform repo, branch, access_token
        access_token ||= "nothing"
        Repo.find_or_create_by(:url => repo, :branch => branch)
        indexer_command = "python #{PYTHON_INDEXER_FILE} #{INDEX_NAME} #{TYPE_NAME} #{TYPE_NAME_FUNC} #{ELASTICSEARCH_URL} #{repo} #{PRIVATE_PATH} #{branch}"
        indexer_command += " #{access_token}"
        directory = PRIVATE_PATH + "/#{repo.split('/').last}"
        FileUtils.mkdir_p(directory) unless Dir.exists? directory
        puts indexer_command
        if system(indexer_command)
            Repo.find_by_url(repo, :branch => branch).update_column(:status, "ACTIVE")
        else
            raise "ERROR #{indexer_command}"
        end
        FileUtils.rm_rf(directory)
        broadcast("/"+repo)
    end
end

