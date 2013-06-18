class MyController < ApplicationController
  
  #我的桌面
  def my_launchpad

    render :layout=>false
  end

  #我的桌面数据
  def my_launchpad_data
    find_option ={}
    find_option[:limit] =  params[:limit] || 500
    find_option[:offset] = params[:start] || 0
    if params[:sort]
      find_option[:order] = params[:sort]
      find_option[:order] +=' '+ (params[:dir] || 'ASC')
    end
    find_option[:conditions]="is_function_menu=1 and need_auth=1"
    
    result = Hash.new
    result[:totalCount] = AppFunction.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AppFunction.all(find_option).collect{|i| i.attributes.merge({:icon_url=>"/ext/css/icons/app-icon/aa/ico64.png"})}

    render :text => result.to_json,:layout=>false
  end
  
  
  #常用功能
  def fav_launchpad_data
    find_option ={}
    find_option[:order] ="lft asc"
    find_option[:conditions]="is_function_menu=1 and need_auth=1 and code in ('biz_project','biz_project_query')"
    
    result = Hash.new
    result[:totalCount] = AdminFunction.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminFunction.all(find_option).collect{|i| i.attributes.merge({:icon_url=>"/ext/css/icons/app-icon/aa/ico64.png"})}
    puts "="*80
    result[:rows].each do |row|
      row["icon_url"] = "/images/activity.png" if row["code"] == "biz_activity"
      row["icon_url"] = "/images/project.png" if row["code"] == "biz_project"
      row["icon_url"] = "/images/query.png" if row["code"] == "biz_project_query"
    end
    puts "="*80
    render :text => result.to_json
    
  end
 
end
