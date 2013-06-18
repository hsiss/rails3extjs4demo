class CreateAdminTables < ActiveRecord::Migration
  def up
    create_table "admin_branchs" do |t|
      t.string   "code",       :limit => 20
      t.string   "name",       :limit => 50
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_configs" do |t|
      t.string   "code",       :limit => 50
      t.string   "name",       :limit => 50
      t.string   "value",      :limit => 200
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_departments" do |t|
      t.string   "code",       :limit => 20
      t.string   "name",       :limit => 50
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_employers" do |t|
      t.string   "code",          :limit => 20
      t.string   "name",          :limit => 50
      t.integer  "branch_id"
      t.integer  "department_id"
      t.string   "email",         :limit => 50
      t.string   "mobilephone",   :limit => 20
      t.string   "remark",        :limit => 200
      t.boolean  "is_active"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "mendian_id",                   :comment => "门店Id"
      t.string   "mendian_name",  :limit => 50,  :comment => "门店Name"
    end
  
    create_table "admin_functions" do |t|
      t.string  "name",             :limit => 20
      t.string  "url",              :limit => 200
      t.integer "parent_id"
      t.integer "lft",              :limit => 8
      t.integer "rgt",              :limit => 8
      t.string  "handler",          :limit => 200
      t.string  "handler_url",      :limit => 200
      t.string  "handler_method",   :limit => 200
      t.string  "code",             :limit => 100
      t.string  "the_type",         :limit => 10
      t.boolean "need_auth"
      t.boolean "is_menu"
      t.boolean "is_function_menu"
      t.boolean "is_active"
      t.string  "icon_cls",         :limit => 50
    end
  
    create_table "admin_mendians", :comment => "门店" do |t|
      t.string   "code",       :limit => 20, :comment => "编码"
      t.string   "name",       :limit => 50, :comment => "名称"
      t.boolean  "is_active",                :comment => "是否可用"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_menus" do |t|
      t.string  "menu_text",      :limit => 20
      t.string  "handler",        :limit => 200
      t.string  "handler_url",    :limit => 200
      t.string  "handler_method", :limit => 200
      t.integer "parent_id"
      t.integer "lft",            :limit => 8
      t.integer "rgt",            :limit => 8
    end
  
    create_table "admin_msg_drafts" do |t|
      t.integer  "owner_id"
      t.integer  "sender_id"
      t.string   "sender_name",   :limit => 50
      t.string   "subject",       :limit => 100
      t.string   "body",          :limit => 2000
      t.string   "receiver",      :limit => 200
      t.string   "receiver_text", :limit => 500
      t.integer  "root_id"
      t.boolean  "auto_send"
      t.datetime "auto_send_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_msg_inboxs" do |t|
      t.integer  "owner_id"
      t.integer  "sender_id"
      t.string   "sender_name",   :limit => 50
      t.string   "subject",       :limit => 100
      t.string   "body",          :limit => 2000
      t.string   "receiver",      :limit => 200
      t.string   "receiver_text", :limit => 500
      t.integer  "root_id"
      t.datetime "send_at"
      t.boolean  "readed"
      t.datetime "read_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_msg_sents" do |t|
      t.integer  "owner_id"
      t.integer  "sender_id"
      t.string   "sender_name",   :limit => 50
      t.string   "subject",       :limit => 100
      t.string   "body",          :limit => 2000
      t.string   "receiver",      :limit => 200
      t.string   "receiver_text", :limit => 500
      t.integer  "root_id"
      t.datetime "send_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "admin_role_auths" do |t|
      t.integer "role_id"
      t.integer "function_id"
      t.boolean "checked"
      t.string  "function_code", :limit => 50
    end
  
    create_table "admin_roles" do |t|
      t.string "code", :limit => 20
      t.string "name", :limit => 20
    end
  
    create_table "admin_user_auths" do |t|
      t.integer "user_id"
      t.integer "function_id"
      t.boolean "checked"
      t.string  "function_code", :limit => 50
    end
  
    create_table "admin_user_extjs_states" do |t|
      t.integer "user_id"
      t.string  "name",    :limit => 200
      t.string  "value",   :limit => 8000
    end
  
    create_table "admin_user_roles" do |t|
      t.integer "user_id"
      t.integer "role_id"
    end
  
    create_table "admin_users" do |t|
      t.string   "username",                    :limit => 50
      t.string   "password_salt",               :limit => 50
      t.string   "password_hashed",             :limit => 50
      t.boolean  "is_active"
      t.integer  "employer_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",                        :limit => 50
      t.boolean  "need_change_password"
      t.string   "recent_change_password_date", :limit => 10
      t.string   "next_change_password_date",   :limit => 10
      t.boolean  "allow_multi_login"
      t.string   "last_login_session_id",       :limit => 500
      t.datetime "last_login_time"
      t.datetime "last_access_time"
      t.boolean  "allow_everywhere_login"
      t.string   "last_login_ip",               :limit => 20
      t.string   "last_access_ip",              :limit => 20
      t.integer  "mendian_id",                                 :comment => "门店Id"
      t.string   "mendian_name",                :limit => 30,  :comment => "门店Name"
    end
  
    create_table "admin_xitonggonggaos" do |t|
      t.string   "title",      :limit => 100
      t.string   "content",    :limit => 500
      t.integer  "youxianji",  :limit => 3
      t.string   "end_date",   :limit => 500
      t.boolean  "is_active"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "comments" do |t|
      t.integer  "commentable_id",   :default => 0
      t.string   "commentable_type", :default => ""
      t.string   "title",            :default => ""
      t.text     "body"
      t.string   "subject",          :default => ""
      t.integer  "user_id",          :default => 0,  :null => false
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
    end
  
    add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
    add_index "comments", ["user_id"], :name => "index_comments_on_user_id"
  
    create_table "web_article_images", :comment => "文章的图片" do |t|
      t.integer  "article_id",                                       :comment => "所属的文章"
      t.string   "image",             :limit => 500,                 :comment => "图片id，文件路径"
      t.integer  "updated_user_id",                                  :comment => "用户"
      t.string   "updated_user_name", :limit => 20,                  :comment => "用户"
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
    end
  
    create_table "web_articles", :comment => "网站文章管理" do |t|
      t.string   "title",            :limit => 200
      t.string   "content",          :limit=>0xffffff, :comment=>"文章的长度很容易超出最大值，用mediumtext类型，最大2G，text最大64k"
      t.integer  "create_user_id"
      t.string   "create_user_name", :limit => 30
      t.boolean  "is_active",                         :default => false
      t.datetime "created_at",                                           :null => false
      t.datetime "updated_at",                                           :null => false
    end


  end

  def down
  end
end
