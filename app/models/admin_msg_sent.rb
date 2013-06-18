class AdminMsgSent < ActiveRecord::Base
  belongs_to :owner,:foreign_key=>'owner_id',:class_name=>'AdminUser'
  belongs_to :sender,:foreign_key=>'sender_id',:class_name=>'AdminUser'
  def before_save
    self.sender_name = self.sender && self.sender.name
    self.send_at = Time.now
  end
  def self.user_ids_of_store(store_name)
    sql = "
      select u.id from admin_users u
      join comm_employers e on u.employer_id = e.id
      join car_stores s on s.id=e.store_id
      where s.name='#{store_name}'
    "
    AdminUser.connection.select_values(sql)
  end  
  def self.user_ids_of_department(department_name)
    sql = "
      select u.id from admin_users u
      join comm_employers e on u.employer_id = e.id
      join comm_departments d on d.id=e.department_id
      where d.name='#{department_name}'
    "
    AdminUser.connection.select_values(sql)
  end  
  def self.sent_message(draft)
    msg_sent = AdminMsgSent.new
    msg_sent.owner = draft.owner
    msg_sent.sender = draft.sender
    msg_sent.subject = draft.subject
    msg_sent.body =   draft.body
    msg_sent.receiver_text = draft.receiver_text
    msg_sent.save
    
    receivers=[]
    unless msg_sent.receiver_text.blank?
      msg_sent.receiver_text.split(',').each do |i|
        name,obj_name = i.split(':')
        if obj_name == "所有人"
          AdminUser.all.each{|u| receivers << u.id}
          break
#        elsif obj_name == "门店"
#          receivers = receivers + self.user_ids_of_store(name)
#        elsif obj_name == "部门"
#          receivers = receivers + self.user_ids_of_department(name)
        elsif obj_name == "用户"
          u = AdminUser.find_by_name(name)
          receivers << u.id if u
        end
      end
    end
    receivers.uniq!
    msg_sent.receiver = receivers.join(",")
    current_user_id = AdminUser.current.id
    receivers.each do |r|
      msg = AdminMsgInbox.new
      msg.owner_id      = r
      msg.sender_id     = msg_sent.sender_id
      msg.sender_name   = msg.sender && msg.sender.name
      msg.subject       = msg_sent.subject
      msg.body          = msg_sent.body
      msg.receiver      = msg_sent.receiver
      msg.receiver_text = msg_sent.receiver_text
      msg.root_id       = nil
      msg.send_at       = Time.now
      msg.readed        = false
      msg.save
    end
    unless draft.new_record?
      draft.destroy
    end
  end
  
  def to_data
    result={}
    result[:id]=self.id
    result[:admin_msg_sent] = self.attributes
    return result
  end
end
