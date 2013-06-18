class NotAuthorizedDataError < StandardError
  attr :message  
  def initialize(message)  
    @message = message  
  end  
end