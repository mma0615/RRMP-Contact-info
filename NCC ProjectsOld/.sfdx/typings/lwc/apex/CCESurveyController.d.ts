declare module "@salesforce/apex/CCESurveyController.getSurvey" {
  export default function getSurvey(param: {eventId: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.createResponse" {
  export default function createResponse(param: {eventId: any, campaignId: any, contactDetails: any, result: any, dateOfSession: any}): Promise<any>;
}
declare module "@salesforce/apex/CCESurveyController.getSurveyAnswers" {
  export default function getSurveyAnswers(param: {surveyResponseId: any}): Promise<any>;
}
