module ApplicationHelper
  def broadcast(channel)
    message = {:channel => channel, :data => "PROCESSED"}
    uri = URI.parse("http://10.1.1.225:9292")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end
