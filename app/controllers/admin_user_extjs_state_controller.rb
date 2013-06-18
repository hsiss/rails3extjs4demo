class AdminUserExtjsStateController < ApplicationController
  #读state
  def read_state
    #      @app_user = AdminUser.new(params[:app_user])
    #      @app_user.is_active=true
    result = Hash.new
    if AdminUser.current
      result[:success] = true
      result[:data] = AdminUser.current.extjs_states.collect{|s| {:name=>s.name,:value=>s.value}}
    else
      result[:success]=false
    end
    render :text => result.to_json(),:layout=>false
  end
  
  #写state
  def submit_state
    result = Hash.new
    if AdminUser.current
      data = ActiveSupport::JSON.decode(params[:data])
      data.each do |s|
        aues = AdminUserExtjsState.first(:conditions=>"user_id=#{AdminUser.current.id} and name='#{s['name']}'")
        if aues
          aues.value=s['value']
          aues.save
        else
          AdminUserExtjsState.create(:user_id=>AdminUser.current.id,:name=>s['name'],:value=>s['value'])
        end
      end
      result[:success] = true
    else
      result[:success]=false
    end
    render :text => result.to_json(),:layout=>false
  end
end