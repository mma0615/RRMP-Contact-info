declare module "@salesforce/apex/SurveyServices.getSurveyDetails" {
  export default function getSurveyDetails(param: {surveyId: any}): Promise<any>;
}
declare module "@salesforce/apex/SurveyServices.cloneSurvey" {
  export default function cloneSurvey(param: {surveyId: any, newRecord: any, setToActive: any, addClonePrefix: any}): Promise<any>;
}
