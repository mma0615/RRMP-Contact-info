declare module "@salesforce/apex/ChangeCloudController.getParticipantName" {
  export default function getParticipantName(param: {ParticipantNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getEventDetails" {
  export default function getEventDetails(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getEventSession" {
  export default function getEventSession(param: {eventId: any, ParticipantNumber: any, pstrue: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getSpeakerDetails" {
  export default function getSpeakerDetails(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.createTask" {
  export default function createTask(param: {eventId: any, firstname: any, lastname: any, email: any, phone: any, subject: any, comments: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.getParticipantSession" {
  export default function getParticipantSession(param: {ParticipantNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeCloudController.updateAttendance" {
  export default function updateAttendance(param: {ParticipantSessionId: any}): Promise<any>;
}
