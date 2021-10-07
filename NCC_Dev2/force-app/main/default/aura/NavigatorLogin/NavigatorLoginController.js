({
  init : function(component, event, helper) {
    var url = $A.get('$Resource.NavigatorLoginLogo');
    component.set('v.backgroundImageURL', url);
  },

  sendToken : function(component, event, helper) {
    helper.doSendToken(component, event, helper);	
  },
  
  submit : function(component, event, helper) {
    helper.doSubmit(component, event, helper);	
  },

  keyPress : function(component, event, helper){
      
  }
    
})