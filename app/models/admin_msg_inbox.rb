class AdminMsgInbox < ActiveRecord::Base
  set_table_name :admin_msg_inboxs
  belongs_to :owner,:foreign_key=>'owner_id',:class_name=>'AdminUser'
  belongs_to :sender,:foreign_key=>'sender_id',:class_name=>'AdminUser'
  
  def to_data
    result={}
    result[:id]=self.id
    result[:admin_msg_inbox] = self.attributes
    return result
  end
  
  #答复发件人
  def reply
    ret = AdminMsgDraft.new
    ret.subject = "答复:#{self.subject}"
    ret.body = "\n\n----- 原消息 -----\n#{self.body}"
    ret.receiver = self.sender && self.sender.id
    ret.receiver_text = "#{self.sender_name}:用户"
    ret.root_id = self.root_id
    return ret
  end
  
  #标记为已读
  def mark_as_readed
    self.readed = true
    self.read_at = Time.now
    self.save
  end
  
  #答复所有
  def reply_all
    ret = AdminMsgDraft.new
    ret.subject = "答复:#{self.subject}"
    ret.body = "\n\n----- 原消息 -----\n#{self.body}"
    ret.receiver_text = "#{self.sender_name}:用户,#{self.receiver_text}"
    ret.root_id = self.root_id
    return ret
  end
  def forward
    ret = AdminMsgDraft.new
    ret.subject = "fw:#{self.subject}"
    ret.body = "\n\n----- 原消息 -----\n#{self.body}"
    ret.receiver = self.sender && self.sender.id
    ret.receiver_text = "#{self.sender_name}:用户"
    ret.root_id = self.root_id
    return ret
  end
  
  
  def self.new_message_count(user_id)
    AdminMsgInbox.count({:conditions=>"owner_id=#{user_id} and coalesce(readed,0)=0 "})
  end
end
