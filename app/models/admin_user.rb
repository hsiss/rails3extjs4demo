class AdminUser < ActiveRecord::Base
  has_many :userroles,:class_name => 'AdminUserRole',:foreign_key => 'user_id'
  has_many :roles,:class_name => 'AdminRole',:through=>:userroles

  belongs_to :mendian,:foreign_key=>'mendian_id',:class_name=>'AdminMendian'
  #用户权限  
  has_many :userfunctions,:class_name => 'AdminUserAuth',:foreign_key => 'user_id'
  has_many :functions,:class_name => 'AdminFunction',:through=>:userfunctions
  has_many :checked_functions,:class_name => 'AdminFunction',:through=>:userfunctions,:source=>:function,:conditions=>'admin_user_auths.checked=1'
  
  #extjs组件状态
  has_many :extjs_states,:class_name => 'AdminUserExtjsState',:foreign_key => 'user_id' 
  
  belongs_to :employer,:foreign_key=>'employer_id',:class_name=>'AdminEmployer'
  
  validates_presence_of :username
  validates_uniqueness_of :username
  
  attr_accessor :password_comirmation
#  validates_confirmation_of :password

  def self.list_data(params)
    find_option ={}
    find_option[:limit] =  params[:limit] unless params[:limit].blank?
    find_option[:offset] = params[:offset] unless params[:offset].blank?
    unless params[:sort].blank?
      params[:sort].each do |s|
        s[:property] = "a.#{s[:property]}" unless ['employer_name'].include?(s[:property])
      end
      find_option[:order]=params[:sort].collect{|s| "#{s[:property]} #{s[:direction] || 'ASC'}"}.join(",")
    end
    
    where = []
    unless params[:username].blank?
      where << "a.username like '%#{params[:username]}%'"
    end
    unless params[:name].blank?
       where << "a.name like '%#{params[:name]}%'"
    end
    unless params[:role_id].blank?
       where << "r.id = #{params[:role_id]}"
    end
    unless params[:is_active].blank?
       where << "a.is_active = #{params[:is_active]}"
    end
    unless params[:branch_id].blank?
      where << "br.id = #{params[:branch_id]}"
    end
    find_option[:conditions] = where.join(' and ')

    find_option[:select]="a.*,
      e.name employer_name
          "
    #TODO注意：如果一个用户有多个角色的时候数据会不对
    find_option[:joins]="as a 
      left outer join admin_employers e on e.id=a.employer_id
      left outer join admin_mendians md on md.id=e.mendian_id
          "

    result = Hash.new
    result[:totalCount] =  AdminUser.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminUser.find(:all, find_option ).collect{|i| i.attributes}

    return result
  end
  
  #授权-权限设置数的数据hash  
  def auth_setting_tree_hash
    result=AdminFunction.all_auth_setting_tree_node(self.checked_functions)
    return result
  end
  #授权
  def auth_functions(allow_function_ids)
    sql = "delete from admin_user_auths where user_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)

    unless allow_function_ids.blank?
      allow_function_ids.each do |f| 
        self.userfunctions.create({:function_id=>f,:checked=>true})
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
        self.userfunctions.create({:function=>f,:checked=>true})
      end
    end
    self.update_userfunctions_code
  end
  
  #更新改角色所有userfunctions的code
  def update_userfunctions_code  
    sql = "update admin_user_auths set function_code=(
               select code from admin_functions where id = admin_user_auths.function_id)
           where user_id=#{self.id}
    "
    ActiveRecord::Base.connection.execute(sql)
  end
  
  #认证-允许的功能清单
  def allowed_functions
    return AdminFunction.all_active if self.username=='admin'
    sql="
      select distinct * from (
        select f.* from admin_users u
        join admin_user_roles ur on ur.user_id=u.id
        join admin_roles r on r.id=ur.role_id
        join admin_role_auths rf on rf.role_id=r.id and checked=1
        join admin_functions f on f.id=rf.function_id
        where u.id=#{self.id}
      union all
      select f.* from admin_functions f
        join admin_user_auths uf on f.id=uf.function_id
        where uf.user_id=#{self.id} and uf.checked=1
      union all
      select f.* from admin_functions f where f.need_auth=0
      ) a where a.is_active = 1
    "
    AdminFunction.find_by_sql(sql)
  end
  
  #认证-允许访问
  def allow_access?(function_code)
    return true if self.username=='admin'
    
    #批售人员默认具有查看批售数据的权限
    if function_code == 'special_pishou_view' && self.employer && self.employer.is_pishou_yewuyuan?
      return true
    end
    
    #角色权限中包含
    sql="
      select count(*) cnt from admin_users u
      join admin_user_roles ur on ur.user_id=u.id
      join admin_roles r on r.id=ur.role_id
      join admin_role_auths rf on rf.role_id=r.id and checked=1
      join admin_functions f on f.id=rf.function_id
      where u.id=#{self.id} and f.code='#{function_code}'
    "
    cnt = self.connection.select_value(sql)
    return true if cnt.to_i>0
    
    #用户权限中包含
    sql="
      select count(*) cnt from admin_functions f
      join admin_user_auths uf on f.id=uf.function_id
      where uf.checked=1 and uf.user_id=#{self.id} and f.code='#{function_code}'
    "
    cnt = self.connection.select_value(sql)
    return true if cnt.to_i>0
    
    return false
  end
  
  #主菜单树
  def function_accordion_jsondata
    ret=[]
    functions = allowed_functions
    AdminFunction.root.menu_children.each do |first_level|
      if functions.include?(first_level)
        h = first_level.to_menu_tree_node(functions)
        h[:children].first[:expanded]=true if h[:children] && h[:children].first 
