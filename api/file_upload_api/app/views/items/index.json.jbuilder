# jbuilderを用いてJSONを整形する
json.item do
  json.contents do
    json.array!(@items) do |t|
      json.id t.id
      json.title do
        json.label t.title
      end
      json.description do
        json.label t.description
      end
      json.thumbnail_medium do
        json.url ("http://#{request.host}:#{request.port.to_s}" + t.picture.url(:medium))
      end
    end
  end
end
