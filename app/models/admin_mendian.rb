class AdminMendian < ActiveRecord::Base
  
  validates_presence_of :code
  validates_presence_of :name 
  validates_uniqueness_of :code
  validates_uniqueness_of :name
  
  
  #列出数据
  def self.list_data(params)
    find_option ={}
    find_option[:limit] =  params[:limit] unless params[:limit].blank?
    find_option[:offset] = params[:offset] unless params[:offset].blank?
    unless params[:sort].blank?
      find_option[:order]=params[:sort].collect{|s| "#{s[:property]} #{s[:direction] || 'ASC'}"}.join(",")
    end
    find_option[:select]="*"
    find_option[:conditions]='1=1'
    unless params[:code].blank?
      find_option[:conditions] << " and code like '%#{params[:code]}%'"
    end
    unless params[:name].blank?
      find_option[:conditions] << " and name like '%#{params[:name]}%'"
    end
    result = Hash.new
    result[:totalCount] =  self.count({:conditions=>find_option[:conditions]})
    result[:rows] = self.all(find_option ).collect{|i| i.attributes}
    return result
  end
  
  def AdminMendian.to_extjs_combo_data
    self.all(:order=>'code').collect{|i| [i.id,i.display_text]}
  end
  def display_text
    "#{name}"
  end
  # 给编辑表单提供数据
  def edit_form_data
    self.attributes
  end
end
