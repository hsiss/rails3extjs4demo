class AdminEmployerController < ApplicationController
  def list
    check_acl('app_employer')
    render :layout=>false
  end
  def list_data
    params[:limit] =  params[:limit] || AdminMendian.per_page
    params[:offset] = params[:start] || 0
    result = AdminEmployer.list_data(params)
    render :text=>result.to_json, :layout=>false
  end
  def new
    @admin_employer = AdminEmployer.new
    render :action=>:edit,:layout=>false
  end
  
  def edit
    @admin_employer = AdminEmployer.find(params[:id])
    render :action=>:edit,:layout=>false
  end

  def save
    result = {}
    model_id = params[:model].delete(:id)
    if model_id.blank?
      # insert
      admin_employer = AdminEmployer.new(params[:model])
      admin_employer.is_active = true
      admin_employer.mendian_name = admin_employer.mendian && admin_employer.mendian.name
      if admin_employer.save
        admin_employer.export_as_user
        result[:success]=true
        result[:message] = "新增员工成功"
      else
        result[:success]=false
        result[:errors] ={}
        admin_employer.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能新增,请检查数据正确性"        
      end
      render :text => result.to_json
      return
    else
      # update
      admin_employer = AdminEmployer.find(model_id)
      if admin_employer.update_attributes(params[:model])
        admin_employer.mendian_name = admin_employer.mendian && admin_employer.mendian.name
        admin_employer.save
        result[:success]=true
      else
        result[:success]=false
        result[:errors] ={}
        admin_employer.errors.each{|k,v| result[:errors]["#{k}"] = v }
        result[:errormsg]="错误,不能保存"        
      end

      render :text => result.to_json
      return
    end
  end

  

  def disable
    @admin_employer = AdminEmployer.find(params[:id])
    result = Hash.new
    begin
      @admin_employer.is_active = false
      @admin_employer.save!
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_employer.errors.each{|k,v| result[:errors]["admin_employer[#{k}]"] = v }
      result[:errormsg]="错误,不能禁用"        
    end
    render :text => result.to_json
  end

  def enable
    @admin_employer = AdminEmployer.find(params[:id])
    result = Hash.new
    begin
      @admin_employer.is_active = true
      @admin_employer.save!
      result[:success]=true
    rescue
      result[:success]=false
      result[:errors] ={}
      @admin_employer.errors.each{|k,v| result[:errors]["admin_employer[#{k}]"] = v }
      result[:errormsg]="错误,不能启用"        
    end
    render :text => result.to_json
  end

  #导出为用户
  def export_as_user
    @admin_employer = AdminEmployer.find(params[:id])
      
    @admin_employer.export_as_user
    result = Hash.new
    result[:success]=true
    result[:message]="已经创建用户,用户名和密码都是员工的编码,请设置权限"
    render :text => result.to_json,:layout=>false
  end
  
  
  def select_list
    @car_store_id = params[:car_store_id]
    render :action=>:select_list,:layout=>false
  end

  def query_employer
    @is_quary_employer = true
    render :action=>:select_list,:layout=>false
  end
  
  #业务员选择窗口
  def yewuyuan_select_window
    render :layout=>false
  end
  #业务员选择列表数据
  def yewuyuan_select_listdata
    find_option ={}
    find_option[:limit] =  params[:limit] || 20
    find_option[:offset] = params[:start] || 0
    if params[:sort]
      find_option[:order] = params[:sort]
      find_option[:order] +=' '+ (params[:dir] || 'ASC')
    end
    where = []
    where << "a.department_id in (select id from comm_departments where is_xiaoshou=1)"
    unless params[:code].blank?
      where << "a.code like '%#{params[:code]}%'"
    end
    unless params[:name].blank?
       where << "a.name like '%#{params[:name]}%'"
    end
    unless params[:is_active].blank?
       where << "a.is_active = 1"
    end
    
    unless params[:department_id].blank?
       where << "a.department_id = '#{params[:department_id]}'"
    end
    
    unless params[:car_store_id].blank?
      where << "a.store_id = #{params[:car_store_id]}"
    end
    find_option[:conditions] = where.join(' and ')

    find_option[:select]="a.*,
      s.name as store_name,
      d.name as department_name
      "
    find_option[:joins]="as a 
      left outer join comm_departments d on d.id=a.department_id
      left outer join car_stores s on s.id=a.store_id
          "
    result = Hash.new
    result[:totalCount] =  AdminEmployer.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminEmployer.find(:all, find_option ).collect{|i| i.attributes}
    render :text => result.to_json(),:layout=>false    
  end
  
  #批售人员列表
  def pishou_list
    check_acl('app_employer')
    render :layout=>false
  end
  # 批售人员数据列表
  def pishou_list_data
    params[:limit] =  params[:limit] || 50
    params[:start] = params[:start] || 0
    params[:include_disable]=true
    params[:only_disable]=true
      
    result = do_pishou_list_data(params)
    render :text => result.to_json(),:layout=>false
  end
  
  #批售人员导出到excel
  def pishou_export_to_excel
    query_params = params
    query_params.delete(:limit)
    query_params.delete(:start)
    result = do_pishou_list_data(query_params)
  
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "批售人员清单"
  
    sheet1.row(0).default_format = Spreadsheet::Format.new :color => :black, :weight => :bold, :size => 10
  
    keys = params[:columns].keys.compact.collect{|key| key.to_i}.sort.collect{|key| key.to_s}
  
    sheet1.row(0).concat(keys.collect{|key| params[:columns][key][:column_header]})
    row_num = 1
    result[:rows].each do |row|
      sheet1.row(row_num).concat keys.collect{|key| row[params[:columns][key][:data_index]]}
      row_num = row_num + 1
    end
    keys.each_with_index  do |key,index|
      sheet1.column(index).width = params[:columns][key][:column_width].to_f/10
    end
  
    book.write xls_report
  
    send_data(xls_report.string,
      :filename => 'pishou.xls',
      :type => 'application/vnd.ms-excel',
      :disposition => 'inline')
  end
  #新指定员工为批售人员
  def new_pishou
    @admin_employer = AdminEmployer.find(params[:id])
    @admin_employer.is_pishou_yewuyuan = true
    @admin_employer.save
    result = Hash.new
    result[:success]=true
    result[:message]="成功设置#{@admin_employer}为批售人员"        
    render :text => result.to_json(),:layout=>false    
  end
  #指定员工取消批售资格
  def cancel_pishou
    @admin_employer = AdminEmployer.find(params[:id])
    @admin_employer.is_pishou_yewuyuan = false
    @admin_employer.save
    result = Hash.new
    result[:success]=true
    result[:message]="成功取消#{@admin_employer}批售资格"        
    render :text => result.to_json(),:layout=>false    
  end
  
  def extjs_jianyan_employer_list
    check_acl('app_employer')
    render :layout=>false
  end
  
  def extjs_jianyan_employer_list_data
    find_option ={}
    find_option[:limit] =  params[:limit]
    find_option[:offset] = params[:start]
    if params[:sort]
      find_option[:order] = params[:sort]
      find_option[:order] +=' '+ (params[:dir] || 'ASC')
    end
    where = []
    where << "a.is_repair_jianyanyuan = 1"
    unless params[:code].blank?
      where << "a.code like '%#{params[:code]}%'"
    end
    unless params[:name].blank?
       where << "a.name like '%#{params[:name]}%'"
    end
    unless params[:is_active].blank?
       where << "a.is_active = 1"
    end
    
    unless params[:department_id].blank?
       where << "a.department_id = '#{params[:department_id]}'"
    end
    
    unless params[:car_store_id].blank?
      where << "a.store_id = #{params[:car_store_id]}"
    end
    find_option[:conditions] = where.join(' and ')

    find_option[:select]="a.*,
      s.name as store_name,
      d.name as department_name
      "
    find_option[:joins]="as a 
      left outer join comm_departments d on d.id=a.department_id
      left outer join car_stores s on s.id=a.store_id
          "
    result = Hash.new
    result[:totalCount] =  AdminEmployer.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminEmployer.find(:all, find_option ).collect{|i| i.attributes}
    render :text => result.to_json(),:layout=>false
  end
  
    
  def add_new_jianyan_employer
    result = Hash.new
    items = params[:items]
    items.each do |i|
      begin
        admin_employer = AdminEmployer.find(i)
        admin_employer.is_repair_jianyanyuan = 1
        admin_employer.save
        result[:success]=true
      rescue
        result[:success]=false
        result[:errormsg]="错误,设置失败"
        render :text => result.to_json(),:layout=>false
        return
      end
    end
    render :text => result.to_json(),:layout=>false    
  end
  
  def cancel_repair_jianyan_employer
    @admin_employer = AdminEmployer.find(params[:id])
    result = Hash.new
    begin
      @admin_employer.is_repair_jianyanyuan = false
      @admin_employer.save
      result[:success]=true
    rescue
      result[:success]=false
      result[:errormsg]="错误,删除失败"
    end
    render :text => result.to_json(),:layout=>false
  end
  
  private
  #批售数据
  def do_pishou_list_data(params)
    find_option ={}
    find_option[:limit] =  params[:limit]
    find_option[:offset] = params[:start]
    if params[:sort]
      find_option[:order] = params[:sort]
      find_option[:order] +=' '+ (params[:dir] || 'ASC')
    end
    where = []
    where << "a.is_pishou_yewuyuan = 1"
    unless params[:code].blank?
      where << "a.code like '%#{params[:code]}%'"
    end
    unless params[:name].blank?
       where << "a.name like '%#{params[:name]}%'"
    end
    unless params[:is_active].blank?
       where << "a.is_active = 1"
    end
    
    unless params[:department_id].blank?
       where << "a.department_id = '#{params[:department_id]}'"
    end
    
    unless params[:car_store_id].blank?
      where << "a.store_id = #{params[:car_store_id]}"
    end
    find_option[:conditions] = where.join(' and ')

    find_option[:select]="a.*,
      s.name as store_name,
      d.name as department_name
      "
    find_option[:joins]="as a 
      left outer join comm_departments d on d.id=a.department_id
      left outer join car_stores s on s.id=a.store_id
          "
    result = Hash.new
    result[:totalCount] =  AdminEmployer.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminEmployer.find(:all, find_option ).collect{|i| i.attributes}
    result
  end
  
end
