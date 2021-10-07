public class SessionParticipantTriggerUtility {

    public static void sendCalendarInvite(List<Session_Participant__c> newList){
        Map<String, String> SFTimezone = new Map<String, String>();
        SFTimezone.put('AKDT', 'America/Anchorage');
        SFTimezone.put('AST', 'America/Anchorage');
        SFTimezone.put('CDT', 'America/Chicago');
        SFTimezone.put('CST', 'America/Mexico_City');
        SFTimezone.put('EDT', 'America/New_York');
        SFTimezone.put('EST', 'America/New_York');
        SFTimezone.put('GT', 'Pacific/Gambier');
        SFTimezone.put('HADT', 'America/Adak');
        SFTimezone.put('HAST', 'America/Adak');
        SFTimezone.put('MT', 'Pacific/Marquesas');
        SFTimezone.put('MPDT', 'America/Mazatlan');
        SFTimezone.put('MPST', 'America/Mazatlan');
        SFTimezone.put('MDT', 'America/Denver');
        SFTimezone.put('MST', 'America/Denver');
        SFTimezone.put('PDT', 'America/Los_Angeles');
        SFTimezone.put('PST', 'America/Los_Angeles');
        SFTimezone.put('PT', 'Pacific/Pitcairn');
        
        
        Set<Id> sessonids = new Set<Id>();    
        for(Session_Participant__c session : newList){
            sessonids.add(session.Id);
        }
        //OrgWideEmail
        List<OrgWideEmailAddress> orgwide = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress];
        Map<String, OrgWideEmailAddress> orgwideMap = new Map<String, OrgWideEmailAddress>();
        for(OrgWideEmailAddress o : orgwide){
            orgwideMap.put(o.id, o);
        }
        
        String TimeZoneSidKey =  [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        List<Session_Participant__c> sessionList = [SELECT Id, Name, Contact__c, Contact__r.Email, Status__c, 
                                                    Event__r.Location__r.Name, Event__r.Email_Sender_Id__c, Event__r.Email_Sender_Name__c,
                                                    Session__r.Name, Session__r.Subtitle__c, Session__r.Calendar_Invite_Email_Description__c,
                                                    Session__r.Time_Zone__c, Session__r.Description__c, Session__r.Meeting_Info__c, Session__r.Meeting_URL__c, Session__r.Calendar_Info__c,
                                                    Session__r.Start_Date_Time__c, Session__r.End_Date_Time__c
                                                    FROM Session_Participant__c WHERE Id IN :newList];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Timezone tz;
        String timeZoneUpdate = '';
        for(Session_Participant__c newSession : sessionList){
            //Session_Participant__c oldSession = oldMap.get(newSession.Id);
            
            //if(newSession.Status__c == 'Registered' && newSession.Status__c != oldSession.Status__c && newSession.Contact__c != null && newSession.Contact__r.Email != null){
            if(newSession.Status__c == 'Registered' && newSession.Contact__c != null && newSession.Contact__r.Email != null){
                String meetinfo = (newSession.Session__r.Calendar_Info__c != null && (newSession.Session__r.Calendar_Info__c).contains('\n') ? (newSession.Session__r.Calendar_Info__c).replace('\n', '') : newSession.Session__r.Calendar_Info__c);
                meetinfo = (meetinfo != null && meetinfo.contains('target="_blank"') ? meetinfo.replace('target="_blank"', '') : meetinfo);
                system.debug('meeting info>>>'+meetinfo);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(newSession.Event__r.Email_Sender_Id__c);
                mail.setToAddresses(new List<String>{newSession.Contact__r.Email});
                //mail.setSenderDisplayName(newSession.Event__r.Email_Sender_Name__c);
                //mail.setReplyTo(orgwideMap.get(newSession.Event__r.Email_Sender_Id__c).Address);
                mail.setSubject(newSession.Session__r.Name);
                mail.setHtmlBody((newSession.Session__r.Meeting_Info__c != null ? newSession.Session__r.Meeting_Info__c : '') + '<br/>' 
                                 /* (newSession.Session__r.Meeting_Info__c != null ? newSession.Session__r.Meeting_Info__c : '')*/);
                mail.setSaveAsActivity(true);
                //mail.setWhatId(newSession.Id);
                mail.setTargetObjectId(newSession.Contact__c);
                
                DateTime startDT = newSession.Session__r.Start_Date_Time__c;
                DateTime endDT = newSession.Session__r.End_Date_Time__c;
                
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
                
                timeZoneUpdate = SFTimezone.get(newSession.Session__r.Time_Zone__c);
                tz = Timezone.getTimeZone(timeZoneUpdate);
                startDT = startDTNew.addHours(-(tz.getOffset(startDTNew)/3600000));
                endDT = endDTNew.addHours(-(tz.getOffset(endDTNew)/3600000));
                
                system.debug('startDT>>>'+startDT);
                system.debug('endDT>>>'+endDT);
                
                String startDTConverted = startDT.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
                String endDTConverted = endDT.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
                
                system.debug('startDTConverted>>>'+startDTConverted );
                system.debug('endDTConverted>>>'+endDTConverted );
                system.debug('newSession.Contact__r.Email'+newSession.Contact__r.Email);
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
                //meetingInviteBody += 'ORGANIZER:mailto:'+newSession.Contact__r.Email+'\n'; 
                meetingInviteBody += 'ORGANIZER;CN='+newSession.Event__r.Email_Sender_Name__c+':MAILTO:'+orgwideMap.get(newSession.Event__r.Email_Sender_Id__c).Address+'\n'; 
                meetingInviteBody += 'DTEND:'+endDTConverted+'\n';
                meetingInviteBody += 'DTSTAMP:20150126T203709Z\n';        
                meetingInviteBody += 'DTSTART:'+startDTConverted+'\n'; 
                meetingInviteBody += 'LAST-MODIFIED:20150126T203709Z\n';
                meetingInviteBody += 'LOCATION:' + (newSession.Session__r.Meeting_URL__c != null ? newSession.Session__r.Meeting_URL__c : newSession.Event__r.Location__r.Name) + '\n';
                meetingInviteBody += 'PRIORITY:5\n';
                meetingInviteBody += 'SEQUENCE:0\n';
                meetingInviteBody += 'SUMMARY:' + (newSession.Session__r.Name != null ? newSession.Session__r.Name : '')+'\n';
                //meetingInviteBody += 'DESCRIPTION:' + (newSession.Session__r.Meeting_Info__c != null ? newSession.Session__r.Meeting_Info__c : newSession.Session__r.Meeting_URL__c)+'\n';
                meetingInviteBody += 'DESCRIPTION:'+(meetinfo!= null ? meetinfo : '')+'\n';
                //meetingInviteBody += 'DESCRIPTION:'+'<a href="'+newSession.Session__r.Meeting_URL__c+'">Click Here</>'+'\n';
                meetingInviteBody += 'LANGUAGE=en-us:Meeting\n';
                meetingInviteBody += 'TRANSP:OPAQUE\n';
                meetingInviteBody += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY></BODY></HTML>\n';
                //meetingInviteBody += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">\n<HTML>\n<HEAD>\n<META NAME="Generator" CONTENT="MS Exchange Server version rmj.rmm.rup.rpr">\n<TITLE></TITLE>\n</HEAD>\n<BODY>\n<p>Hello <b>Bold</b> New World</p>\n\n<P DIR=LTR><SPAN LANG="en-us"><FONT FACE="Calibri">This is some</FONT></SPAN><SPAN LANG="en-us"><B> <FONT FACE="Calibri">HTML</FONT></B></SPAN><SPAN LANG="en-us"><FONT FACE="Calibri"></FONT></SPAN><SPAN LANG="en-us"><U> <FONT FACE="Calibri">formatted</FONT></U></SPAN><SPAN LANG="en-us"><FONT FACE="Calibri"></FONT></SPAN><SPAN LANG="en-us"><I> <FONT FACE="Calibri">text</FONT></I></SPAN><SPAN LANG="en-us"><FONT FACE="Calibri">.</FONT></SPAN><SPAN LANG="en-us"></SPAN></P>\n\n</BODY>\n</HTML>\n';
                
                /*string html_begin = '<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2//EN\">' +
                '\n<html>' +
                '\n<head>' +
                '\n<title></title>' +
                '\n</head>' +
                '\n<body>' +
                '\n<!-- Converted from text/rtf format -->\n\n<P DIR=LTR><SPAN LANG=\"en-us\">' +
                '\n<Font face=\"Times New Roman\"';
                
                String body = 'I simply <b> want some bold </b> here 555';
                
                string html_end = '</font></span></body>\n</html>';
                string html_body = html_begin + body + html_end;
                
                meetingInviteBody += 'X-ALT-DESC;FMTTYPE=text/html:' + html_body;
                meetingInviteBody += 'X-ALT_DESC;FMTTYPE=text/html:' + html_body;*/
                
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
                system.debug('meetingInviteBody'+meetingInviteBody);
                //Attach Meeting Attachment
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                emails.add(mail);
            }
            
            newSession.Sent_Calendar_Invite__c = true;
        }
        
        Messaging.SendEmailResult[] er = Messaging.sendEmail(emails);
        update sessionList;
        
    }
}