declare module "@salesforce/apex/CampaignHierarchyPage.objectType" {
  export default function objectType(param: {recordIdVal: any}): Promise<any>;
}
declare module "@salesforce/apex/CampaignHierarchyPage.searchForCampaign" {
  export default function searchForCampaign(param: {recordIdVal: any}): Promise<any>;
}
declare module "@salesforce/apex/CampaignHierarchyPage.searchForEvent" {
  export default function searchForEvent(param: {recordIdVal: any}): Promise<any>;
}
declare module "@salesforce/apex/CampaignHierarchyPage.searchForSession" {
  export default function searchForSession(param: {eventList: any, recordIdVal: any}): Promise<any>;
}
