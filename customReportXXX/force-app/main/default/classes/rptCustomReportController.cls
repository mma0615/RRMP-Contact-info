public with sharing class rptCustomReportController {
    public rptCustomReportController() {

    }

    @AuraEnabled(Cacheable = true)
    public static lwcData getRecords(string reportId)
    {
        System.debug('getRecords ==> reportId: '+ reportId  );
        lwcData oLWCData = new lwcData();




        //id reportId = 'm0A5w000000ERrIEAW';

		list<string> groupByList = new list<string>();
		map<string,string> groupByMap = new map<string,string>();
		string tallyingFieldStr = '';

		string queryRecordStr = 'Select id';
        string queryGroupByStr;

        List<Report_Header__mdt> rptHeaderList = 
            [select id, Object_API_Name__c from Report_Header__mdt where id = :reportId];
        List<Report_Detail__mdt> rptDetailList = new List<Report_Detail__mdt>();
        rptDetailList =  [select id,  Report_Header__c,
        	Field_API_Name__c, Group_By__c, Sequence__c, Sorted__c, Summary_Type__c
            from Report_Detail__mdt where Report_Header__c = : reportId
            order by Group_By__c, Sorted__c, Sequence__c];

        for (Report_Detail__mdt rptDetail : rptDetailList)
        {
            // get grouping
            if (!String.isEmpty(rptDetail.Group_By__c) )
            {
            	groupByMap.put(rptDetail.Group_By__c,rptDetail.Field_API_Name__c);
                groupByList.Add(rptDetail.Group_By__c);
            }
            
            // get talling fields
            if (!String.isEmpty(rptDetail.Summary_Type__c) )
                tallyingFieldStr += ', ' + rptDetail.Summary_Type__c + '(' + rptDetail.Field_API_Name__c + ')';
            
            //if (!rptDetail.Sorted__c == true) 
            //	sortByList.Add(rptDetail.Field_API_Name__c);

            queryRecordStr += ', ' + rptDetail.Field_API_Name__c ;

        }
		
		// Query detail records
		queryRecordStr +=  ' from ' + rptHeaderList[0].Object_API_Name__c;
        System.debug('getRecords ==> queryRecordStr: '+ queryRecordStr);
		List<sObject> sObjRecordList = Database.query(queryRecordStr);

		string groupbyStr = '';
		groupByList.sort();
		for (string groupStr : groupByList)
        {
            if (groupStr == '01')
                groupbyStr = groupByMap.get(groupStr);
            else
                groupbyStr += ', ' + groupByMap.get(groupStr);  
            queryGroupByStr = populatingGroupQuerry(groupbyStr, tallyingFieldStr, rptHeaderList[0].Object_API_Name__c);
            
            System.debug('getRecords ==> queryGroupByStr: '+ queryGroupByStr);            
        }

        


	
		
		//string sortKeyStr;
		//groupByList.Sort();
		/*
		string apiName;
		for (sObject oS : sObjectList)
        {
            System.debug('****' + oS.get('StageName') );
            
            for(string gpStr : groupByMap.keyset())
			{
                apiName = groupByMap.get(gpStr);
                
            	if (gpStr == '01')
            	{
                    //acc.getSobject('Owner').getSobject('Profile').get('Name');
                	groupBy01List.Add(string.valueOf(oS.getSobject('Account').get('ParentId')) );
                	System.debug('****' + oS.getSobject('Account').get('ParentId'));
                }
                
                
            	if (gpStr == '02')
            	{
                	groupBy02List.Add(string.valueOf(oS.getSobject('Account').get('Name')) );
                	System.debug('****' + oS.getSobject('Account').get('Name'));
                }
   				
			}

            
            
        }
*/







        return oLWCData;

    }

    private static string populatingGroupQuerry (string groupStr, string tallingFieldStr, string objNameStr)
    {
        string returnString;
        returnString = 'select ' + groupStr + tallyingFieldStr + 
                    ' from ' + objNameStr +
                    ' group by ' + groupStr;
        return returnString;
    }
    

     /*****
     * lwcData
    */
    public with sharing class lwcData 
    {
        @AuraEnabled public string contactInfo;
        @AuraEnabled public List<contactOption> listContactOption;
        @AuraEnabled public List<Contact_Information_Detail__mdt> listContactInfoDetail;

        public lwcData() {}
    }

    public with sharing class contactOption
    {
        @AuraEnabled public string label;
        @AuraEnabled public string value;
   

        public contactOption() {}
    }
}
