Ext.ns("App");

//警告信息,不自动关闭
App.warn = function(msg){
  Ext.Msg.alert('注意',msg);
};
//提示信息,可以自动关闭
App.info = function(msg){
  Ext.Msg.alert('系统提示',msg);
};

//避免在ie下调用console.log出错
if(!window.console){
  window.console = {
    log:function(message){
//      alert(message);
    }
  }
}

App.amountRenderer = function(v){
    if(v==0){
        return "";
    }
    return Ext.util.Format.number(v,"0,0.00")
};


var deving_handler = function(){
    Ext.Msg.alert('系统提示', '尚未实现');
};

////////////////////////////////////////////////////////////////////////////////
// ajax请求相关
////////////////////////////////////////////////////////////////////////////////

// 默认的ajax执行成功的回调函数
var default_ajax_request_success_callback=function(response, options) {
    var jsret =  Ext.decode(response.responseText);
    if (jsret.return_type && jsret.return_type==='js' && jsret.run){
        return jsret.run(); //var win = jsret.run();
    } else {
        if (jsret.message){
            Ext.Msg.alert('系统提示', jsret.message);
        }
        if (jsret.errormsg){
            Ext.Msg.alert('错误', jsret.errormsg);
        }
        return jsret;
    }
};

// 默认的ajax执行失败的回调函数
var default_ajax_request_failure_callback = function(response, options) {
    if (console){
        console.log(response);
    }
};


//执行远程的json
var execute_remote_extjson = function(url,params){
    Ext.Ajax.request({
        url: url,
        params:params||{},
        success: default_ajax_request_success_callback,
        failure: default_ajax_request_failure_callback
    });
};

// 创建远程窗口,不要用这种方法了
var create_remote_window = function(url,params){
  execute_remote_extjson(url,params)
};


////////////////////////////////////////////////////////////////////////////////
// form.submit相关
////////////////////////////////////////////////////////////////////////////////

// 默认的form.submit成功的回调函数
var default_form_submit_success_callback=function(form,action) {
    if (action.result && action.result.message){
        Ext.Msg.alert('系统提示', action.result.message);
    }
};
// 默认的form.submit失败的回调函数
var default_form_submit_failure_callback = function(form,action) {
    if (action.result && action.result.message){
        Ext.Msg.alert('错误', action.result.message);
    }
    if (action.result && action.result.errormsg){
        Ext.Msg.alert('错误', action.result.errormsg);
    }
    if (console){
        console.log([form,action]);
    }
};

//激活一个控件,主要是panel或者window
var active_container=function(cmp){
  if(!cmp) return;

  if(cmp.getXType()==="panel"){
    var main = Ext.getCmp('main');
    if(main){
      main.activate(cmp);
      cmp.getEl().frame("ff0000", 1, { duration: 0.5 });
    }
    return cmp;
  }
  if(cmp.getXType()==="window"){
    cmp.show();
    cmp.getEl().frame("ff0000", 1, { duration: 0.5 });
    return cmp;
  }
};
