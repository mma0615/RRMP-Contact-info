({
    doInit : function(cmp, event, helper){
        //nothing to initialize
    },

    handleCloseModal : function(cmp, event, helper){
        helper.closeModal();       
    },

    handlePrevious : function(cmp, event, helper){
        let currentIndex = cmp.get('v.currentPageIndex');
        cmp.set('v.currentPageIndex', currentIndex > 1 ? --currentIndex : currentIndex);
    },

    handleNext : function(cmp, event, helper){
        let currentIndex = cmp.get('v.currentPageIndex');
        let lastPageIndex = cmp.get('v.lastPageIndex');
        const orgWideEmailAddressRecord = cmp.get('v.orgWideEmailAddressRecord');
        const contactIdList = cmp.get('v.contactIdList');
        const subject = cmp.get('v.subject');
        const emailBody = cmp.get('v.emailBody');

        if(currentIndex === 1){
            if(!orgWideEmailAddressRecord){
                helper.showToastWarning('Sender is Required!');
            }
            else if(!subject){
                helper.showToastWarning('Subject is Required!');
            }
            else if(!emailBody){
                helper.showToastWarning('Email Body/Message is Required!');
            }
            else{
                cmp.set('v.currentPageIndex', currentIndex <= lastPageIndex-1 ? ++currentIndex : currentIndex);
            }
        }
        else if(currentIndex === 2){
            if(!contactIdList.length){
                helper.showToastWarning('Contact Recipient is required!');
            }
            else{
                cmp.set('v.currentPageIndex', currentIndex <= lastPageIndex-1 ? ++currentIndex : currentIndex);
            }
        }

    },

    handleSend : function(cmp, event, helper){
        helper.sendEmail(cmp, event, helper);
    },


})