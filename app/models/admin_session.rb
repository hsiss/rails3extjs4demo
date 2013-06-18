#当前session
class AdminSession
  def AdminSession.current_user
    AdminUser.current
  end
  def AdminSession.current_user_id
    current_user && current_user.id 
  end
  def AdminSession.current_user_name
    current_user && current_user.name 
  end

  # 门店  
  def AdminSession.current_mendian
    current_user && current_user.mendian
  end
  def AdminSession.current_mendian_id
    current_mendian && current_mendian.id 
  end
  def AdminSession.current_mendian_name
    current_mendian && current_mendian.name 
  end
  
  #当前用户的新消息数
  def AdminSession.new_message_count
    AdminMsgInbox.new_message_count(current_user.id)
  end
  
  #当前用户所在分支机构
  def AdminSession.current_branch_id
    AdminUser.current_branch_id
  end
end