class IndexController < ApplicationController
  skip_before_filter :authorize,:admin_session_setup,:only=>[:login,:login_submit,:logout]
      
  def index
  end
  def login
  end
  
  def change_password
  end
  
  def change_password_submit
    result = Hash.new
    if(params[:newpassword]!=params[:newpassword_confirm])
      result[:success]=false
      result[:errormsg]="两次输入的新密码不一致"
      render :text => result.to_json(),:layout=>false
      return
    end
    
    u=AdminUser.authenticate(AdminUser.current.username,params[:oldpassword])
    unless u
      result[:success]=false
      result[:errormsg]="旧密码不对"    
      render :text => result.to_json(),:layout=>false
      return
    end

    AdminUser.current.password = params[:newpassword]
    AdminUser.current.need_change_password = false
    AdminUser.current.recent_change_password_date = Date.today.strftime('%Y-%m-%d')
    AdminUser.current.save
    result[:success]=true
    result[:message]="密码修改成功,下次请用新密码登录"    
    render :text => result.to_json(),:layout=>false
  end
  
  def login_submit
    result = Hash.new
    u=AdminUser.authenticate(params[:username],params[:password])
    raise "请输入有效的用户名和密码!" unless u
    raise "该用户已被禁用!" unless u.is_active?
    u.last_login_session_id = request.session_options[:id]
    u.last_login_time = Time.now
    u.last_access_time = Time.now
    u.last_login_ip = request.remote_ip
    u.save
    session[:user_id] = u.id
    result[:success]=true
    render :text => result.to_json
  end
  
  def logout
    AdminUser.current = nil
    session[:user_id] = nil
    redirect_to '/index/login'
  end

  def sys_lock
  end

  def sys_lock_submit
    result = Hash.new
    u=AdminUser.authenticate(params[:username],params[:password])
    if u
      session[:user_id] = u.id
      result[:success]=true
    else
      result[:success]=false
      result[:errormsg]="请输入有效的和密码"
    end
    render :text => result.to_json(),:layout=>false
  end
  
end
