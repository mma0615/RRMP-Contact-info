declare module "@salesforce/apex/CompassEmailController.getOrgWideEmailAddress" {
  export default function getOrgWideEmailAddress(): Promise<any>;
}
declare module "@salesforce/apex/CompassEmailController.getDefaultSenderId" {
  export default function getDefaultSenderId(): Promise<any>;
}
declare module "@salesforce/apex/CompassEmailController.searchContactRecipient" {
  export default function searchContactRecipient(param: {searchTerm: any, selectedIds: any}): Promise<any>;
}
declare module "@salesforce/apex/CompassEmailController.getLookupResultsById" {
  export default function getLookupResultsById(param: {initialLookupIds: any}): Promise<any>;
}
declare module "@salesforce/apex/CompassEmailController.getEmailTemplates" {
  export default function getEmailTemplates(): Promise<any>;
}
declare module "@salesforce/apex/CompassEmailController.getJourneyParticipants" {
  export default function getJourneyParticipants(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CompassEmailController.sendCompassEmail" {
  export default function sendCompassEmail(param: {recordId: any, orgWideEmailId: any, contactRecipientIds: any, subject: any, emailBody: any, ccRecipients: any, bccRecipients: any}): Promise<any>;
}
