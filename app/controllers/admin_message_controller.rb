class AdminMessageController < ApplicationController
  #消息中心
  def my_message
    
  end
  
  #新消息
  def new_message
    @admin_msg_draft = AdminMsgDraft.new
    render :layout=>false
  end
  
  def get_new_message_count
    result = Hash.new
    result[:success]=true
    result[:new_message_count]=AdminMsgInbox.new_message_count(AdminUser.current.id)
    render :text => result.to_json(),:layout=>false
  end
  
  # 收件箱数据
  def msg_inbox_data
    params[:limit] = params[:limit] || 50
    params[:start] = params[:start] || 0
      
    find_option ={}
    find_option[:limit] =  params[:limit]
    find_option[:offset] = params[:start]
    if params[:sort]
      find_option[:order] = params[:sort]
      find_option[:order] +=' '+ (params[:dir] || 'ASC')
    end
    find_option[:conditions] = "owner_id=#{AdminUser.current.id}"
    find_option[:select]="a.*
      "
    find_option[:joins]="as a
      "

    result = Hash.new
    result[:totalCount] =  AdminMsgInbox.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminMsgInbox.find(:all, find_option ).collect{|i| i.attributes}
    render :text => result.to_json(),:layout=>false
  end
  
  # 收件人数据
  def receiver_data
    find_option ={}
    
    rows = []
    rows << {:name=>"all",:type=>"所有人",:value=>"all:所有人"}
#    CarStore.all(:conditions=>"is_mendian=1").each do |i|
#      rows << {:name=>i.name,:type=>"门店",:value=>"#{i.name}:门店"}
#    end
#    CommDepartment.all(find_option).each do |i|
#      rows << {:name=>i.name,:type=>"部门",:value=>"#{i.name}:部门"}
#    end
    AdminUser.all(find_option).each do |i|
      rows << {:name=>i.name,:type=>"用户",:value=>"#{i.name}:用户"}
    end
    
    result = Hash.new
    result[:totalCount] =  rows.size
    result[:rows] = rows
    render :text => result.to_json(),:layout=>false
  end
  
  #{"receiver":"","receivers":["付强:用户","管理部:部门"],"subject":"aa","body":"aa"}
  #发送消息
  def send_message
    if params[:id].blank?
      msg = AdminMsgDraft.new
      msg.owner = AdminUser.current
      msg.sender = AdminUser.current
      msg.subject = params[:subject]
      msg.body =   params[:body]
      if params[:receivers].respond_to?(:join)
        msg.receiver_text = params[:receivers].join(",")
      else
        msg.receiver_text = params[:receivers].to_s
      end
      msg.sent_message
    else
      msg = AdminMsgDraft.find(params[:id])
      msg.owner = AdminUser.current
      msg.sender = AdminUser.current
      msg.subject = params[:subject]
      msg.body =   params[:body]
      if params[:receivers].respond_to?(:join)
        msg.receiver_text = params[:receivers].join(",")
      else
        msg.receiver_text = params[:receivers].to_s
      end
      msg.sent_message
      msg.destroy
    end
    
    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
  
  #删除收件箱中的消息
  def msg_inbox_delete
    ids = params[:ids]
    ids.each do |i|
      msg = AdminMsgInbox.find(i)
      msg.destroy if msg
    end
    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
  #标记为已读
  def mark_as_readed
    ids = params[:ids]
    ids.each do |i|
      msg = AdminMsgInbox.find(i)
      unless msg.readed?
        msg.mark_as_readed
      end
    end
    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
  #查看消息
  def msg_inbox_view
    @admin_msg_inbox = AdminMsgInbox.find(params[:id])
    @admin_msg_inbox.mark_as_readed
    render :layout=>false
  end
  #答复消息
  def msg_inbox_reply
    @admin_msg_inbox = AdminMsgInbox.find(params[:id])
    @admin_msg_draft = @admin_msg_inbox.reply   
    render :action=>:new_message,:layout=>false
  end
  #答复所有人
  def msg_inbox_reply_all
    @admin_msg_inbox = AdminMsgInbox.find(params[:id])
    @admin_msg_draft = @admin_msg_inbox.reply_all   
    render :action=>:new_message,:layout=>false
  end
  #转发
  def msg_inbox_forward
    @admin_msg_inbox = AdminMsgInbox.find(params[:id])
    @admin_msg_draft = @admin_msg_inbox.forward
    render :action=>:new_message,:layout=>false
  end
  
  
  ####################################################################
  def msg_sent_data
    params[:limit] = params[:limit] || 50
    params[:start] = params[:start] || 0
      
    find_option ={}
    find_option[:limit] =  params[:limit]
    find_option[:offset] = params[:start]
    if params[:sort]
      find_option[:order] = params[:sort]
      find_option[:order] +=' '+ (params[:dir] || 'ASC')
    end
    find_option[:conditions] = "owner_id=#{AdminUser.current.id}"
    find_option[:select]="a.*
      "
    find_option[:joins]="as a
      "

    result = Hash.new
    result[:totalCount] =  AdminMsgSent.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminMsgSent.find(:all, find_option ).collect{|i| i.attributes}
    render :text => result.to_json(),:layout=>false
  end
  #删除发件箱中的消息
  def msg_sent_delete
    ids = params[:ids]
    ids.each do |i|
      msg = AdminMsgSent.find(i)
      msg.destroy if msg
    end
    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
  #查看消息
  def msg_sent_view
    @admin_msg_sent = AdminMsgSent.find(params[:id])
    render :layout=>false
  end
  #草稿信息数据列表
  def msg_draft_data
    params[:limit] = params[:limit] || 50
    params[:start] = params[:start] || 0
      
    find_option ={}
    find_option[:limit] =  params[:limit]
    find_option[:offset] = params[:start]
#    if params[:sort]
#      find_option[:order] = params[:sort]
#      find_option[:order] +=' '+ (params[:dir] || 'ASC')
#    end
    find_option[:conditions] = "owner_id=#{AdminUser.current.id}"
    find_option[:select]="a.*
      "
    find_option[:joins]="as a
      "
    result = Hash.new
    result[:totalCount] =  AdminMsgDraft.count({:conditions=>find_option[:conditions],:joins=>find_option[:joins]})
    result[:rows] = AdminMsgDraft.find(:all, find_option ).collect{|i| i.attributes}
    render :text => result.to_json(),:layout=>false
  end
  #新增草稿
  def new_msg_draft
    @admin_msg_draft = AdminMsgDraft.new
    render :action=>:edit_draft,:layout=>false
  end
  #保存草稿
  def save_draft_message
    if params[:id].blank?
      msg = AdminMsgDraft.new
      msg.owner = AdminUser.current
      msg.subject = params[:subject]
      msg.body =   params[:body]
      msg.save
    else
      msg = AdminMsgDraft.find(params[:id])
      msg.subject = params[:subject]
      msg.body =   params[:body]
      msg.save
    end
    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
#  查看草稿
  def msg_draft_edit
    @admin_msg_draft = AdminMsgDraft.find(params[:id])
    render :action=>:edit_draft,:layout=>false
  end
#  删除草稿
  def msg_draft_delete
    ids = params[:ids]
    ids.each do |i|
      msg = AdminMsgDraft.find(i)
      msg.destroy if msg
    end
    result = Hash.new
    result[:success]=true
    render :text => result.to_json(),:layout=>false
  end
#  发送草稿
  def msg_sent_draft
    @admin_msg_draft = AdminMsgDraft.find(params[:id])
    render :action=>:new_message,:layout=>false
  end
  
end
