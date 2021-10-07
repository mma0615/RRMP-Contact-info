({
    checkLanguage : function(component, event, helper) {
        if (window.location.href.includes('language=es')) {
            component.set("v.language", "English");
            component.set("v.languageShort", "EN");
        }
    },
    
    changeLanguage : function(component, event, handler) {
        let param = '?language=en-US';
        let link = window.location.href;

        component.get("v.language") == 'English' ? (component.set("v.language", "Español"), component.set("v.languageShort", "ES")) : (param = '?language=es', component.set("v.language", "English"), component.set("v.languageShort", "EN"));
        link.includes('language=') ? (link.includes('en-US') ? link = link.replace('=en-US', '=es') : link = link.replace('=es', '=en-US')) : link += param;
        
        window.location.href = link;
    }
})