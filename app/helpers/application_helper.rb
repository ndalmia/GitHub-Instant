module ApplicationHelper
  def broadcast(channel)
    message = {:channel => channel, :data => "PROCESSED"}
    uri = URI.parse(Figaro.env["faye_url"])
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end
