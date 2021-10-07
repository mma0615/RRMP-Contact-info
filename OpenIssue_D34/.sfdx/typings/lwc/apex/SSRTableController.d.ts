declare module "@salesforce/apex/SSRTableController.fetchUser" {
  export default function fetchUser(): Promise<any>;
}
declare module "@salesforce/apex/SSRTableController.fetchDate" {
  export default function fetchDate(param: {pageAccess: any, collegeAccountId: any}): Promise<any>;
}
declare module "@salesforce/apex/SSRTableController.getPicklistValues" {
  export default function getPicklistValues(param: {objectAPIName: any, fieldAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/SSRTableController.getRecords" {
  export default function getRecords(): Promise<any>;
}
declare module "@salesforce/apex/SSRTableController.updateRecordsv2" {
  export default function updateRecordsv2(param: {jsonString: any}): Promise<any>;
}
declare module "@salesforce/apex/SSRTableController.notifyUpdatesDone" {
  export default function notifyUpdatesDone(): Promise<any>;
}
