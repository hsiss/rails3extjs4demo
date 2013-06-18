class WebArticleController < ApplicationController
  layout false
  skip_before_filter :authorize,:admin_session_setup,:only=>[:image_upload]
    
  def list
    check_acl('article_list')
  end
 
  
  def list_data
    result = WebArticle.list_data(params)
    render :text => result.to_json
  end
  
  
  def new
    @article = WebArticle.new
    @article.is_active = false
    @article.save!
    
    render :action=>'edit'
  end

  def edit
    @article = WebArticle.find(params[:id])
    render :action=>'edit'
  end
  
  def save
    raise "标题不能为空"  if params[:title].blank?
    raise "内容不能为空"  if params[:content].blank?
    
    if params[:id].blank?
      article = WebArticle.new
    else
      article = WebArticle.find(params[:id])
    end
    article.title = params[:title]
    article.content = params[:content]
    article.is_active = true
    article.create_user_id = AdminUser.current && AdminUser.current.id
    article.create_user_name = AdminUser.current && AdminUser.current.name
    article.save!
    render :json=>{:success=>true}
  end
  
  def delete
    WebArticle.delete(params[:id])
    render :text => {:success=>true},:layout=>false
  end

  #文件上传
  def image_upload
#    Parameters: {"dir"=>"默认目录", "fileName"=>"yuyue-sellcar-main.jpg", "Filename"=>"yuyue-sellcar-main.jpg", 
#      "param2"=>"value2", "param1"=>"value1", "pictitle"=>"yuyue-sellcar-main.jpg", "upfile"=>#<ActionDispatch::Http::UploadedFile:0x007f95b6fe8fc8 @original_filename="yuyue-sellcar-main.jpg", @content_type="application/octet-stream", @headers="Content-Disposition: form-data; name=\"upfile\"; filename=\"yuyue-sellcar-main.jpg\"\r\nContent-Type: application/octet-stream\r\n", @tempfile=#<Tempfile:/var/folders/r2/y_xt64g96_96q2mnkj8_8lgw0000gn/T/RackMultipart20130427-23835-1qzvjkh>>, "Upload"=>"Submit Query"}
    
    img = WebArticleImage.new
    if params[:id]
      article = WebArticle.find(params[:id])
      img.article = article
    end
    img.image = params[:upfile]
    img.updated_user_id = AdminSession.current_user_id
    img.updated_user_name = AdminSession.current_user_name
    img.save!
    render :json=>{:url => img.image.url, 'state'=>'SUCCESS', :title=>params[:pictitle]}  
    #{'url':'图片地址','state':'SUCCESS','title':'图片title'}
  end
end
