class WebArticleImageUploader < BaseUploader
  
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  process :convert => 'png'
  
  def filename
      [Time.now().strftime('%Y%m'),
       "#{Time.now().strftime('%Y%m%d%H%M%S')}-#{Digest::MD5.hexdigest(File.dirname(current_path))[0..9]}.png"
      ].join("/")
  end
end