class ImageService

  def self.upload(data_url, type, api_id)
    png = Base64.decode64(data_url['data:image/png;base64,'.length .. -1])
    File.open("public/photos/#{type}-#{api_id}.png", 'wb') { |f| f.write(png) }
    return "public/photos/#{type}-#{api_id}.png"
  end

  def self.read(path)
    open(path, 'rb')
  end


end
