trigger TeleMeetTrigger on TeleMeet__c  (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        List<TeleMeet_Participant__c> conPar = new List<TeleMeet_Participant__c>();
        
        for(Telemeet__c t: Trigger.new){
            if(t.Contact__c != null){
                TeleMeet_Participant__c patient = new TeleMeet_Participant__c();
                patient.Contact__c = t.Contact__c;
                patient.Role__c = 'Patient';
                patient.TeleMeet__c = t.Id;
                conPar.add(patient);
            }
            if(t.Resource_Contact__c != null){
                TeleMeet_Participant__c provider = new TeleMeet_Participant__c();
                provider.Contact__c = t.Resource_Contact__c;
                provider.Role__c = 'Provider';
                provider.TeleMeet__c = t.Id;
                conPar.add(provider);
            }
        }
        if(!conPar.isEmpty()){
            insert conPar;
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        Set<Id> teleMeetids = new Set<Id>();    
        for(TeleMeet__c telemeet : trigger.new){
            teleMeetids.add(telemeet.Id);
        }
        String TimeZoneSidKey =  [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        
        Map<Id,TeleMeet__c> telemeetMap = new Map<Id,TeleMeet__c>([SELECT (SELECT Contact__c, Contact__r.Email, Optional__c, TeleMeet__r.Time_Zone__c  FROM TeleMeet_Participants__r WHERE Contact__r.Email != null) FROM TeleMeet__c WHERE Id IN :teleMeetids]);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(TeleMeet__c newTelemeet : trigger.new){
            TeleMeet__c oldTeleMeet = trigger.oldMap.get(newTelemeet.Id);
            
            if(newTelemeet.Status__c == 'Scheduled' && newTelemeet.Status__c != oldTeleMeet.Status__c){
                TeleMeet__c telemeet = telemeetMap.get(newTelemeet.Id);
                Timezone tz;
                for(TeleMeet_Participant__c participant : telemeet.TeleMeet_Participants__r) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{participant.Contact__r.Email});
                    mail.setSubject(newTelemeet.Subject__c);
                    mail.setHtmlBody(newTelemeet.Description__c);
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(newTelemeet.Id);
                    mail.setTargetObjectId(participant.Contact__c);
                    
                    DateTime startDT = newTelemeet.Start_Date_Time__c;
                    DateTime endDT = newTelemeet.End_Date_Time__c;
                    
                    
                    system.debug('startDT old>>>'+startDT);
                    system.debug('endDT old>>>'+endDT);
                    
                    
                    String startDTGMT = startDT.format('MM/dd/yyyy/HH/mm/ss', TimeZoneSidKey);
                    String endDTGMT = endDT.format('MM/dd/yyyy/HH/mm/ss', TimeZoneSidKey);
                    
                    system.debug('startDTGMT >>>'+startDTGMT );
                    system.debug('endDTGMT>>>'+endDTGMT);
                    
                    List<String> startDTtz = startDTGMT.split('/');
                    List<String> endDTtz = endDTGMT.split('/');
                    
                    DateTime startDTNew = DateTime.newInstanceGMT(Integer.valueOf(startDTtz[2]), Integer.valueOf(startDTtz[0]), Integer.valueOf(startDTtz[1]),  Integer.valueOf(startDTtz[3]), 
                                                                  Integer.valueOf(startDTtz[4]), Integer.valueOf(startDTtz[5]));
                    DateTime endDTNew = DateTime.newInstanceGMT(Integer.valueOf(endDTtz[2]), Integer.valueOf(endDTtz[0]), Integer.valueOf(endDTtz[1]),  Integer.valueOf(endDTtz[3]), 
                                                                Integer.valueOf(endDTtz[4]), Integer.valueOf(endDTtz[5]));
                    
                    
                    //mel
                    //tz = Timezone.getTimeZone('America/New_York');
                    tz = Timezone.getTimeZone(newTelemeet.Time_Zone__c);
                    startDT = startDTNew.addHours(-(tz.getOffset(startDTNew)/3600000));
                    endDT = endDTNew.addHours(-(tz.getOffset(endDTNew)/3600000));
                    
                    //system.debug('offset>>>'+tz.getOffset(startDT));
                    
                    //String sHours = string.valueOf(startDT.hour());
                    //String eHours = string.valueOf(endDT.hour());
                    
                    
                    system.debug('startDT>>>'+startDT);
                    system.debug('endDT>>>'+endDT);
                    
                    String startDTConverted = startDT.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
                    String endDTConverted = endDT.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
                    
                    
                    //
                    /*
//Convert it into Company TimeZone
String startDTGMT = startDT.format('MM/dd/yyyy/HH/mm/ss', TimeZoneSidKey);
String endDTGMT = endDT.format('MM/dd/yyyy/HH/mm/ss', TimeZoneSidKey);

system.debug('startDTGMT >>>'+startDTGMT );
system.debug('endDTGMT>>>'+endDTGMT);

system.debug('newTelemeet.Time_Zone__c'+newTelemeet.Time_Zone__c);
List<String> startDTtz = startDTGMT.split('/');
List<String> endDTtz = endDTGMT.split('/');

DateTime startDTNew = DateTime.newInstanceGMT(Integer.valueOf(startDTtz[2]), Integer.valueOf(startDTtz[0]), Integer.valueOf(startDTtz[1]),  Integer.valueOf(startDTtz[3]), 
Integer.valueOf(startDTtz[4]), Integer.valueOf(startDTtz[5]));
DateTime endDTNew = DateTime.newInstanceGMT(Integer.valueOf(endDTtz[2]), Integer.valueOf(endDTtz[0]), Integer.valueOf(endDTtz[1]),  Integer.valueOf(endDTtz[3]), 
Integer.valueOf(endDTtz[4]), Integer.valueOf(endDTtz[5]));


system.debug('startDTNew >>>'+startDTNew );
system.debug('endDTNew >>>'+endDTNew );


//Convert to selectted Timezone
String startDTConvertedV = startDTNew.format('MM/dd/yyyy/HH/mm/ss', newTelemeet.Time_Zone__c);
String endDTConvertedV = endDTNew.format('MM/dd/yyyy/HH/mm/ss', newTelemeet.Time_Zone__c);


system.debug('startDTConvertedV >>>'+startDTConvertedV );
system.debug('endDTConvertedV >>>'+endDTConvertedV );


List<String> startDTConvertedVTZ  = startDTConvertedV.split('/');
List<String> endDTConvertedVTZ = endDTConvertedV.split('/');

DateTime startDTNewTZ = DateTime.newInstanceGMT(Integer.valueOf(startDTConvertedVTZ[2]), Integer.valueOf(startDTConvertedVTZ[0]), Integer.valueOf(startDTConvertedVTZ[1]),  
Integer.valueOf(startDTConvertedVTZ[3]), Integer.valueOf(startDTConvertedVTZ[4]), Integer.valueOf(startDTConvertedVTZ[5]));
DateTime endDTNewTZ = DateTime.newInstanceGMT(Integer.valueOf(endDTConvertedVTZ[2]), Integer.valueOf(endDTConvertedVTZ[0]), Integer.valueOf(endDTConvertedVTZ[1]),  
Integer.valueOf(endDTConvertedVTZ[3]), Integer.valueOf(endDTConvertedVTZ[4]), Integer.valueOf(endDTConvertedVTZ[5]));


system.debug('startDTNewTZ>>>'+startDTNewTZ);
system.debug('endDTNewTZ >>>'+endDTNewTZ );

String startDTConverted = startDTNewTZ.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
String endDTConverted = endDTNewTZ.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');*/
                    
                    
                    //
                    
                    /*
Datetime startDTgmt = Datetime.newInstanceGmt(startDT.year(),startDT.month(),startDT.day(),startDT.hour(),startDT.minute(),startDT.second());
Datetime endDTTgmt = Datetime.newInstanceGmt(endDT.year(),endDT.month(),endDT.day(),endDT.hour(),endDT.minute(),endDT.second());


system.debug('startDTgmt>>>'+startDTgmt);
system.debug('endDTTgmt>>>'+endDTTgmt);

String startDTConverted = startDTgmt.format('yyyyMMdd\'T\'HHmmss\'Z\'','America/New_York');
String endDTConverted = endDTTgmt.format('yyyyMMdd\'T\'HHmmss\'Z\'','America/New_York');*/
                    
                    system.debug('startDTConverted>>>'+startDTConverted );
                    system.debug('endDTConverted>>>'+endDTConverted );
                    
                    //String startStr = String.valueof(startDT.year() + (String.valueOf(startDT.month()).length() > 1 ? '' : '0' ) + startDT.month() +''+ startDT.day() + 'T000000Z');
                    //String endStr = String.valueof(endDT.year() + (String.valueOf(endDT.month()).length() > 1 ? '' : '0' ) + endDT.month() +''+ endDT.day() + 'T010000Z');
                    ////String startStr = String.valueof(startDT.year() + (String.valueOf(startDT.month()).length() > 1 ? '' : '0' ) + startDT.month() +''+ startDT.day() + 'T'+(String.valueOf(startDT.hour()).length() > 1 ? '' : '0' )+startDT.hour()+(String.valueOf(startDT.minute()).length() > 1 ? '' : '00' )+startDT.minute()+'00Z');
                    ////String endStr = String.valueof(endDT.year() + (String.valueOf(endDT.month()).length() > 1 ? '' : '0' ) + endDT.month() +''+ endDT.day() + 'T'+(String.valueOf(endDT.hour()).length() > 1 ? '' : '0' )+endDT.hour()+(String.valueOf(endDT.minute()).length() > 1 ? '' : '0' )+endDT.minute()+'00Z');
                    
                    //system.debug('startStr>>>'+startStr);
                    //system.debug('startStr>>>'+endStr);
                    
                    //Create Meeting Body
                    String meetingInviteBody = ''; 
                    meetingInviteBody += 'BEGIN:VCALENDAR\n';        
                    meetingInviteBody += 'PRODID::-//hacksw/handcal//NONSGML v1.0//EN\n';
                    meetingInviteBody += 'VERSION:2.0\n';
                    meetingInviteBody += 'METHOD:PUBLISH\n';
                    meetingInviteBody += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
                    meetingInviteBody += 'BEGIN:VEVENT\n';
                    meetingInviteBody += 'CLASS:PUBLIC\n';
                    meetingInviteBody += 'CREATED:20150126T203709Z\n';        
                    meetingInviteBody += 'DTEND:'+endDTConverted+'\n';
                    meetingInviteBody += 'DTSTAMP:20150126T203709Z\n';        
                    meetingInviteBody += 'DTSTART:'+startDTConverted+'\n'; 
                    meetingInviteBody += 'LAST-MODIFIED:20150126T203709Z\n';
                    meetingInviteBody += 'LOCATION:' + newTelemeet.TeleMeet_URL__c + '\n';
                    meetingInviteBody += 'PRIORITY:5\n';
                    meetingInviteBody += 'SEQUENCE:0\n';
                    meetingInviteBody += 'SUMMARY:' + newTelemeet.Subject__c + '\n';
                    meetingInviteBody += 'DESCRIPTION:' + newTelemeet.Description__c + '\n';
                    meetingInviteBody += 'LANGUAGE=en-us:Meeting\n';
                    meetingInviteBody += 'TRANSP:OPAQUE\n';
                    meetingInviteBody += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY><!-- Converted from text/plain format --></BODY></HTML>\n';
                    meetingInviteBody += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
                    meetingInviteBody += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
                    meetingInviteBody += 'END:VEVENT\n';
                    meetingInviteBody += 'END:VCALENDAR';
                    
                    //Meeting Email Attachment
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.Filename = 'meeting.ics'; 
                    attach.ContentType = 'text/calendar';     
                    attach.Inline = true;     
                    attach.Body = Blob.valueOf(meetingInviteBody);
                    
                    //Attach Meeting Attachment
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                    emails.add(mail);
                }
            }
        }
        
        Messaging.SendEmailResult[] er = Messaging.sendEmail(emails);
    }
    
}