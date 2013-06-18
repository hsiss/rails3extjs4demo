class AdminXitonggonggao < ActiveRecord::Base
  def self.to_extjs_combo_store
    result = {:xtype=>'arraystore',:fields=>['id','display_text'],:data=>self.to_extjs_combo_data}
  end
  def self.to_extjs_combo_data
    self.all(:order=>'youxianji desc').collect{|i| [i.id,i.display_text]}
  end
  def display_text
    "#{title}"
  end
  def self.to_html
    data = self.all(:order=>'youxianji desc,end_date asc',:conditions=>["is_active=1 and end_date>=?",Time.now.strftime('%Y-%m-%d')])
    ret=[]
    data.each do |d|
      ret<<"<h3>#{d.title}</h3><div>#{d.content.gsub(/\r\n/,'\n').gsub(/\n/,'<br/>')}</div>"
    end
    return ret.join("<hr/>")
  end
end
