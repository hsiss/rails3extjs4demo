class AdminEmployer < ActiveRecord::Base
  belongs_to :branch,:foreign_key=>'branch_id',:class_name=>'AdminBranch'
  belongs_to :mendian,:foreign_key=>'mendian_id',:class_name=>'AdminMendian'
  belongs_to :department,:foreign_key=>'department_id',:class_name=>'AdminDepartment'
  has_many :users,:class_name=>'AdminUser',:foreign_key=>'employer_id'

  validates_presence_of :code
  validates_presence_of :name 
  validates_uniqueness_of :code
  validates_uniqueness_of :name

  after_save do |employer|
    employer.users.each do |user|
      user.mendian_id = employer.mendian_id
      user.mendian_name = employer.mendian_name
      user.save
    end
  end
    
    
  def self.to_extjs_combo_data
    self.all(:order=>'code',:conditions=>"is_active = 1").collect{|i| [i.id,i.name,i.display_text]}
  end
  def display_text
    "#{code} #{name}"
  end
  def export_as_user
    u = AdminUser.first(:conditions=>"username='#{self.code}' and name<>'#{self.name}'")
    if u
      raise "该编码已被#{u.name}占用,不能直接导为用户,请手工创建用户,并建立关联关系"
    end
    u = AdminUser.first(:conditions=>"username='#{self.code}'")
    u= AdminUser.create(:username=>self.code,:name=>self.name,:password=>self.code,:is_active=>true) unless u
    u.employer=self
    
    u.mendian_id = self.mendian_id
    u.mendian_name = self.mendian_name
    u.save
  end
  #根据部门关联出可用员工
  def self.to_extjs_combo_data_by_bumen
    result={}
    self.all(:order=>'id',:conditions => "is_active = 1").each{|i| 
      result[i.department_id.to_s]||=[]
      result[i.department_id.to_s]<<[i.id,i.display_text,i.department_id.to_s]
    }
    return result
  end
  
  #根据部门关联出当前用户所在门店的可用员工
  def self.to_extjs_combo_data_by_bumen_and_current_store
    result={}
    self.all(:order=>'id',:conditions => "is_active = 1 and store_id=#{AdminSession.current_branch_id}").each{|i| 
      result[i.department_id.to_s]||=[]
      result[i.department_id.to_s]<<[i.id,i.display_text,i.department_id.to_s]
    }
    return result
  end
  
  #根据部门关联出当前用户所在门店的销售顾问
  def self.yewuyuan_to_extjs_combo_data_by_bumen_and_current_store
    result={}
    self.all(:order=>'id',:conditions => "is_active = 1 and department_id=#{CommDepartment.xiaoshouguwen.id}").each{|i| 
      result[i.store_id.to_s]||=[]
      result[i.store_id.to_s]<<[i.id,i.display_text,i.name,i.department_id.to_s]
    }
    return result
  end
  
  #根据门店关联出可用员工
  def self.to_extjs_combo_data_by_mendian
    result={}
    result[0.to_s] = []
    self.all(:order=>'id',:conditions => "is_active = 1").each{|i| 
      result[i.store_id.to_s]||=[]
      result[i.store_id.to_s]<<[i.id,i.display_text,i.store_id.to_s,i.name.to_s]
      result[0.to_s] << [i.id,i.display_text,i.store_id.to_s,i.name.to_s]
    }
    return result
  end

  def self.to_extjs_combo_xiaoshou_data_by_mendian
    result={}
    result[0.to_s] = []
    self.all(:order=>'id',:conditions => "department_id in (select id from comm_departments where is_xiaoshou=1) and is_active = 1").each{|i| 
      result[i.store_id.to_s]||=[]
      result[i.store_id.to_s]<<[i.id,i.display_text,i.store_id.to_s,i.name.to_s]
    }
    return result
  end

  def self.to_extjs_combo_shouhou_guwen_by_mendian
    result={}
    result[0.to_s] = []
    self.all(:order=>'id',:conditions => "department_id in (select id from comm_departments where code='009') and is_active = 1").each{|i| 
      result[i.store_id.to_s]||=[]
      result[i.store_id.to_s]<<[i.id,i.display_text,i.store_id.to_s,i.name.to_s]
    }
    return result
  end
  
  def self.to_extjs_combo_fuwu_guwen_data_by_mendian
    result={}
    result[0.to_s] = []
    self.all(:order=>'id',:conditions => "department_id in (select id from comm_departments where code='009') and is_active = 1").each{|i| 
      result[i.store_id.to_s]||=[]
      result[i.store_id.to_s]<<[i.id,i.display_text,i.store_id.to_s,i.name.to_s]
      result[0.to_s] << [i.id,i.display_text,i.store_id.to_s,i.name.to_s]
    }
    return result
  end

  def self.to_extjs_combo_fuwu_guwen_by_mendian_data
    self.all(:order=>'code',:conditions=>"department_id in (select id from comm_departments where code='009') and is_active = 1").collect{|i| [i.id,i.display_text,i.store_id,i.name]}
  end
  
  def self.to_extjs_combo_fuwu_guwen_by_mendian
    result = {:xtype=>'arraystore',:fields=>['id','display_text','store_id', 'name'],:data=>self.to_extjs_combo_fuwu_guwen_by_mendian_data}
  end
  
  def self.to_extjs_combo_store_by_mendian
    result = {:xtype=>'arraystore',:fields=>['id','display_text','store_id', 'name'],:data=>self.to_extjs_combo_data_by_mendian}
  end

  def self.all_repair_employer_data 
    self.all(:conditions=>"is_active = true",:order=>'code').collect{|i| [i.id,i.name,i.display_text]}
  end
  
  def self.all_repair_employer_store
    result = {:xtype=>'arraystore',:fields=>['id','name','display_text'],:data=>self.all_repair_employer_data}
  end
  
  def self.all_employer_data 
    self.all(:conditions=>" is_active = 1 ",:order=>'code').collect{|i| [i.id,i.name]}
  end
  
  def self.all_employer_store
    result = {:xtype=>'arraystore',:fields=>['id','name'],:data=>self.all_employer_data}
  end
  
  def self.to_extjs_combo_store_by_bumen
    result = {:xtype=>'arraystore',:fields=>['id','display_text','department_id'],:data=>self.to_extjs_combo_data_by_epartment}
  end
  
  def self.to_extjs_combo_data_by_epartment
    self.all(:order=>'code',:conditions=>"is_active = 1").collect{|i| [i.id,i.display_text,i.department_id.to_s]}
  end

  def self.list_data(params)
    find_option ={}
    find_option[:limit] =  params[:limit] unless params[:limit].blank?
    find_option[:offset] = params[:offset] unless params[:offset].blank?
    unless params[:sort].blank?
      find_option[:order]=params[:sort].collect{|s| "#{s[:property]} #{s[:direction] || 'ASC'}"}.join(",")
    end
    
    conditions = []
    unless params[:code].blank?
      conditions << " a.code like '%#{params[:code]}%' "
    end
    unless params[:name].blank?
      conditions << " a.name like '%#{params[:name]}%' "
    end
    unless params[:is_active].blank?
      conditions << "a.is_active = #{params[:is_active]}"
    end
    unless params[:department_id].blank?
      conditions << "a.department_id = '#{params[:department_id]}'"
    end
    
    unless params[:mendian_id].blank?
      conditions << "a.mendian_id = #{params[:mendian_id]}"
    end

    where = conditions.blank? ? "" : "where #{conditions.join(' and ')}"
    
    sql = "select a.*
      from admin_employers as a 
      #{where}
    "

    result = {}
    
    countsql = "select count(*) from (#{sql}) t"
    result[:totalCount] = ActiveRecord::Base.connection.select_value(countsql)
      
    sql << " order by #{find_option[:order]}" unless find_option[:order].blank?
    ActiveRecord::Base.connection.add_limit_offset!(sql,find_option)
    result[:rows] = ActiveRecord::Base.connection.select_all(sql)

    return result
  end
end
