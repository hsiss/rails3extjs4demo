//==============================================================================
// 以post方式打开新窗口,主要用于打印和导出excel传递参数的时候
//==============================================================================
if(Ext.isChrome){
//chrome
  window.openPostWindow = function(url,name,data){
      window.open(url+'?'+Ext.urlEncode(data),name,'height=400, width=400, top=0, left=0, toolbar=yes, menubar=yes, scrollbars=yes, resizable=yes,location=yes, status=yes');   
  };
} else {
// FF && IE
window.openPostWindow=function(url,name,data){ 
    var tempForm = document.createElement("form"); 
    tempForm.id="tempForm1"; 
    tempForm.method="post"; 
    tempForm.action=url; 
    tempForm.target=name; 
    for(var p in data){ 
        var hideInput = document.createElement("input"); 
        hideInput.type="hidden"; 
        hideInput.name= p;
        hideInput.value= data[p];
        tempForm.appendChild(hideInput);  
    }
    var request_forgery_protection_token_hideInput = document.createElement("input"); 
    request_forgery_protection_token_hideInput.type="hidden"; 
    request_forgery_protection_token_hideInput.name= "authenticity_token";
    request_forgery_protection_token_hideInput.value= Ext.Ajax.extraParams.authenticity_token;
    tempForm.appendChild(request_forgery_protection_token_hideInput);  

    if(tempForm.attachEvent){
        tempForm.attachEvent("onsubmit",function(){openWindow(name);});
    } else {
        tempForm.addEventListener("submit",function(){openWindow(name);},false); 
    }
    document.body.appendChild(tempForm); 
    if (tempForm.fireEvent) {
        tempForm.fireEvent('onsubmit');
        tempForm.submit();
    } else if (document.createEvent) {
        var ev = document.createEvent('HTMLEvents');
        ev.initEvent('submit', false, true);
        tempForm.dispatchEvent(ev);
    }
    
    document.body.removeChild(tempForm);
    return false;
};

}

//==============================================================================
// 导出一个grid到excel
//==============================================================================
var export_to_excel = function(options){
  var grid = options.grid;
  var formpanel = options.formpanel;
  var url = options.url;
  return function(){
      params = (formpanel && formpanel.getForm().getValues()) || {};
      if(grid.store.sortInfo && grid.store.remoteSort){
          var pn = grid.store.paramNames;
          params[pn.sort] = grid.store.sortInfo.field;
          params[pn.dir] = grid.store.sortInfo.direction;
      }
      var cm = grid.columns;
      for (var i = 0; i < cm.length; i++) {
          if (cm[i]['dataIndex']){
              var fld = grid.store.model.prototype.fields.get(cm[i]['dataIndex']);
              var column_type = 'String';
              switch(fld.type) {
                  case "int":
                      column_type="int";
                      break;
                  case "float":
                      column_type="float";
                      break;
                  case "date":
                      column_type="date";
                      break;
              };
              //params['columns['+i+'][hidden]']= cm[i].isHidden();
              params['columns['+i+'][column_width]'] = cm[i].width;
              params['columns['+i+'][column_header]']= cm[i].text;
              //params['columns['+i+'][column_type]']  = column_type;
              params['columns['+i+'][data_index]']  = cm[i].dataIndex;
          }
      }
      openPostWindow(url,'_blank',params);
  }
};


//==============================================================================
// utc Date类转换器,支持和utc时间的转换,getTimezoneOffset()返回480=8*60
//==============================================================================
var utc_date_to_locale = function(value){
  if (Ext.isString(value)){
    value = new Date();
    value.setTime(Date.parse(value));
  }
  if (Ext.isDate(value)){
    return value.add(Date.MINUTE, -value.getTimezoneOffset());
  }
  return value;
}
