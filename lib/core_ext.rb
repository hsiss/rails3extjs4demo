class UnquotedString < String
  def as_json(options = nil) self end #:nodoc:
  def encode_json(encoder) self end #:nodoc:
end
class String
  def uq # un quote string
    UnquotedString.new(self)
  end
  
  # 截取字符串
  def truncate_u(length=30, truncate_string = "...")
    ret = ''
    count = 0
    self.scan(/./u).each do |c|
      if count >= length
        ret << truncate_string
        break 
      end
      
      ret << c
      count += (c.length == 1 ? 0.5 : 1)
    end

    return ret
  end
end

class ActiveRecord::Base
  def self.per_page
    AdminConfig.per_page
  end
  
  def edit_form_data
    self.attributes
  end
end

class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  def add_limit_offset!(sql, options)
    limit, offset = options[:limit], options[:offset]
    if limit && offset
      sql << " LIMIT #{offset.to_i}, #{sanitize_limit(limit)}"
    elsif limit
      sql << " LIMIT #{sanitize_limit(limit)}"
    elsif offset
      sql << " OFFSET #{offset.to_i}"
    end
    sql
  end
end