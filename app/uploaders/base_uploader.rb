require 'carrierwave/processing/mini_magick'
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # 上传文件的根目录,在uploads下根据模型建立
  def store_dir
    "uploads/#{model.class.to_s.underscore}"
  end

end
