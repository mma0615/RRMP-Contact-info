# Expense Total

# Invoice

    Krow__Invoice__c Object
        Krow__Formatting__c add to 'Project Role & Rate' picklist
    
    Krow__Krow_Role__c Object
        Clin_Description__c

    ApexClass:  
        NCC_emailInvoiceController
        NCC_emailInvoiceControllerTest
        NCC_InvoiceControllerExtension
        NCC_InvoiceControllerExtensionTest

    Visual Page: 
        NCC_EmailInvoiceVF
        NCC_Print_InvoiceVF

    button link

        Preview PDF:
            Behavior:	Display in new window
            Display Type:	Detail Page Button
            Button or Link URL:
                /apex/
                {!IF( ISPICKVAL( Krow__Invoice__c.Krow__Formatting__c , "Project Role & Rate") ,
                "NCC_Print_InvoiceVF",
                "Krow__Print_Invoice")}
                ?Id={!Krow__Invoice__c.Id}
        
        Email Invoice:
            Behavior:	Display in new window
            Display Type:	Detail Page Button
            Button or Link URL:
                /apex/
                {!IF( ISPICKVAL( Krow__Invoice__c.Krow__Formatting__c , "Project Role & Rate") ,
                "NCC_EmailInvoiceVF",
                "Krow__EmailInvoiceFwd")}
                ?Id={!Krow__Invoice__c.Id}

# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## rename Lightning component bundles
    Select Id, DeveloperName from AuraDefinitionBundle

## Survey Migration Testing
    Testing survey Id: a3l1F000000UUWrQAO      
    select id, Survey__c, Survey__r.Name, Description__c, Sorting_Order__c, Question_Type__c, Options__c from Survey_Question__c where Survey__c in ('a3l1F000000UUWrQAO', 'a3l1F000000cKgLQAU') order by Survey__c 

    select id, name, Survey__c, Survey__r.Name, Session__c, Response_Number__c from Survey_Response__c where Survey__c in ('a3l1F000000UUWrQAO', 'a3l1F000000cKgLQAU') order by Survey__c, Response_Number__c 

    select id, name, Question__c, Survey_Question__c, Survey_Question__r.Name, Survey_Response__c, Survey_Response__r.Name, Answer__c, Report_Answer__c from Survey_Answer__c where Survey_Question__r.Survey__c in ('a3l1F000000UUWrQAO', 'a3l1F000000cKgLQAU') order by Survey_Question__r.Survey__c

    select id, name, Survey_Answer__c, createddate from Survey_Answer_Sentiment__c
  
    select id, name, event__r.name from survey__c where name like '%minh%'
    select id, Survey__c, Survey__r.Name, Description__c, Sorting_Order__c, Question_Type__c, Options__c from Survey_Question__c where createddate=today
    select id, name, Survey__c, Survey__r.Name, Session__c, Response_Number__c from Survey_Response__c where createddate=today
    select id, name, Question__c, Survey_Question__c, Survey_Question__r.Name, Survey_Response__c, Survey_Response__r.Name, Answer__c, Report_Answer__c from Survey_Answer__c where createddate=today order by Survey_Question__r.Survey__c
    List<Survey_Question__c> surveyQuestionList = 
    
    [select id from Survey_Question__c where Survey__c = null];
    delete surveyQuestionList;

## linktree Steps
    Add Logo_URL__c to Campaign__c (Campaign Layout)
    Add Show_To_Links__c to Event__c (Event Layout)
    Permission Sets:
        Compass Survey (All Access)
            Apex Classes: linktreeController
            Object
                Campaign__c : Logo_URL__c (read)
                Event__c(avail, visible, read): Show_To_Links__c (read)
        Compass (All Access)
            Apex Classes: linktreeController
            Object
                Campaign__c: Logo_URL__c (read,edit)
                Event__c: Show_To_Links__c (read,edit)
        Compass (Public Access)
            Apex Classes: linktreeController
            Object
                Campaign__c (read,create): Logo_URL__c (read)
                Event__c (read,create): Show_To_Links__c (read)
        Compass (Public Dashboard Access)
            Apex Classes: linktreeController
            Object
                Campaign__c: Logo_URL__c (read)
                Event__c : Show_To_Links__c (read)

    Add to Permission Sets:
        Apex Class: 
            linktreeController
        Object
            Campaigns
                Logo_URL__c - read/edit
            Event__c
                Show_To_Links__c to read/edit

## Import Surveys
    Manually add importSurvey to Event Layout
    Compass (All Access)
        Apex Class:
            importSurveyDataController
        Object
            Survey_Responses__c
                Response_Number__c - Read/Edit
