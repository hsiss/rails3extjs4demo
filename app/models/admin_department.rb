class AdminDepartment < ActiveRecord::Base
  
  validates_presence_of :code
  validates_presence_of :name 
  validates_uniqueness_of :code
  validates_uniqueness_of :name
  
  
  def self.to_extjs_combo_store_allow_all
    result = {:xtype=>'arraystore',:fields=>['id','name','display_text'],:data=>[["","全部"]]+self.to_extjs_combo_data}
  end
  def self.to_extjs_combo_store
    result = {:xtype=>'arraystore',:fields=>['id','name','display_text'],:data=>self.to_extjs_combo_data}
  end
  def self.to_extjs_combo_data
    self.all(:order=>'code').collect{|i| [i.id,i.name,i.display_text]}
  end
  def display_text
    "#{code} #{name}"
  end
  def to_s
    "#{name}"
  end
  # 给编辑表单提供数据
  def edit_form_data
    self.attributes
  end
end
