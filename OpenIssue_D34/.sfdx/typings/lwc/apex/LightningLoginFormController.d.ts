declare module "@salesforce/apex/LightningLoginFormController.login" {
  export default function login(param: {username: any, password: any, startUrl: any}): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.resetPassword" {
  export default function resetPassword(param: {username: any}): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.changePassword" {
  export default function changePassword(param: {newPass: any}): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.getIsUsernamePasswordEnabled" {
  export default function getIsUsernamePasswordEnabled(): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.getIsSelfRegistrationEnabled" {
  export default function getIsSelfRegistrationEnabled(): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.getSelfRegistrationUrl" {
  export default function getSelfRegistrationUrl(): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.getForgotPasswordUrl" {
  export default function getForgotPasswordUrl(): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.setExperienceId" {
  export default function setExperienceId(param: {expId: any}): Promise<any>;
}
declare module "@salesforce/apex/LightningLoginFormController.checkIfUsernameExists" {
  export default function checkIfUsernameExists(param: {email: any}): Promise<any>;
}
