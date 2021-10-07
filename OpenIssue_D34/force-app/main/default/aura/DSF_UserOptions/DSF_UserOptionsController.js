({
    checkParam : function(component, event, helper) {
        let currLink = window.location.href;

        if (currLink.includes('language=')) {
            component.set("v.languageParam", currLink.includes('en-US') ? '?language=en-US' : '?language=es');
        }
    }
})