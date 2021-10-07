({
    initializeRecipients : function(cmp, event, helper){
        let ccPillItems = [];
        let bccPillItems = [];
        const ccRecipients = cmp.get('v.ccRecipients');
        const bccRecipients = cmp.get('v.bccRecipients');
        // console.log('ccRecipients', ccRecipients);
        // console.log('bccRecipients', bccRecipients);
        for(const email of ccRecipients){
            ccPillItems.push({ label: email, name: email });
        }
        for(const email of bccRecipients){
            bccPillItems.push({ label: email, name: email });
        }
        cmp.set('v.ccPillItems', ccPillItems);
        cmp.set('v.bccPillItems', bccPillItems);
        cmp.set('v.isLoading', false);
    },

    removePillItem: function(cmp, event, attributeName){
        const name = event.getParam("item").name;
        // Remove the pill from view
        let pillItems = cmp.get(attributeName);
        const item = event.getParam("index");
        pillItems.splice(item, 1);
        cmp.set(attributeName, pillItems);

    },

    removeRecipient: function(cmp, event, attributeName){
        // Remove the email from recipient/s list
        let recipients = cmp.get(attributeName);
        const name = event.getParam("item").name;
        const index = recipients.indexOf(name);
        if (index > -1) {
            recipients.splice(index, 1);
        }
        cmp.set(attributeName, recipients);
        console.log('Remaining Emails >> ', cmp.get(attributeName));
    }
})