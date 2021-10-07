declare module "@salesforce/apex/NavigatorController.getNavigationDetailsWithVerif" {
  export default function getNavigationDetailsWithVerif(param: {contactId: any, token: any}): Promise<any>;
}
declare module "@salesforce/apex/NavigatorController.getNavigationDetails" {
  export default function getNavigationDetails(): Promise<any>;
}
declare module "@salesforce/apex/NavigatorController.sendTokenCode" {
  export default function sendTokenCode(param: {email: any}): Promise<any>;
}
declare module "@salesforce/apex/NavigatorController.doLogin" {
  export default function doLogin(param: {email: any, token: any}): Promise<any>;
}
declare module "@salesforce/apex/NavigatorController.getContactInfo" {
  export default function getContactInfo(param: {contactId: any}): Promise<any>;
}
