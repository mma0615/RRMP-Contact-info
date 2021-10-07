declare module "@salesforce/apex/CCESurveyController.getSurvey" {
  export default function getSurvey(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.getSurveyLogo" {
  export default function getSurveyLogo(param: {code: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.getSurveyFieldConfiguration" {
  export default function getSurveyFieldConfiguration(param: {code: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.getParticipantDetails" {
  export default function getParticipantDetails(param: {participantNumber: any, participantEmail: any, isStandalone: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.createResponse" {
  export default function createResponse(param: {eventId: any, formDetailAnswers: any, surveyQuestionAnswers: any, participantNumber: any, isStandalone: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.getSurveyAnswers" {
  export default function getSurveyAnswers(param: {surveyResponseId: any}): Promise<any>;
}
