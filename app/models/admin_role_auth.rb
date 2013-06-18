class AdminRoleAuth < ActiveRecord::Base
  belongs_to :role,:foreign_key=>'role_id',:class_name=>'AdminRole'
  belongs_to :function,:foreign_key=>'function_id',:class_name=>'AdminFunction'
end
