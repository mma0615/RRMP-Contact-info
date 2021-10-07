declare module "@salesforce/apex/CC_EventRegistrationClass.DoInit" {
  export default function DoInit(param: {campaignId: any}): Promise<any>;
}
declare module "@salesforce/apex/CC_EventRegistrationClass.getContactInfo" {
  export default function getContactInfo(param: {emailstr: any}): Promise<any>;
}
declare module "@salesforce/apex/CC_EventRegistrationClass.submitBooking" {
  export default function submitBooking(param: {campaignId: any, FirstName: any, LastName: any, Email: any, Company: any, sessionIds: any}): Promise<any>;
}
