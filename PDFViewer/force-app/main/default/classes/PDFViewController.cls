/*********************
*   PDFViewController
*   @author:        Minh H Ma
*   @date:          12/17/2020
*   descrtiption:   This is to render email template to PDF, save as content file, and 
*                   link the file to provided recordId
*
*                   Parameters:
*                   formId: can be either valid classic or lightning email template's name.
*                   recordId: can be any salesforce record Id.
*                   formParamters: Json string. if passing in object make sure append 'list' to
*                       object name. For example:
*                           contact ==> contactlist
*                           email   ==> emaillist
*                       example formParamters input:
*                           {"contactname":"Sean Forbes","repname":"Tim Pitman","createddate":"12/21/2020","batterlist":[{ "id": "1001", "type": "Regular" },{ "id": "1002", "type": "Chocolate" },{ "id": "1003", "type": "Blueberry" },{ "id": "1004", "type": "Devils Food" }]}
*
*   Update History:
*   12/17/2020  Intial Version
*********************/
public with sharing class PDFViewController 
{
    public String displayText {get; set;}

    public PDFViewController() 
    {
        displayText = String.escapeSingleQuotes(
            ApexPages.currentPage().getParameters().get('displayText'));
    }

    @AuraEnabled
    public static ContentVersion generatePDF(String formId, String recordId, String formParameters) 
    {
        System.debug('formId: ' + formId);
        System.debug('RecordId: ' + recordId);
        System.debug('formParameters: ' + formParameters);
        string textValue;
        List<EmailTemplate> ListEmailTemplate = [SELECT Body,HtmlValue,Id,Name FROM EmailTemplate where name=:formid];
        /***** No formId found */
        if (ListEmailTemplate.isEmpty() )
        {
            //ListEmailTemplate = [SELECT Body,HtmlValue,Id,Name FROM EmailTemplate where name='NoTemplateFound'];
            textValue = 'Email Template <b>' + formId + '</b> not found...'; 
        }
        else
            textValue = populatingTextValue(formParameters, ListEmailTemplate[0].HtmlValue);

        Pagereference pg = Page.renderAsPDF;
        pg.getParameters().put('displayText', textValue);

        /***** get sObject Name from recordId */
        string strName = '';
        if (!String.isEmpty(recordId))
            strName = getObjectName(recordId);

        /****** Create contentversion */
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        if(Test.isRunningTest())
            cv.VersionData = Blob.valueOf('tempString');
        else
        	cv.VersionData = pg.getContentaspdf();
        cv.Title = formId + strName;
        cv.PathOnClient = formId + strName + '.pdf';
        
        insert cv;

 		System.debug('cv.id= '+cv.id);

        /***** Create contentdocumentlink if record id is not null */
        if (!String.isEmpty(recordId) & 
            !String.isEmpty(strName))
        {
            id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
		    System.debug('conDocId= '+conDocId);

		    ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'I';        
            insert cdl;
		    System.debug('cdl.id= ' + cdl.id);
        }
		

        return cv;
    }

    /***** Poulatulate email template body*/
    private static string populatingTextValue (string strParameters, string textValue)
    {
        string strName;
        string strValue;
        string strListName;
        string strListValue;
        List<string> listStr;
        Map<string,string> mapStr;
        
        JSONParser parser = JSON.createParser(strParameters);
        while (parser.nextToken() != null) 
        {            
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
            {
                parser.nextValue();
                if (parser.getCurrentName().endsWith('list') ||
                    parser.getCurrentName().endsWith('List') )
                {
                    strListName = parser.getCurrentName();
                    strListValue = '<table>';
                    while(parser.nextToken()!= JSONToken.END_ARRAY) 
                    {
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                        {
                            parser.nextValue();
                			strName = parser.getCurrentName();
                            strValue = parser.getText();
                            listStr.add(strName);
                            mapStr.Put(strName, strValue);
                            //System.Debug('***strName: ' + strName);
                			//System.Debug('***strValue: ' + strValue);
                			//strListValue += '<td>' + strValue + '</td>';
                        } 
                        else if(parser.getCurrentToken() == JSONToken.END_OBJECT) 
                        {
                            listStr.sort();
                            for (string key : listStr) 
                            {
                                strListValue += '<td>' + mapStr.get(key) + '</td>';
                            }

                            strListValue += '</tr>';
                            continue;
                        } 
                        else if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            listStr = new List<string>();
                            mapStr = new Map<string,string>();
                            strListValue += '<tr>';
                            continue;
                        }
                	}
                    strListValue += '</table>';
                    textValue = textValue.Replace('{' + strListName + '}', strListValue);
                    System.Debug('strListName: ' + strListName);
                    System.Debug('***** strListValue: ' + strListValue);
                }
                else
                {
                    strName = parser.getCurrentName();
                	strValue = parser.getText();
                    textValue = textValue.Replace('{' + strName + '}', strValue);
                    System.Debug('strName: ' + strName);
                	System.Debug('strValue: ' + strValue);
                }
            
            }
            
        }	

        System.Debug('textValue: ' + textValue); 
        return textValue;
    }

    /***** get recordId's name from Id field */
    private static string getObjectName(string recordId)
    {
        string strName = '';
        Id idRecordId;

        /***** check if recordId is id's field */
        if (recordId.length() == 15 ||
            recordId.length() == 18)
            idRecordId = Id.valueOf(recordId);
        System.debug('getObjectName ==> idRecordId: '+ idRecordId);
        
        /***** if record is provided and valid's id */
	    if (!String.isEmpty(idRecordId) )
        {
            try
            {
                String query = 'SELECT Id, Name ' +
                    ' from ' +  idRecordId.getSObjectType() +
                    ' where id =\'' + recordId + '\'';
			    System.debug('getObjectName ==> query: '+ query);        
 
			    List<sObject> listRecord = Database.query(query);        
        	    if (listRecord.size() == 1)
        	    {
        		    System.debug('getObjectName ==>  listRecord: '+ listRecord[0]);
            	    if (listRecord[0].get('Name') != null)
        			    strName = ' - ' + String.valueOf(listRecord[0].get('Name'));
        	    }
            }
            catch(exception e) {}
            System.debug('getObjectName ==> strName: '+ strName);
        }
        return strName;
    }
}