public class CalendarInvites {

    @InvocableMethod(label='Sample Calendar Invite' description='Send calendar invites to Session Participants' category='Participant__c')
    public static void sendConfirmationCalendarInvite(List<ID> ids) {
        System.debug('*****[sendConfirmationCalendarInvite]ids-->'+ids);
        if(!ids.isEmpty()){
            List<Messaging.SingleEmailMessage> invites = new List<Messaging.SingleEmailMessage>();
            for(Session_Participant__c sessionParticipant : [SELECT Id, Name, Status__c,
                                                                        Participant__c,
                                                                            Participant__r.Member_Contact__c,
                                                                            Participant__r.Member_Contact__r.FirstName,
                                                                            Participant__r.Member_Contact__r.LastName,
                                                                            Participant__r.Member_Contact__r.Email,
                                                                        Event__c,
                                                                            Event__r.Location__c,
                                                                            Event__r.Location__r.Name,
                                                                            Event__r.Email_Sender_Id__c,
                                                                            Event__r.Email_Sender_Name__c,
                                                                        Session__c,
                                                                            Session__r.Name, 
                                                                            Session__r.Description__c, 
                                                                            Session__r.Subtitle__c, 
                                                                            Session__r.Start_Date_Time__c, 
                                                                            Session__r.End_Date_Time__c, 
                                                                            Session__r.Meeting_URL__c, 
                                                                            Session__r.Time_Zone__c
                                                                    FROM Session_Participant__c 
                                                                    WHERE Participant__c IN: ids])
            {
                
                System.debug('*****[sendConfirmationCalendarInvite]sessionParticipant-->'+sessionParticipant);
                String senderName = 'MC Integration User';//FROM default workflow user's email address setup;//need to updated everytime Process Automation Settings(/setup/WorkflowSettings/home) is updated
                String senderEmail = 'alexander@ulapp.co';//FROM default workflow user's email address setup;//need to updated everytime Process Automation Settings(/setup/WorkflowSettings/home) is updated
                String subject = '';
                if(sessionParticipant.Session__r.Name!=null){
                    subject = sessionParticipant.Session__r.Name;
                }
                System.debug('*****[sendConfirmationCalendarInvite]subject-->'+subject);
                String title = '';
                if(sessionParticipant.Session__r.Name!=null){
                    title = sessionParticipant.Session__r.Name;
                    
                    if(sessionParticipant.Session__r.Subtitle__c!=null){
                        title +=' - '+ sessionParticipant.Session__r.Subtitle__c;
                    }
                }
                System.debug('*****[sendConfirmationCalendarInvite]title-->'+title);
                String location = '';
                if(sessionParticipant.Event__r.Location__r.Name!=null){
                    location = sessionParticipant.Event__r.Location__r.Name;
                }
                System.debug('*****[sendConfirmationCalendarInvite]location-->'+location);
                Datetime startDateTime = null;
                if(sessionParticipant.Session__r.Start_Date_Time__c!=null){
                    startDateTime = sessionParticipant.Session__r.Start_Date_Time__c;
                }
                System.debug('*****[sendConfirmationCalendarInvite]startDateTime-->'+startDateTime);
                Datetime endDateTime = null;
                if(sessionParticipant.Session__r.End_Date_Time__c!=null){
                    endDateTime = sessionParticipant.Session__r.End_Date_Time__c;
                }
                System.debug('*****[sendConfirmationCalendarInvite]endDateTime-->'+endDateTime);
                String description = '';
                if(sessionParticipant.Session__r.Name!=null){
                    description = 'Session Description: '+ sessionParticipant.Session__r.Description__c;
                    
                    if(sessionParticipant.Session__r.Meeting_URL__c!=null){
                        description +=' \n Virtual Meeting Link: '+ sessionParticipant.Session__r.Meeting_URL__c;
                    }
                }
                System.debug('*****[sendConfirmationCalendarInvite]description-->'+description);
                List<String> toList = new List<String>();
                if(sessionParticipant.Participant__r.Member_Contact__r.Email!=null){
                   toList.add(sessionParticipant.Participant__r.Member_Contact__r.Email);
                }

                Messaging.SingleEmailMessage invite = EmailUtility.buildCalendarInvite(toList,
                                                            senderEmail,
                                                            senderName,
                                                            subject,//'SAMPLE CALENDAR INVITE SUBJECT',
                                                            title,//'MEETING INVITE TITLE',
                                                            location,//'MEETING LOCATION',
                                                            startDateTime,
                                                            endDateTime,
                                                            datetime.now(),
                                                            description,
                                                            datetime.now());
                invites.add(invite);
            }
            if(!invites.isEmpty()){
                Messaging.SendEmailResult[] result = EmailUtility.sendEmailMessage(invites);// CalendarInvites.sendinvite(invites);
            }
        }
    }

