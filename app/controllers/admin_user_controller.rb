class AdminUserController < ApplicationController
  def list
    check_acl('admin_user')
    render :layout=>false
  end
  def list_data
    params[:limit] =  params[:limit] || AdminMendian.per_page
    params[:offset] = params[:start] || 0
    result = AdminUser.list_data(params)
    render :text=>result.to_json, :layout=>false
  end
  def new
    @admin_user = AdminUser.new
    render :action=>:edit,:layout=>false
  end
  
  def edit
    @admin_user = AdminUser.find(params[:id])
    render :action=>:edit,:layout=>false
  end
  def change_password
    @admin_user = AdminUser.find(params[:id])
    render :layout=>false
  end
  def change_password_submit
    result = {}
    admin_user = AdminUser.find(params[:id])
    if admin_user.update_attributes(params[:admin_user])
      result[:success]=true
      result[:message]="修改密码成功"
    else
      result[:success]=false
      result[:errors] ={}
      admin_user.errors.each{|k,v| result[:errors]["#{k}"] = v }
      result[:errormsg]="错误,不能保存"        
    end

    render :text => result.to_json,:layout=>false
    return
  end
  def dbclick_on_grid
    edit
  end
  
  def save
    result = {}
    model_id = params[:model].delete(:id)
    if model_id.blank?
      # insert
      admin_user = AdminUser.new(params[:model])
      admin_user.is_active = true  
      admin_user.allow_multi_login = false
      admin_user.need_change_password = true
      if admin_user.save
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_user.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能新增,请检查数据正确性"        
      end
      render :text => result.to_json,:layout=>false
      return
    else
      # update
      admin_user = AdminUser.find(model_id)
      if admin_user.update_attributes(params[:model])
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_user.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能保存"        
      end

      render :text => result.to_json,:layout=>false
      return
    end
  end

  def delete
    @admin_user = AdminUser.find(params[:id])
    result = Hash.new
    begin
      @admin_user.destroy
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_user.errors.each{|k,v| result[:errors]["admin_user[#{k}]"] = v }
      result[:errormsg]="错误,不能删除"        
    end
    render :text => result.to_json(),:layout=>false
  end
  def disable
    @admin_user = AdminUser.find(params[:id])
    result = Hash.new
    begin
      @admin_user.is_active = false
      @admin_user.save
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_user.errors.each{|k,v| result[:errors]["admin_user[#{k}]"] = v }
      result[:errormsg]="错误,停用失败"        
    end
    render :text => result.to_json(),:layout=>false
  end
  def enable
    @admin_user = AdminUser.find(params[:id])
    result = Hash.new
    begin
      @admin_user.is_active = true
      @admin_user.save
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_user.errors.each{|k,v| result[:errors]["admin_user[#{k}]"] = v }
      result[:errormsg]="错误,启用失败"        
    end
    render :text => result.to_json(),:layout=>false
  end
  
  #用户授权
  def auth_setting
    @admin_user = AdminUser.find(params[:id])
    render :layout=>false
  end
  def auth_setting_data
    @admin_user = AdminUser.find(params[:id])
    render :text => [@admin_user.auth_setting_tree_hash].to_json(),:layout=>false
  end
  def auth_setting_submit
    @admin_user = AdminUser.find(params[:id])
    @admin_user.auth_functions(params[:allow_function_ids])

    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
end
