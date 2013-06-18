class AdminConfig < ActiveRecord::Base
  
  def self.get_value(code)
    c = AdminConfig.find_by_code(code)
    c && c.value
  end
  def self.set_value(code,value)
    c = AdminConfig.find_by_code(code)
    unless c
      c = AdminConfig.new
      c.code = code
    end
    c.value=value
    c.save
  end
  
  ##################################################################################################
  #以下是具体的一些参数

  #默认每页显示数据行数
  def AdminConfig.per_page
    value = get_value('per_page')
    (value && value.to_i) || 50 
  end
  def AdminConfig.per_page=(value)
    set_value('per_page',value)
  end
  
  #pdf打印的时候是否采用inline
  def AdminConfig.pdf_inline?
    return false
  end
  def AdminConfig.pdf_disposition
    if AdminConfig.pdf_inline?
      return 'inline'
    else
      return 'attachment'
    end
  end
  
  
  
  def self.company_name
    get_value('company_name')
  end
  def self.company_name=(value)
    set_value('company_name',value)
  end
  def self.email_sender
    get_value('email_sender') || 'bao.biao@hrbyd.com'
  end
  def self.email_test_recipient
    get_value('email_test_recipient') || 'bao.biao@hrbyd.com'
  end
end
