/**
 * NCC_InvoiceControllerExtension
 * @author Minh Ma 
 * @date 02/28/2021
 * @description This prints invoice to PDF for Invoice Formatting = 'Project Role & Rate'
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
public class NCC_InvoiceControllerExtension 
{
    public String invId 
    {
        get { return invId ;}
      
        set { invId = value; 
              getInvoice();}  
    }
    
    public String invoiceId { get;set; }

    public static string language { get; set; }

    public static string dateFormat{ get; set; }
    public static string defaultFontSize { get; set; }
    public static string currencySymbol { get; set; }
    public static string currencyFormat { get; set; }
    
    public List<summaryBy> resourceList { get; set; }
    public List<summaryBy> projectList { get; set; }
    public List<summaryBy> projectRoleAndRate { get; set; }
    public List<summaryBy> summaryList { get; set; }
    
    //private map<string, Krow__Krow_Role__c> roleMap { get; set; }
    
    public static list<Krow__Invoice_Line_Item__c> invLineItemList { get; set; }
    
    public List<Schema.FieldSetMember> getinvoiceFieldSet () 
    {
        return SObjectType.Krow__Invoice__c.FieldSets.Krow__Invoice_Fieldset.getFields();
    }
    
    public Krow__Invoice__c invoice { get; set; }

    public NCC_InvoiceControllerExtension() 
    {                
    }
    
    public NCC_InvoiceControllerExtension(ApexPages.StandardController controller) {
    
        invoiceId = ApexPages.currentPage().getParameters().get('id');
        system.debug('invoiceId : ' + invoiceId);
    }
    
    /***** Get invoice from input parameter and populating 
     * all related objects
     */
    public void getInvoice()
    {
        invoiceId = invId;
        system.debug('NCC_InvoiceComponentController ==> invId: ' + invId);
        system.debug('NCC_InvoiceComponentController ==> invoiceId : ' + invoiceId);
    
        /***** getting invoice fields */
        this.invoice = [select id, Krow__Organization__r.Krow__Logo_Id__c, Krow__Organization__r.Krow__Logo_Url__c,
            Krow__Organization__r.Name, Krow__Organization__r.Krow__Address__c, Krow__Invoice_Account__r.Name,
            Krow__Footer__c, Krow__Invoice_Total__c, Krow__Project__c, Krow__Account__c, Krow__Address__c,
            Krow__Project__r.name, Krow__Project__r.Project_Code__c, Krow__PO_Number__c, Krow__Invoice_Serial_Number__c,
            Krow__Invoice_Date__c, Krow__Due_Date__c, Krow__Notes__c, Krow__Summarize__c, Krow__Start_Date__c, Krow__End_Date__c,
            Krow__Include_Rate__c, Krow__Show_All_Hours__c, Krow__Tax_Type__c, Krow__Include_Notes__c, Krow__Discount__c,
            Krow__Invoice_Amount__c, Krow__Labour_Hours__c, Krow__Service_Notes__c, Krow__Expense_Amount__c, Krow__Expense_Notes__c,
            Krow__Invoice_Subtotal__c, Krow__Total_Tax_Amount__c, Krow__Total_Tax_2_Amount__c
            from Krow__Invoice__c where id = :invoiceId];
        
        /**** setting defaults */
        language = 'English';
        //defaultFontSize = '12';
        dateFormat = 'MM\'/\'dd\'/\'yyyy';
        currencyFormat = '###,###,###,##0.00';
        currencySymbol = '$';
        system.debug('dateFormat: ' + dateFormat);
            
        /***** Summary By Person */ 
        List<AggregateResult> AggregateResultList = [select Krow__Project_Resource__r.name ResourceName, sum(Krow__Hours__c) TotalHours, 
            sum(Krow__Amount_Total__c) TotalAmount, sum(Krow__Cost_Amount__c) TotalCost, avg(Krow__Bill_Rate__c) BillRate
            from Krow__Invoice_Line_Item__c 
            where Krow__Invoice__c= :invoiceId
                and Krow__Timesheet_Split__r.Krow__Billable__c = true 
                and Krow__Timesheet_Split__r.Krow__Approval_Status__c='Approved' 
                and Krow__Date__c >= :invoice.Krow__Start_Date__c 
                and Krow__Date__c <= :invoice.Krow__End_Date__c
            group by Krow__Project_Resource__r.name];
            
        resourceList = new List<summaryBy>();
        for(AggregateResult aggr:AggregateResultList)
        {             
            summaryBy sBy = new summaryBy(); 
            sBy.name = (string) aggr.get('ResourceName');
            sBy.billRate = (decimal)aggr.get('BillRate');
            sBy.totalHours = (decimal)aggr.get('TotalHours');
            sBy.totalAmount = (decimal)aggr.get('TotalAmount'); 
            resourceList.Add(sBy);
        }
        system.debug('resourceList: ' + resourceList);
            
        /***** Summary by Project */
        AggregateResultList = [select Krow__Timesheet_Split__r.Krow__Krow_Project__r.Name ProjectName, sum(Krow__Hours__c) TotalHours, 
            sum(Krow__Amount_Total__c) TotalAmount, sum(Krow__Cost_Amount__c) TotalCost, avg(Krow__Bill_Rate__c) BillRate
            from Krow__Invoice_Line_Item__c 
            where Krow__Invoice__c= :invoiceId
                and Krow__Timesheet_Split__r.Krow__Billable__c = true 
                and Krow__Timesheet_Split__r.Krow__Approval_Status__c='Approved' 
                and Krow__Date__c >= :invoice.Krow__Start_Date__c 
                and Krow__Date__c <= :invoice.Krow__End_Date__c
            group by Krow__Timesheet_Split__r.Krow__Krow_Project__r.Name];
            
        projectList = new List<summaryBy>();
        for(AggregateResult aggr:AggregateResultList)
        {             
            summaryBy sBy = new summaryBy(); 
            sBy.Name = (string) aggr.get('ProjectName');
            sBy.billRate = (decimal)aggr.get('BillRate');
            sBy.totalHours = (decimal)aggr.get('TotalHours');
            sBy.totalAmount = (decimal)aggr.get('TotalAmount'); 
            projectList.Add(sBy);
        }          
        
        // Get Invoice Line Items
        //invLineList = [select id, name from Invoice_Line__c where Invoice__c = :invoiceId];
        
        // Get Invoice Line Items
        invLineItemList = [select id, name, Krow__Invoice__c, Krow__Timesheet_Split__r.Krow__Project_Role__c, 
            Krow__Timesheet_Split__r.Krow__Project_Role__r.Name, Krow__Timesheet_Split__r.Krow__Project_Role__r.CLIN_Description__c,
            Krow__Bill_Rate__c, Krow__Hours__c, Krow__Cost_Amount__c, 
            Krow__Project_Resource__c, Krow__Project_Resource__r.name, Krow__Amount_Total__c
            from Krow__Invoice_Line_Item__c 
            where Krow__Invoice__c = :invoiceId
                and Krow__Timesheet_Split__r.Krow__Billable__c = true 
                and Krow__Timesheet_Split__r.Krow__Approval_Status__c='Approved' 
                and Krow__Date__c >= :invoice.Krow__Start_Date__c 
                and Krow__Date__c <= :invoice.Krow__End_Date__c
                order by Krow__Invoice__c,
                    Krow__Timesheet_Split__r.Krow__Project_Role__r.Name,
                    Krow__Timesheet_Split__r.Krow__Project_Role__c, 
                    Krow__Bill_Rate__c,
                    Krow__Project_Resource__r.name ];
        
        // Summary by ProjectRole and Rate
        Set<string> invLineKeySet = new Set<string>();
        
        // populating roleMap ******* Need to fix on Id__c when moving to production ********
        //roleMap = new map<string, Krow__Krow_Role__c>();
        //for (Krow__Krow_Role__c role : [select id, name, CLIN_Description__c, Id__c from Krow__Krow_Role__c])
        //{
        //    roleMap.put(role.Id__c, role);
        //}
        
        // populating projectRoleAndRate 
        projectRoleAndRate = new List<summaryBy>();
        for (Krow__Invoice_Line_Item__c invLineItem : invLineItemList)
        {
            string invLineItemKey = String.valueof(invLineItem.Krow__Invoice__c) +                // Invoice 
                String.valueof(invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c) +      // Project Role
                String.valueof(invLineItem.Krow__Project_Resource__r.name) +                      // Resource
                string.valueOf(invLineItem.Krow__Bill_Rate__c);                                   // Bill Rate
            if (!invLineKeySet.Contains(invLineItemKey) )
            {
                invLineKeySet.Add(invLineItemKey);
                //Krow__Krow_Role__c role = roleMap.get(invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c);
                summaryBy sBy = new summaryBy();
                sBy.uniqueKey = invLineItemKey;
                //sBy.Name = role.Name;
                //sby.CLIN_Description = role.CLIN_Description__c;
                sBy.Name = invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__r.Name;
                sby.CLIN_Description = invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__r.CLIN_Description__c;
                sBy.resource = invLineItem.Krow__Project_Resource__r.name;
                sBy.unitOfIssue = 'Hours';
                sBy.billRate = invLineItem.Krow__Bill_Rate__c;
                projectRoleAndRate.Add(sBy);
            }
        }
        
        // projectRoleAndRate RollUP;
        for (summaryBy sBy : projectRoleAndRate)
        {
            sBy.totalHours = 0;
            sBy.totalAmount = 0;
            sBy.totalCost = 0;
            for (Krow__Invoice_Line_Item__c invLineItem : invLineItemList)
            {
                string invLineItemKey = String.valueof(invLineItem.Krow__Invoice__c) +                // Invoice 
                    String.valueof(invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c) +      // Project Role
                    String.valueof(invLineItem.Krow__Project_Resource__r.name) +                      // Resource
                    string.valueOf(invLineItem.Krow__Bill_Rate__c);                                   // Bill Rate
                if (sBy.uniqueKey == invLineItemKey)
                {
                    sBy.totalHours += invLineItem.Krow__Hours__c;
                    sBy.totalAmount += invLineItem.Krow__Amount_Total__c;
                    sBy.totalCost += invLineItem.Krow__Cost_Amount__c;
                }
            }
        }
        
        // populating summary Project by Role & Rate
        string LastSummaryKey = '';
        summaryBy newSBy;
        summaryList = new List<summaryBy>();
        for (summaryBy sBy : projectRoleAndRate)
        {
            // Print Summary line
            if (String.isEmpty(lastSummaryKey) || 
                sBy.Name != lastSummaryKey )
            {
                lastSummaryKey = sBy.Name;
                newSBy = new summaryBy();
                newSBy.itemSubNumber = 'Sum';
                newSBY.Name = sBy.CLIN_Description;
                newSBy.CLIN_Description = sBy.Name;
                summaryList.Add(newSBy);
                
            }
            
            // print detail line
            newSBy = new summaryBy();
            newSBY.Name = sBy.resource;
            newSBy.CLIN_Description = sBy.Name;
            newSBY.billRate= sBy.billRate;
            newSBY.totalHours= sBy.totalHours;
            newSBY.totalAmount= sBy.totalAmount;
            summaryList.Add(newSBy);
        }                
    }
    
    /***** this class holds all summary info for invoice printing */
    public class summaryBy
    {
        string name;
        string uniqueKey;
        string CLIN_Description;
        string resource;
        string itemSubNumber;
        string unitOfIssue;
        decimal billRate;
        decimal totalHours;
        decimal totalAmount;
        decimal totalCost;
        
        public String getName () 
        {
            return this.name;
        }
        
        public String getDescription () 
        {
            return this.CLIN_Description;
        }
        
        public String getItemSubNumber () 
        {
            return this.itemSubNumber;
        }
        
        public String getUnitOfIssue () 
        {
            return this.unitOfIssue;
        }
        
        public decimal getBillRate () 
        {
            return this.billRate;
        }
        
        public decimal getTotalHours () 
        {
            return this.totalHours ;
        }
        
        public decimal getTotalAmount () 
        {
            return this.totalAmount;
        }
        
        public decimal getTotalCost () 
        {
            return this.totalCost;
        }  
        
    }
}