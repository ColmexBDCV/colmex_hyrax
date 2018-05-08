json.array!(@imports) do |import|
  json.extract! import, :id, :user_id, :image_path, :csv_path
  json.url import_url(import, format: :json)
end