    public static Messaging.SingleEmailMessage buildCalendarInvite(List<string> emailsList, 
                                                                    string Organiser, 
                                                                    string name, 
                                                                    string subject, 
                                                                    string title, 
                                                                    string location, 
                                                                    dateTime startDate, 
                                                                    dateTime endDate, 
                                                                    dateTime createdDate, 
                                                                    string description, 
                                                                    dateTime lastmodifiedDate){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(emailsList);
        mail.setSubject(subject);      
        mail.setPlainTextBody(description);     
        mail.setHtmlBody(description);     
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
        attach.filename = 'reminder.ics'; 
        attach.ContentType = 'text/calendar';     
        attach.inline = true;     
        attach.body = invite(emailsList, Organiser, name, subject, 
                                        title, location, 
                                        startDate, endDate, 
                                        createdDate, description, 
                                        lastmodifiedDate );   
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 

        return mail;
    }

    public static void sendinvite(List<Messaging.SingleEmailMessage> invites) {  
        Messaging.SendEmailResult[] er = Messaging.sendEmail(invites); 
    }


    
    public static void sendinvite() {        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new List<String>{'jerick@ulapp.co'});
        mail.setSubject('TEST Meeting Invitation');      
        mail.setPlainTextBody('');     
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
        attach.filename = 'reminder.ics'; 
        attach.ContentType = 'text/calendar';     
        attach.inline = true;     
        attach.body = invite();   
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   
        Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail }); 
    }
    
    public static void sendinvite(List<string> emailsList, 
                                    string Organiser, 
                                    string name, 
                                    string subject, 
                                    string title, 
                                    string location, 
                                    dateTime startDate, 
                                    dateTime endDate, 
                                    dateTime createdDate, 
                                    string description, 
                                    dateTime lastmodifiedDate) {        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new List<String>{'jerick@ulapp.co'});
        mail.setSubject('TEST Meeting Invitation');       
        mail.setPlainTextBody(description);     
        mail.setHtmlBody(description);     
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
        attach.filename = 'reminder.ics'; 
        attach.ContentType = 'text/calendar';     
        attach.inline = true;     
        attach.body = invite(emailsList, Organiser, name, subject, 
                                    title, location, 
                                    startDate, endDate, 
                                    createdDate, description, 
                                    lastmodifiedDate );   
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   
        Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail }); 
    }
    
    private static Blob invite() {
        DateTime dt=DateTime.now().adddays(1);
        String currentdatetime = DateTime.now().format('yyyy\'0\'Mdd\'T\'HHmmss\'Z\'');
        String startdatetime=String.valueof(dt.year()+'0'+dt.month()+''+dt.day()+'T000000Z');
        String enddatetime=String.valueof(dt.year()+'0'+dt.month()+''+dt.day()+'T020000Z');
        String txtInvite = ''; 
        txtInvite += 'BEGIN:VCALENDAR\n';        
        txtInvite += 'PRODID::-//hacksw/handcal//NONSGML v1.0//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'METHOD:PUBLISH\n';
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'CLASS:PUBLIC\n';
        txtInvite += 'CREATED:'+currentdatetime+'\n';//20091026T203709Z\n';        
        txtInvite += 'DTEND:'+enddatetime+'\n';
        txtInvite += 'DTSTAMP:'+currentdatetime+'\n';//20191026T203709Z\n';        
        txtInvite += 'DTSTART:'+startdatetime+'\n';
        txtInvite += 'LAST-MODIFIED:'+currentdatetime+'\n';//20091026T203709Z\n';
        txtInvite += 'LOCATION:Not Disclosed\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'SUMMARY;';
        txtInvite += 'LANGUAGE=en-us:Meeting\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY><!-- Converted from text/plain format --></BODY></HTML>\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR'; 
        return Blob.valueOf(txtInvite);
    }
    
    public static Blob invite(List<String> emailsList, 
                              string Organiser, 
                              string name, 
                              string subject, 
                              string title, 
                              string location, 
                              dateTime startDate, 
                              dateTime endDate, 
                              dateTime createdDate, 
                              string description, 
                              dateTime lastmodifiedDat) {
        String txtInvite = '';
        string startdateTime;
        string enddateTIme;
        string createdDateTime;
        string lastmodifiedDatTime;
 
        startdateTime = startDate.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        enddateTIme = endDate.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        createdDateTime = createdDate.formatGMT('yyyyMMdd\'T\'hhmmss\'Z\'');
        lastmodifiedDatTime = lastmodifiedDat.formatGMT('yyyyMMdd\'T\'hhmmss\'Z\'');
 
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Microsoft Corporation//Outlook 16.0 MIMEDIR//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'CALSCALE:GREGORIAN\n';
        txtInvite += 'METHOD:REQUEST\n';
        txtInvite += 'REPLAY:ACCEPTED\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'ATTENDEE\n';
        txtInvite += 'CN=' + subject + '\n';
        for (String email: emailsList) {
            txtInvite += 'ATTENDEE:' + email + '\n';
        }
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        //txtInvite += 'X-WR-RELCALID:{0000002E-9CDF-9CE8-AD4C-66FC0A5A25F7}\n';
        txtInvite += 'CLASS:PUBLIC\n';
        txtInvite += 'CREATED:' + createdDateTime+'\n';
        txtInvite += 'DTEND:' + enddateTIme+'\n';
        txtInvite += 'DTSTART:' + startdateTime+'\n';
        txtInvite += 'LAST-MODIFIED:' + lastmodifiedDatTime+'\n';
        txtInvite += 'ORGANIZER;CN=' + name + ':mailto:' + Organiser + '\n';
        txtInvite += 'RSVP=TRUE\n';
        txtInvite += 'ROLE=REQ-PARTICIPANT\n';
        txtInvite += 'PARTSTAT=NEEDS-ACTION\n';
        txtInvite += 'CN=' + subject + ':mailto:' + Organiser + '\n';
        txtInvite += 'LOCATION:'+ location +'\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'SUMMARY:'+title+'\n';//THIS IS SUMMARY TEXT
        txtInvite += 'STATUS:NEEDS-ACTION\n';
        txtInvite += 'LANGUAGE=en-us:'+title+'\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        //txtInvite += 'UID:4036587160834EA4AE7848CBD028D1D200000000000000000000000000000000\n';
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:';
                txtInvite += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">';
                txtInvite += '\n<HTML>';
                txtInvite += '\n<HEAD>';
                txtInvite += '\n<META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000">';
                txtInvite += '\n<TITLE>This is a title in the HEAD</TITLE>';
                txtInvite += '\n</HEAD>';
                txtInvite += '\n<BODY>';
                txtInvite += '\n<p>Hello <b>Bold</b> New World</p><p>'+description+'</p><!-- Converted from text/plain format -->';
                txtInvite += '\n</BODY>';
                txtInvite += '\n</HTML>\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
        txtInvite += 'BEGIN:VALARM\n';
        txtInvite += 'TRIGGER:-PT15M\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'STATUS:CONFIRMED\n';
        txtInvite += 'DESCRIPTION:'+description+'\n';//Reminder
        txtInvite += 'END:VALARM\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        return Blob.valueOf(txtInvite);
     }

 }