class AdminMsgDraft < ActiveRecord::Base
  belongs_to :owner,:foreign_key=>'owner_id',:class_name=>'AdminUser'
  belongs_to :sender,:foreign_key=>'sender_id',:class_name=>'AdminUser'
  
  def sent_message
    self.save
    AdminMsgSent.sent_message(self)
  end
  
  def to_data
    result={}
    result[:id]=self.id
    result[:admin_msg_draft] = self.attributes
    return result
  end
end
