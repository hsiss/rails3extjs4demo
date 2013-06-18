class InsertAdminInitData < ActiveRecord::Migration
  def up
    u = AdminUser.find_by_username('admin')
    u.delete if u
    
    u = AdminUser.new
    u.username='admin'
    u.password='123456'
    u.is_active = true
    u.name = '系统管理员'
    u.need_change_password = false
    u.allow_multi_login = true
    u.save!
    
    all_function = AdminFunction.create(:code=>'all_function',:name=>'所有功能',
        :is_menu=>true,:is_function_menu=>false,:is_active=>true,:need_auth=>true)
    
    biz = AdminFunction.create(:code=>'biz',:name=>'业务处理',
        :is_menu=>true,:is_function_menu=>false,:is_active=>true,:need_auth=>true)
    biz.move_to_child_of(all_function)

    master_data = AdminFunction.create(:code=>'md',:name=>'基础信息',
        :is_menu=>true,:is_function_menu=>false,:is_active=>true,:need_auth=>true)
    master_data.move_to_child_of(all_function)

    sys = AdminFunction.create(:code=>'sys',:name=>'系统管理',
        :is_menu=>true,:is_function_menu=>false,:is_active=>true,:need_auth=>true)
    sys.move_to_child_of(all_function)
    
    
    #系统管理
    sys = AdminFunction.find_by_code("sys")

    #门店
    admin_mendian = AdminFunction.create(
      :code=>'admin_mendian', :name=>'门店管理',
      :is_menu=>true, :is_function_menu=>true, :need_auth=>true,
      :handler_method => "execute_remote_extjson",
      :handler_url=>"/admin_mendian/list",
      :is_active=>true
    )
    admin_mendian.move_to_child_of(sys)

    #员工
    admin_employer = AdminFunction.create(
      :code=>'admin_employer', :name=>'员工管理',
      :is_menu=>true, :is_function_menu=>true, :need_auth=>true,
      :handler_method => "execute_remote_extjson",
      :handler_url=>"/admin_employer/list",
      :is_active=>true
    )
    admin_employer.move_to_child_of(sys)

    #用户
    admin_user = AdminFunction.create(
      :code=>'admin_user', :name=>'用户管理',
      :is_menu=>true, :is_function_menu=>true, :need_auth=>true,
      :handler_method => "execute_remote_extjson",
      :handler_url=>"/admin_user/list",
      :is_active=>true
    )
    admin_user.move_to_child_of(sys)
            
    #角色
    admin_role = AdminFunction.create(
      :code=>'admin_role', :name=>'角色管理',
      :is_menu=>true, :is_function_menu=>true, :need_auth=>true,
      :handler_method => "execute_remote_extjson",
      :handler_url=>"/admin_role/list",
      :is_active=>false
    )
    admin_role.move_to_child_of(sys)

    #部门
    admin_department = AdminFunction.create(
      :code=>'admin_department', :name=>'部门管理',
      :is_menu=>true, :is_function_menu=>true, :need_auth=>true,
      :handler_method => "execute_remote_extjson",
      :handler_url=>"/admin_department/list",
      :is_active=>false
    )
    admin_department.move_to_child_of(sys)
    
    
    web = AdminFunction.find_by_code('web')
    web.delete if web
    web = AdminFunction.create(:code=>'web',:name=>'网站内容管理',
        :is_menu=>true,:is_function_menu=>false,
        :is_active=>true,:need_auth=>1
    )
    web.move_to_child_of(all_function)

    article_list = AdminFunction.find_by_code('article_list')
    article_list.delete if article_list
    article_list = AdminFunction.create(:code=>'article_list',:name=>'文章管理',
        :is_menu=>true,:is_function_menu=>true,
        :is_active=>true,:need_auth=>1,
        :handler_url=>"/web_article/list",
        :handler_method=>"execute_remote_extjson"
    )
    article_list.move_to_child_of(web)
  end

  def down
  end
end
