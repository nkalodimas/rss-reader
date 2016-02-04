json.array!(@feeds) do |feed|
  json.extract! feed, :id, :title, :link
  json.url feed_url(feed, format: :json)
end