#        ret << {:title=>first_level.name,
#          :layout=>'fit',
#          :items=>{
#            :xtype=>'treepanel',
#            :autoScroll=>true,
#            :containerScroll=>true,
#            :animate => true,
#            :border => false,
#            :rootVisible => false,
#            :loader=> "new Ext.tree.TreeLoader()".uq,
#            :root=>"new Ext.tree.AsyncTreeNode(#{h.to_json})".uq
#          },
#          :listeners => "{
#              'show':{
#                  fn: function(p){
#                      alert(p);
#                      console.log(p);
#                  }
#              }
#          }".uq
#        }
          
        this_node = {
            :xtype=>'treepanel',
            :title=>first_level.name,  
            :autoScroll=>true,
            :containerScroll=>true,
            :animate => true,
            :border => false,
            :rootVisible => false,
            :store => "Ext.create('Ext.data.TreeStore', {
                root: #{h.to_json}
            })".uq,
            :listeners=>{:itemclick=> "
                function(view,record){
                  if(record.raw.listeners && record.raw.listeners.itemclick){
                    record.raw.listeners.itemclick.call(view,record);
                  }
                }".uq
            }
        }
        #TODO
        this_node[:iconCls]=first_level.icon_cls unless first_level.icon_cls.blank?
        if first_level.handler_method && first_level.handler_url
          this_node[:listeners] = "{
              expand:{
                  fn: function(){#{first_level.handler_method}('#{first_level.handler_url}');},
                  single:true
              }
          }".uq
        elsif first_level.handler
          this_node[:listeners] = "{
              expand:{
                  fn: function(n){#{first_level.handler}},
                  single:true
              }
          }".uq
        end
        ret << this_node
      end
    end
    return ret
  end
    
#  def validate
#    errors.add_to_base("请输入密码!") if password_hashed.blank?    
#  end
  
  def role_id
    roles && roles.first && roles.first.id
  end
  def role_id=(role_id)
    userroles.delete_all
    userroles.build({:role_id=>role_id})
  end
  #
  def roles_text
    self.roles.collect{|r| r.name}.join(",")
  end
  def self.authenticate(username,pwd)
    u=self.find_by_username(username)
    if u
      expected_password = self.encrypted_password(pwd,u.password_salt)
      if u.password_hashed != expected_password
        u=nil          
      end
    end
    u
  end

  def password
    @password    
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.password_hashed = AdminUser.encrypted_password(self.password,self.password_salt)
  end

  def self.current=(user)
    Thread.current[:user] = user
  end
  
  def self.current
    Thread.current[:user]
  end
  def self.current_id
    self.current && self.current.id
  end
  def self.current_name
    (self.current && self.current.name)||""
  end
  #当前员工
  def self.current_employer
    self.current && self.current.employer
  end
  def self.current_employer_id
    self.current && self.current.employer_id
  end
  #当前分支机构
  def self.current_branch
    self.current_employer && self.current_employer.branch
  end
  def self.current_branch_id
    self.current_employer && self.current_employer.branch_id
  end
  #当前品牌
  def self.current_brand
    self.current_store && self.current_store.brand
  end
  def self.current_brand_id
    self.current_brand && self.current_brand.id
  end
  def self.current_brand_name
    self.current_brand && self.current_brand.name
  end
  #当前部门
  def self.current_department
    self.current_employer && self.current_employer.department
  end
  
  def to_s
    username    
  end

  def self.to_extjs_combo_store
    result = {:xtype=>'arraystore',:fields=>['id','display_text'],:data=>self.to_extjs_combo_data}
  end
  def self.to_extjs_combo_data
    self.all(:order=>'id').collect{|i| [i.id,i.display_text]}
  end
  def display_text
    "#{name}"
  end
  
  def portal_items
    ret = []
    portlet_columns.each_with_index do |col,i|
      ret << {:columnWidth=>1.0/portlet_columns.length,
       :style=>'padding:10px 0 10px 10px',
       :items=>col,
       :id=>"portal_col_#{i}"
      }
    end
    return ret
  end
  def portlet_columns
