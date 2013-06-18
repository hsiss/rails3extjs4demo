class ApplicationController < ActionController::Base
#  protect_from_forgery
  
  layout false

  rescue_from NotAuthorizedFunctionError do |e|
    msg = "您没有#{e.function_name}的权限"
    if params[:format] && params[:format] == 'extjs'
      render :text=>ext_error_alert(msg)
    elsif params[:extjs]
      result = Hash.new
      result[:success] = false
      result[:errormsg] = msg
      render :text => result.to_json
    end
    return
  end
  
  rescue_from RuntimeError do |e|
    msg = e.message
    if params[:format] && params[:format] == 'extjs'
      render :text=>ext_error_alert(msg)
    elsif params[:extjs]
      result = Hash.new
      result[:success] = false
      result[:errormsg] = msg
      render :text => result.to_json
    end
    return
  end

  before_filter :admin_session_setup, :authorize, :config_params

  #extjs方式返回错误提示框
  def ext_error_alert(msg)
    return "Ext.Msg.alert('错误', '#{msg}');"
  end

  protected
  #检查访问控制
  def check_acl(function_code)
    allow = AdminUser.current.allow_access?(function_code)
    return true if allow

    f = AdminFunction.find_by_code(function_code)
    if f
      raise NotAuthorizedFunctionError.new(f)
    else
      logger.error "权限控制错误,功能号[#{function_code}]不存在,允许访问"
#      puts "权限控制错误,功能号[#{function_code}]不存在,允许访问"
      return false
    end
  end
  private
  def admin_session_setup
    # locale
#    session[:locale]= session[:locale] || I18n.default_locale
#    I18n.locale = session[:locale]
    
    #theme
#    session[:theme] = 'blue' if session[:theme].blank?
    
    #user  
    user=AdminUser.session_auth(session[:user_id])

    if user
      AdminUser.current = user 
    else
      AdminUser.current = nil 
    end
  end
  def authorize
    unless AdminUser.current
      if params[:format] && params[:format] == 'extjs'
        render :text=>"Ext.Msg.alert('错误', '由于您长时间处于闲置状态,请刷新页面重新登录');"
      elsif params[:extjs]
        result = Hash.new
        result[:success] = false
        result[:errormsg] = "由于您长时间处于闲置状态,请刷新页面重新登录"
        render :text => result.to_json()
      else
        flash[:notice]="请登录"
        redirect_to "/index/login"
      end
      return
    end

    user = AdminUser.current
    if !user.allow_multi_login? && !user.last_login_session_id.blank? && user.last_login_session_id!=request.session_options[:id]
      session[:user_id] = nil
      raise "您的账号在其他地方登录,最后访问系统的时间是#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}<BR/>系统已强制退出,请按F5重新登录<BR/>建议您尽快更换密码"
    end
#有多条外网线路的时候会误报    
#    if !user.allow_multi_login? && !user.last_login_ip.blank? && user.last_login_ip!= request.remote_ip
#      session[:user_id] = nil
#      raise "您的账号信息异常,可能是因为更换了网络地点,请按F5重新登录"
#    end
     
    user.last_access_time = Time.now
    user.save
  end

  def config_params
    params[:sort] = ActiveSupport::JSON.decode(params[:sort]) if params[:sort].is_a?(String)
  end
end
