class AdminUserAuth < ActiveRecord::Base
  belongs_to :user,:foreign_key=>'user_id',:class_name=>'AdminUser'
  belongs_to :function,:foreign_key=>'function_id',:class_name=>'AdminFunction'
end
