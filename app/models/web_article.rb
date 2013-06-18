class WebArticle < ActiveRecord::Base
  belongs_to :type, :foreign_key=>'type_id', :class_name=>'WebArticleType'
  
  # 其他对象引用
  belongs_to :articlable, :polymorphic => true
 
  #查询列表数据
  def self.list_data(params)
    find_option ={}
    find_option[:limit] =  params[:limit] || 20
    find_option[:offset] = params[:start] || 0
    unless params[:sort].blank?
      find_option[:order]=params[:sort].collect{|s| "#{s[:property]} #{s[:direction] || 'ASC'}"}.join(",")
    end
    find_option[:select]="a.*
          "
    find_option[:joins]="as a
              "
    find_option[:conditions]='is_active=1'
    unless params[:type_id].blank?
      find_option[:conditions] << " and a.type_id = #{params[:type_id]}"
    end
    unless params[:title].blank?
      find_option[:conditions] << " and a.title like '%#{params[:title]}%'"
    end
    result = Hash.new
    result[:totalCount] =  WebArticle.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = WebArticle.find(:all, find_option ).collect{|i| i.attributes}
    return result
  end

  
  ################################################################################
  # 新闻相关的方法
  ################################################################################

  #最新5条新闻
  def WebArticle.last_news(cnt=5)
    ret = WebArticle.where(:type_id=>WebArticleType.news).order("create_datetime desc").limit(cnt)
    if ret.size < cnt
      (cnt - ret.size).times { ret << nil }
    end
    return ret
  end
  
  #浏览新闻url链接
  def news_view_path
    "/aboutus/news/#{id}-#{title}"
  end
  
  # 新闻相关的方法 end
  ################################################################################
  
  ################################################################################
  # 活动专场相关的方法
  ################################################################################

  #最新5条活动专场
  def WebArticle.last_5_promotions
    ret = WebArticle.where(:type_id=>WebArticleType.promotion).order("create_datetime desc").limit(5)
    if ret.size<5
      (5-ret.size).times { ret << nil }
    end
    return ret
  end
  
  #浏览活动专场url链接
  def promotion_view_path
    "/promotion/#{id}-#{title}"
  end
  
  # 活动专场相关的方法 end
  ################################################################################

  ################################################################################
  # 单篇文章  
   
  def self.last_or_default(title)
    ret = WebArticle.where(:title=>title).order("updated_at").first
    unless ret
      ret = WebArticle.new
      ret.title=title
      ret.article_content="没有设置<i>#{title}</i>,请到后台设置"
    end
    ret
  end
  
  
  #展厅位置
  def WebArticle.zhantingweizhi
    WebArticle.last_of_default("展厅位置")
  end
  
  #关于我们
  def WebArticle.about_us
    WebArticle.last_of_default("关于我们")
  end

end
