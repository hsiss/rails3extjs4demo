class NotAuthorizedError < StandardError
  attr :function  
  def initialize(function)  
    @function = function  
  end  
  def function_name
    @function && @function.name
  end
end