declare module "@salesforce/apex/contactController.getContacts" {
  export default function getContacts(): Promise<any>;
}
declare module "@salesforce/apex/contactController.deleteContacts" {
  export default function deleteContacts(param: {lstConIds: any}): Promise<any>;
}
declare module "@salesforce/apex/contactController.getFieldTypes" {
  export default function getFieldTypes(param: {objectName: any}): Promise<any>;
}
