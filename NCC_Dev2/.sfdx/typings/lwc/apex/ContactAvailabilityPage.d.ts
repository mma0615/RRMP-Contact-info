declare module "@salesforce/apex/ContactAvailabilityPage.getFieldValues" {
  export default function getFieldValues(): Promise<any>;
}
declare module "@salesforce/apex/ContactAvailabilityPage.searchForContact" {
  export default function searchForContact(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactAvailabilityPage.searchForConAvaRecord" {
  export default function searchForConAvaRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactAvailabilityPage.searchForTelemeet" {
  export default function searchForTelemeet(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactAvailabilityPage.searchForContactAvailability" {
  export default function searchForContactAvailability(param: {recordId: any, specialty: any, startdate: any, enddate: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactAvailabilityPage.scheduleMeeting" {
  export default function scheduleMeeting(param: {recordId: any, area: any, otherarea: any, internalnotes: any, contId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactAvailabilityPage.updateTelemeet" {
  export default function updateTelemeet(param: {contactAvailabilityId: any, telemeetId: any}): Promise<any>;
}
