class AdminRole < ActiveRecord::Base
  validates_presence_of :code
  validates_presence_of :name 
  validates_uniqueness_of :code
  validates_uniqueness_of :name
  
  has_many :userroles,:class_name => 'AdminUserRole',:foreign_key => 'role_id'
  has_many :users,:class_name => 'AdminUser',:through=>:userroles

  has_many :rolefunctions,:class_name => 'AdminRoleAuth',:foreign_key => 'role_id'
  has_many :functions,:class_name => 'AdminFunction',:through=>:rolefunctions
  has_many :checked_functions,:class_name => 'AdminFunction',:through=>:rolefunctions,:source=>:function,:conditions=>'admin_role_auths.checked=1'

  def self.to_extjs_combo_store
    result = {:xtype=>'arraystore',:fields=>['id','display_text'],:data=>self.to_extjs_combo_data}
  end
  def self.to_extjs_combo_data
    self.all(:order=>'code').collect{|i| [i.id,i.display_text]}
  end
  def display_text
    "#{code} #{name}"
  end
  #用户checkbox array
  def user_checkbox_array
    self.users.collect{|u| {}}
  end
  
  def auth_setting_tree_hash
    result=AdminFunction.all_auth_setting_tree_node(self.checked_functions)
    return result
  end
  
  def prepare_auth_setting
    AdminFunction.all().each do |f|
      self.rolefunctions.create({:function=>f,:checked=>false}) unless self.functions.include?(f)
    end
  end
  
  #授权
  def auth_functions(allow_function_ids)
    sql = "delete from admin_role_auths where role_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)

    unless allow_function_ids.blank?
      allow_function_ids.each do |f| 
        self.rolefunctions.create({:function_id=>f,:checked=>true})
      end
    end
    checked_functions = self.checked_functions
    ancestor_functions = []
    checked_functions.each do |f|
      ancestor_functions=ancestor_functions+f.ancestors
    end
    ancestor_functions.uniq!
    ancestor_functions.each do |f|
      unless checked_functions.include?(f)
        self.rolefunctions.create({:function=>f,:checked=>true})
      end
    end
    self.update_rolefunctions_code
  end
  #更新改角色所有rolefunctions的code
  def update_rolefunctions_code  
    sql = "update admin_role_auths set function_code=(
               select code from admin_functions where id = admin_role_auths.function_id)
           where role_id=#{self.id}
    "
    ActiveRecord::Base.connection.execute(sql)
  end
  
  
  
  def AdminRole.listdata(params)
    find_option ={}
    find_option[:limit] =  params[:limit] || 50
    find_option[:offset] = params[:start] || 0
    if params[:sort] && params[:sort][:property]
      find_option[:order] = params[:sort][:property]
      find_option[:order] +=' '+ (params[:sort][:direction] || 'ASC')
    else
      find_option[:order] = "id asc"
    end
    
    conditions = []
    unless params[:code].blank?
      conditions << " a.code like '%#{params[:code]}%' "
    end
    unless params[:name].blank?
      conditions << " a.name like '%#{params[:name]}%' "
    end
    
    where = conditions.blank? ? "" : "where #{conditions.join(' and ')}"
    
    sql = "select * from admin_roles a #{where}"
    result = {}
    
    countsql = "select count(*) from ("+sql+") t"
    result[:totalCount] = ActiveRecord::Base.connection.select_value(countsql)
      
    sql << " order by #{find_option[:order]}" unless find_option[:order].blank?
    ActiveRecord::Base.connection.add_limit_offset!(sql,find_option)
    result[:rows] = ActiveRecord::Base.connection.select_all(sql)
    return result
  end
end
