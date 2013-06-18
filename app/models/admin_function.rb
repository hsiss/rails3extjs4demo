class AdminFunction < ActiveRecord::Base
  acts_as_nested_set
  
  #需要权限认证的子节点
  has_many :need_auth_children,:class_name => 'AdminFunction',:foreign_key => 'parent_id',:conditions=>"need_auth='1'",:order=>'lft'
  #菜单子节点
  has_many :menu_children,:class_name => 'AdminFunction',:foreign_key => 'parent_id',:conditions=>"is_menu='1' and is_active='1'",:order=>'lft'
  #功能菜单子节点  
  has_many :function_menu_children,:class_name => 'AdminFunction',:foreign_key => 'parent_id',:conditions=>"is_function_menu='1'",:order=>'lft'

  #所有功能菜单
  def self.all_function_menu
    AdminFunction.all(:conditions=>"is_function_menu='1'")
  end
  def self.root_function
    AdminFunction.first(:order=>:lft)
  end
  def self.all_active
    AdminFunction.all(:conditions=>"is_active='1'")
  end
  
  #权限设置树
  def self.all_auth_setting_tree_node(checked_functions)
    self.root_function.to_auth_setting_tree_node(checked_functions)
  end
  #权限设置树的一个节点
  def to_auth_setting_tree_node(checked_functions)
    { 
      :id => self.id,
      :text => self.name,
      :leaf => self.children.count==0,
      :checked => checked_functions.include?(self),
      :expanded=>true,
      :children => self.need_auth_children.collect{|c| c.to_auth_setting_tree_node(checked_functions)}
    }
  end
  
  #菜单树的一个节点
  def to_menu_tree_node(checked_functions)
    return nil if !checked_functions.include?(self)

    ret={ 
      :text => self.name,
      :leaf => self.is_function_menu?,
      :hidden => !checked_functions.include?(self),
#      :expanded=> self.level<=2 ,
      :singleClickExpand => !self.leaf?, 
      :children => self.menu_children.collect{|c| c.to_menu_tree_node(checked_functions)}.compact
    }
    if self.handler_method && self.handler_url
      ret[:listeners]={:itemclick=> "function(view,record){#{self.handler_method}('#{self.handler_url}');}".uq}
    elsif self.handler
      ret[:listeners]={:itemclick=> "function(n){#{self.handler}}".uq}
    else
      ret[:disabled]=true if self.leaf?
    end
    ret
  end
    
  def self.find_by_code(code)
    self.first(:conditions=>['code=?',code])
  end
  
  def self.create_or_update(attributes = nil)
    code = attributes[:code] || attributes['code']
    f = AdminFunction.find_by_code(code)
    if f
      f.update_attributes(attributes)
    else
      f=AdminFunction.create(attributes)
    end
    f
  end
  def to_ruby_code
    ret=''
    h = self.attributes
    ['lft','id','rgt','parent_id'].each{|a| h.delete(a)}
    ret << "\n#{' '*2*self.level}#{self.code}=AdminFunction.create(#{h.inspect})"
    if self.parent
      ret << "\n#{' '*2*self.level}#{self.code}.move_to_child_of(#{self.parent.code})" 
    end
    return ret
  end
  #如果存在就删除
  def self.delete_by_code_if_exist(code)
    f = self.find_by_code(code)
    if f && f.children.count>0
      raise "ERROR: Can't delete a admin_function(#{code}) because exist children"
    end
    f.delete if f
  end
  #创建子节点
  def self.crate_as_child_of(parent_code,data)
    p = self.find_by_code(parent_code)
    unless p
      raise "ERROR: no parent admin_function(#{code}) exist"
    end
    f = self.create(data)
    f.move_to_child_of(p)
  end

end
