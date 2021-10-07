({
    initNavigatorAttributes : function(component, event, helper){
        const contact =  event.getParam('contact');
        const navRecord = event.getParam('navigatorRecord');
        component.set('v.navigatorRecord', navRecord);
        component.set('v.greeting', navRecord.Header_Text__c.replace('{name}', '<b>' + contact.Name + '</b>'));
    },


    // scroll: function(component, event, helper){
    //     const scrollToTopButton = component.find('scrollTopButton');
    //     scrollToTopButton.style.display = event.target.scrollTop > 20 ? 'block' : 'none';
    // },
})