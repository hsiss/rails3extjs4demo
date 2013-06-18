class AdminMendianController < ApplicationController
  def list
    check_acl('admin_mendian')
    render
  end
  
  def list_data
    params[:limit] =  params[:limit] || AdminMendian.per_page
    params[:offset] = params[:start] || 0
    result = AdminMendian.list_data(params)
    render :text => result.to_json
  end
  
  def new
    @admin_mendian = AdminMendian.new
    render :action=>:edit
  end
  
  def edit
    @admin_mendian = AdminMendian.find(params[:id])
    render :action=>:edit
  end

  def save
    result = {}
    model_id = params[:model].delete(:id)
    if model_id.blank?
      # insert
      admin_mendian = AdminMendian.new(params[:model])
      admin_mendian.is_active = true
      if admin_mendian.save
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_mendian.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能新增,请检查数据正确性"        
      end
      render :text => result.to_json
      return
    else
      # update
      admin_mendian = AdminMendian.find(model_id)
      if admin_mendian.update_attributes(params[:model])
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_mendian.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能保存"        
      end

      render :text => result.to_json
      return
    end
  end
  
  def disable
    @admin_mendian = AdminMendian.find(params[:id])
    result = Hash.new
    begin
      @admin_mendian.is_active = false
      @admin_mendian.save!
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_mendian.errors.each{|k,v| result[:errors]["admin_mendian[#{k}]"] = v }
      result[:errormsg]="错误,不能禁用"        
    end
    render :text => result.to_json
  end

  def enable
    @admin_mendian = AdminMendian.find(params[:id])
    result = Hash.new
    begin
      @admin_mendian.is_active = true
      @admin_mendian.save!
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_mendian.errors.each{|k,v| result[:errors]["admin_mendian[#{k}]"] = v }
      result[:errormsg]="错误,不能启用"        
    end
    render :text => result.to_json
  end

end
