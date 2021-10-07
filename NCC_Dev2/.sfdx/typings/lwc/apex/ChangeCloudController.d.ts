declare module "@salesforce/apex/ChangeCloudController.getEventDetails" {
  export default function getEventDetails(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getEventDetailsHeader" {
  export default function getEventDetailsHeader(param: {eventId: any, pm: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getEventSession" {
  export default function getEventSession(param: {eventId: any, participantNumber: any, pstrue: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getEventMaterials" {
  export default function getEventMaterials(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getSpeakerDetails" {
  export default function getSpeakerDetails(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.createTask" {
  export default function createTask(param: {eventId: any, firstname: any, lastname: any, email: any, phone: any, subject: any, comments: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getParticipantSession" {
  export default function getParticipantSession(param: {participantNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.updateAttendance" {
  export default function updateAttendance(param: {ParticipantSessionId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getParticipantDetail" {
  export default function getParticipantDetail(param: {emailstr: any, eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getParticipantDetailByNumber" {
  export default function getParticipantDetailByNumber(param: {participantNumber: any}): Promise<any>;
}
