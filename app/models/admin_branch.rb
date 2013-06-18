class AdminBranch < ActiveRecord::Base
  set_table_name :admin_branchs
  
  validates_presence_of :code
  validates_presence_of :name 
  validates_uniqueness_of :code
  validates_uniqueness_of :name
  
  def AdminBranch.to_extjs_combo_store_allow_all
    result = {:xtype=>'arraystore',:fields=>['id','display_text'],:data=>[["","全部"]]+self.all_combo_data}
  end

  def AdminBranch.to_extjs_combo_store
    result = {:xtype=>'arraystore',:fields=>['id','display_text'],:data=>self.all_combo_data}
  end
  def AdminBranch.all_combo_data
    self.all(:order=>'code').collect{|i| [i.id,i.display_text]}
  end
  def display_text
    "#{code} #{name}"
  end
end
