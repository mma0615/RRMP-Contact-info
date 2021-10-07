({
    doInit : function(cmp, event, helper){
        helper.getCurrentUser(cmp, event, helper);
        helper.initializeDraftEmail(cmp, event, helper);
    },

    handleCloseModal : function(cmp, event, helper){
        helper.closeModal();       
    },

    handlePrevious : function(cmp, event, helper){
        let currentIndex = cmp.get('v.currentPageIndex');
        cmp.set('v.currentPageIndex', currentIndex > 1 ? --currentIndex : currentIndex);
    },

    handleNext : function(cmp, event, helper){
        helper.validateInputs(cmp, event, helper);
    },

    handleSend : function(cmp, event, helper){
        helper.setupEmailBody(cmp, event, helper);
        helper.sendCompassEmail(cmp, event, helper);
    },

    handleSaveDraft : function(cmp, event, helper){
        helper.setupEmailBody(cmp, event, helper);
        helper.saveDraft(cmp, event, helper);
    }


})