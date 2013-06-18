class AdminDepartmentController < ApplicationController
  def list
    check_acl('admin_department')
    render :layout=>false
  end
  def list_data
    check_acl('admin_department')
    find_option ={}
    find_option[:limit] =  params[:limit] || 20
    find_option[:offset] = params[:start] || 0
    if params[:sort] && params[:sort][:property]
      find_option[:order] = params[:sort][:property]
      find_option[:order] +=' '+ (params[:sort][:direction] || 'ASC')
    else
      find_option[:order] = "id asc"
    end
    where = []
    unless params[:code].blank?
      where << "a.code like '%#{params[:code]}%'"
    end

    result = Hash.new
    result[:totalCount] =  AdminDepartment.count
    result[:rows] = AdminDepartment.find(:all, find_option ).collect{|i| i.attributes}
    render :text => result.to_json(),:layout=>false
  end
  def new
    @admin_department = AdminDepartment.new
    render :action=>:edit,:layout=>false
  end
  
  def edit
    @admin_department = AdminDepartment.find(params[:id])
    render :action=>:edit,:layout=>false
  end

  def save
    result = {}
    model_id = params[:model].delete(:id)
    puts params[:model].to_json
    if model_id.blank?
      # insert
      admin_department = AdminDepartment.new(params[:model])
      if admin_department.save
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_department.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能新增,请检查数据正确性"        
      end
      render :text => result.to_json,:layout=>false
      return
    else
      # update
      admin_department = AdminDepartment.find(model_id)
      if admin_department.update_attributes(params[:model])
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_department.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能保存"        
      end

      render :text => result.to_json,:layout=>false
      return
    end
  end
  
  def extjs_delete
    @admin_department = AdminDepartment.find(params[:id])
    result = Hash.new
    begin
      @admin_department.destroy
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_department.errors.each{|k,v| result[:errors]["admin_department[#{k}]"] = v }
      result[:errormsg]="错误,不能删除"        
    end
    render :text => result.to_json(),:layout=>false
  end

end
