class AdminRoleController < ApplicationController  
  def list
    check_acl('admin_role')
    render :layout=>false
  end
  def list_data
    check_acl('admin_role')
    params[:limit] =  params[:limit] || 50
    params[:start] = params[:start] || 0
    result = AdminRole.listdata(params)
    render :text => result.to_json,:layout=>false
  end
  def new
    @admin_role = AdminRole.new
    render :action=>:edit,:layout=>false
  end
  
  def edit
    @admin_role = AdminRole.find(params[:id])
    render :action=>:edit,:layout=>false
  end
  
  #角色授权
  def auth_setting
    @admin_role = AdminRole.find(params[:id])
    render :layout=>false
  end
  def auth_setting_data
    @admin_role = AdminRole.find(params[:id])
    render :text => [@admin_role.auth_setting_tree_hash].to_json,:layout=>false
  end
  def auth_setting_submit
    @admin_role = AdminRole.find(params[:id])
    @admin_role.auth_functions(params[:allow_function_ids])

    result = Hash.new
    result[:success]=true
    render :text => result.to_json,:layout=>false
  end
  
  def create
    @admin_role = AdminRole.new(params[:admin_role])
    result = Hash.new
    if @admin_role.save
      result[:success]=true
    else
      result[:success]=false
      result[:errors] ={}
      @admin_role.errors.each{|k,v| result[:errors]["admin_role[#{k}]"] = v }
      result[:errormsg]="错误,不能保存"        
    end
    render :text => result.to_json,:layout=>false
  end
  
  def update
    @admin_role = AdminRole.find(params[:id])
    result = Hash.new
    if @admin_role.update_attributes(params[:admin_role])
      result[:success]=true
    else
      result[:success]=false
      result[:errors] ={}
      @admin_role.errors.each{|k,v| result[:errors]["admin_role[#{k}]"] = v }
      result[:errormsg]="错误,不能保存"        
    end
    render :text => result.to_json,:layout=>false
  end
  def delete
    @admin_role = AdminRole.find(params[:id])
    result = Hash.new
    begin
      @admin_role.destroy
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_role.errors.each{|k,v| result[:errors]["admin_role[#{k}]"] = v }
      result[:errormsg]="错误,不能删除"        
    end
    render :text => result.to_json,:layout=>false
  end

end
