({
  updateContact: function (component, event, helper) {
    // Get uploaded file details
    // NOTE: This is specifically for single image upload for Journey Participant Page
    let uploadedFiles = event.getParam("files");

    var profileURLContactUpdate = component.get("c.updatePicturePath");
    profileURLContactUpdate.setParams({
      attachToRecId: component.get("v.userRecordId"),
      contentVersionRecId: uploadedFiles[0].contentVersionId
    });
    profileURLContactUpdate.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" || state === "DRAFT") {
        var contactPicWrapper = response.getReturnValue();
        let message = "Your profile picture has been updated.";
        let type = "Success";
        let profileURL = contactPicWrapper.profileURL;
        if (contactPicWrapper.hasErrors) {
          message = "Sorry. Something went wrong.";
          profileURL = "";
          type = "Error";
        } else {
          component.set("v.profilePictureURL", profileURL);
        }
        //show close upload button
        component.set("v.hasUploaded", true);

        //Show success/error message
        var resultToast = $A.get("e.force:showToast");
        resultToast.setParams({
          message: message,
          type: type
        });
        resultToast.fire();
      }
    });
    $A.enqueueAction(profileURLContactUpdate);
  },

  deleteProfileImage: function (component, event, helper) {
    var profileURLContactUpdate = component.get("c.removeAndDeleteImageURL");

    profileURLContactUpdate.setParams({
      participantContactId: component.get("v.userRecordId"),
      profileImageURL: component.get("v.profilePictureURL")
    });
    profileURLContactUpdate.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var isSuccess = response.getReturnValue();
        let message = "Your profile picture has been removed.";
        let type = "Success";
        if (!isSuccess) {
          message = "Sorry. Something went wrong.";
          profileURL = "";
          type = "Error";
        } else {
          component.set("v.profilePictureURL", "");
        }
        //show close upload button
        component.set("v.hasUploaded", true);

        //Show success/error message
        var resultToast = $A.get("e.force:showToast");
        resultToast.setParams({
          message: message,
          type: type
        });
        resultToast.fire();
      }
    });
    $A.enqueueAction(profileURLContactUpdate);
  }
});