#    [[portlet_xitonggonggao],[portlet_crm_richeng],[]]
    [[portlet_xitonggonggao],[portlet_renwuzhongxin],[]]
  end
  
  #session认证
  def self.session_auth(user_id)
    return nil if user_id.blank?
    user = self.find(user_id)
    return nil if user.blank?
    raise "用户被停用" unless user.is_active?
    
    return user
  end


  # 给编辑表单提供数据
  def edit_form_data
    {:id=>self.id,:username=>self.username,:name=>self.name,:role_id=>self.role_id,:employer_id=>self.employer_id}
  end
  
  private
  def self.encrypted_password(password,salt)
    password = "" unless password
    salt = "" unless salt
    string_to_hash = password + "gaoliu" +salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  def create_new_salt
    self.password_salt = self.object_id.to_s + rand.to_s    
  end
  
  #系统公告
  def portlet_xitonggonggao
    {
      :id=>"portal_portlet_xitonggonggao",
        :title => '系统公告',
        :layout => 'fit',
        :tools => [{
            :xtype => 'tool',
            :type => 'close',
            :handler => "function(e, target, panel){panel.ownerCt.remove(panel, true);}".uq
        }],
        :html=>AdminXitonggonggao.to_html
    }
  end
  #任务中心
  def portlet_renwuzhongxin
    url = "/admin/admin_task/my_task"
    {
      :id=>"portal_portlet_renwuzhongxin",
        :title => '任务中心',
        :id=>'task_center_portlet',
        :listeners => {
            'close' => "Ext.bind(this.onPortletClose, this)".uq
        },
        :layout => 'fit',
        :tools => [{ 
            :xtype => 'tool',
            :type => 'close',
            :handler => "function(e, target, panel){panel.ownerCt.remove(panel, true);}".uq
        },{
            :xtype => 'tool',
            :type => 'refresh',
          :qtip=>'刷新',
          :handler => " function(e, target, panel){
            panel.getUpdater().update({url:'#{url}'});
          }".uq
        }],
        :autoLoad => url
    }
  end
  #销售意向单日程
  def portlet_crm_richeng
    {
      :xtype=>'grid',
      :draggable =>true,
      :collapsible=>true,
      :title => '日程',
      :layout => 'fit',
      :tools => [{ :id => 'close',
          :handler => "function(e, target, panel){panel.ownerCt.remove(panel, true);}".uq
      }],
      :store=>{
          :xtype=>'jsonstore',
          :root=>'rows',
          :totalProperty=>'totalCount',
          :idProperty=>'id',
          :remoteSort=>true,
          :autoLoad=>true,
          :fields=>[
              {:name=>'id'},
              {:name=>'xiaoshoujihui_id'},
              {:name=>'jihui_code'},
              {:name=>'jihua_date'},
              {:name=>'richeng_state'},
              {:name=>'code'},
              {:name=>'objective'},
              {:name=>'client_name'},
              {:name=>'contact_name'},
              {:name=>'xiaoshouyuan_id'},
              {:name=>'xiaoshouyuan_name'},
              {:name=>'remark'}
          ],
          :url=>'/crm_richeng/extjs_listdata',
          :sortInfo=>{:field=>'jihua_date',:direction=>'DESC'}
      },
      :trackMouseOver=>false,
      :loadMask=>true,
      :stripeRows=>true,
      :columns=>[
          "new Ext.grid.RowNumberer()".uq,
          {:header=>'意向单号',:dataIndex=>"jihui_code",:sortable=> true},
          {:header=>'客户名称',:dataIndex=>"client_name",:sortable=> true},
          {:header=>'销售人员',:dataIndex=>"xiaoshouyuan_name",:sortable=> true},
          {:header=>'日程单号',:dataIndex=>"code",:sortable=> true},
          {:header=>'计划时间',:dataIndex=>"jihua_date",:sortable=> true},
          {:header=>'计划目的',:dataIndex=>"objective",:sortable=> true},
          {:header=>'日程状态',:dataIndex=>"richeng_state",:sortable => true}
      ],
      :sm=>"new Ext.grid.RowSelectionModel({singleSelect: true})".uq,
      :viewConfig=>{:forceFit=>true}
    }    
  end

  def time_zone
#    @time_zone ||= (self.pref.time_zone.blank? ? nil : ActiveSupport::TimeZone[self.pref.time_zone])
    "Beijing"
  end
  
end
