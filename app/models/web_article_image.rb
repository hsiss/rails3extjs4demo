class WebArticleImage < ActiveRecord::Base
  #上传的图片
  mount_uploader :image, WebArticleImageUploader
  belongs_to :article, :foreign_key=>'article_id', :class_name=>'WebArticle'
  
  
  def self.list_data(params)
    find_option ={}
    find_option[:limit] =  params[:limit] || 20
    find_option[:offset] = params[:start] || 0
    unless params[:sort].blank?
      find_option[:order]=params[:sort].collect{|s| "#{s[:property]} #{s[:direction] || 'ASC'}"}.join(",")
    end
    find_option[:select]="*"
    find_option[:conditions]='1=1'
    result = Hash.new
    result[:totalCount] =  WebArticleImage.count({:conditions=>find_option[:conditions]})
    result[:rows] = WebArticleImage.find(:all, find_option ).collect{|i| i.attributes}
    return result
  end

end
