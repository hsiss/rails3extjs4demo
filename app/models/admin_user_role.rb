class AdminUserRole < ActiveRecord::Base
  belongs_to :user,:foreign_key=>'user_id',:class_name=>'AdminUser'
  belongs_to :role,:foreign_key=>'role_id',:class_name=>'AdminRole'
end
