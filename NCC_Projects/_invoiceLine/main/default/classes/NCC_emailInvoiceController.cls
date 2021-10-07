/**
 * NCC_emailInvoiceController
 * @author Minh Ma 
 * @date 02/28/2021
 * @description This is to email invoice PDF for Invoice Formatting = 'Project Role & Rate'
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
public with sharing class NCC_emailInvoiceController
 {
    public NCC_emailInvoiceController(ApexPages.StandardController controller) 
    {
        invoiceId = ApexPages.currentPage().getParameters().get('id');
        system.debug('invoiceId : ' + invoiceId);
        this.invoice = [select id, name from Krow__Invoice__c where id = :invoiceId];
    }

    public String invoiceId { get;set; }
    
    public Krow__Project__c Project { get;set; }

    public Krow__Invoice__c invoice { get; set; }
    
    public Document doc { get; set; }
    
    public string settingTemplateId { get;set; }
    public List<SelectOption> TemplateList { get;set; }    
    
    public string additionalToEmailAddress{ get;set; }
    public string selectedFromEmailId{ get;set; }
    public string userEmail { get;set; }
    public string ccEmailAddress{ get;set; }
    
    /***** Init when form load
     * 1 Delete old saved old invoice if exist
     * 2 Print Invoice as PDF, the save to document
     * 3 Get list of avail email tempates
     * 4 Get all avail info
    */
    public void init()
    {        
        String fileName = 'Invoice-' + invoice.Name + '.pdf';

        /***** Delete old saved old invoice if exist */
        List<Document> invDoclist = [select id, name from Document where name=:fileName];
        if (invDocList.size() > 0)
            delete (invDocList);
        system.debug('generatePDF ==> invDocList.size() : ' + invDocList.size());

        /***** Print Invoice as PDF, the save to document */ 
        Blob content;
        PageReference pr = Page.NCC_Print_InvoiceVF;
        pr.getParameters().put('id', invoice.id);
        if(Test.isRunningTest())
            content = Blob.valueOf('tempString');
        else
        	content = pr.getContentAsPDF();

        List<Folder> folderList = [SELECT Id, Name From Folder WHERE Name = 'Invoices'];
        system.debug('generatePDF ==> folderList.size() : ' + folderList.size());
        String docFolderId = folderList[0].Id; //Get Folder Id
        String fileContent = 'Invoice'; //File Content
        
        doc = new Document();
        doc.Name = fileName;
        doc.Body = content;
        doc.FolderId = docFolderId;
        doc.IsPublic = true;
        system.debug('generatePDF ==> Insert  Doc : ' + doc);
        Insert doc;
        
        /***** Get list of avail email tempates */
        TemplateList = new List<SelectOption>();
        for (EmailTemplate eTemplate : [SELECT Id,Name FROM EmailTemplate where IsActive = true order by Name])
        {
            TemplateList.Add(new SelectOption(eTemplate.id, eTemplate.Name));
        }
        
        /***** Get all avail info */
        Project = new Krow__Project__c();
        userEmail = userinfo.getUserEmail();
    
    }
    
    public PageReference sendEmail() 
    {
        try
        {
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setTemplateId(settingTemplateId);
            mail.setTargetObjectId(project.Krow__Contact__c);
            mail.setWhatId(invoice.Id);
            
            mail.setReplyTo(userEmail);
            mail.setSaveAsActivity(false);
            
            //To
            string [] to_receivers = new List<String>();
            Contact oCont = [select email from contact where id=:project.Krow__Contact__c];
            if (oCont == null)
                throw new DmlException('No Contact\'s email found...');
            else
                to_receivers.Add(oCont.Email);
            if (!string.isEmpty(additionalToEmailAddress) )
            {
                for (string receiver : additionalToEmailAddress.Split(','))
                {
                    to_receivers.Add(receiver);
                }
            }        
            mail.setToAddresses(to_receivers);
            
            // CC
            if (!string.isEmpty(ccEmailAddress) )
                mail.setCcAddresses(ccEmailAddress.Split(','));
            
            //Set email file attachments
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(doc.Name);
            efa.setBody(doc.Body);
            fileAttachments.add(efa);
    
            mail.setFileAttachments(fileAttachments);
            
            system.debug('sendEmail ==> mail: ' + mail);
            
            // Sending email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Email sent Successfully'));
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,e.getMessage()));
        }  
        return null;

    }

    public PageReference goBack()
    {
        PageReference parentPage = new PageReference('/' + Invoice.Id);
        parentPage.setRedirect(true);
        return parentPage;
    }

}