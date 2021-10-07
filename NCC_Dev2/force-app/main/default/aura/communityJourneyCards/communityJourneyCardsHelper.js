({
  getUserJourney: function (component, journeyId) {
    var userJourney = component.get("c.getUserJourney");
    userJourney.setParams({
      strJourneyId: journeyId
    });

    userJourney.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var userJourneyWrapper = response.getReturnValue();
        if (userJourneyWrapper.urlFromJourney === false) {
          component.set("v.userJourney", userJourneyWrapper.userJourney);
          console.log("!@#userJourney: " + component.get("v.userJourney"));
          component.set("v.urlFromJourney", userJourneyWrapper.urlFromJourney);
          if (userJourneyWrapper.lstUserMilestones !== undefined) {
            component.set(
              "v.userMilestones",
              userJourneyWrapper.lstUserMilestones
            );
            if (userJourneyWrapper.mapTasksByMilestoneName !== undefined) {
              var acts = [];
              for (var key in userJourneyWrapper.mapTasksByMilestoneName) {
                acts.push({
                  value: userJourneyWrapper.mapTasksByMilestoneName[key],
                  key: key
                });
                console.log("!@# Milestone: " + key);
              }
              component.set("v.userMilestoneRelatedInfo", acts);
            }
          }
        } else if (userJourneyWrapper.urlFromJourney === true) {
          component.set(
            "v.journeyMilestoneList",
            userJourneyWrapper.journeyMilestoneList
          );
          component.set("v.journeyData", userJourneyWrapper.journeyData);
        }
      } else {
        console.log("!@# User Journey not found!");
      }
    });
    $A.enqueueAction(userJourney);
  },
    
    updateParticipantMilestoneMetric : function(component, event, helper){
        var updateParticipantMilestoneMetric = component.get("c.processSurveyAssessmentComplete");
        const milestoneId = event.getSource().get("v.name");
    	updateParticipantMilestoneMetric.setParams({
      		participantMilestoneId: milestoneId
    	});

    	updateParticipantMilestoneMetric.setCallback(this, function (response) {
      		const state = response.getState();
      		if (state === "SUCCESS") {
                component.set("v.spinner", false);
        		const hasErrors = response.getReturnValue();
                let message = "Survey has been completed!";
        		let type = "Success";
                if(!hasErrors){
        			let userMilestone = component.get("v.userMilestones");
                    for(let i = 0; i < userMilestone.length; i++){
                        if(userMilestone[i].Id === milestoneId){
                            userMilestone[i].Progress__c = 100;
                        }
                    }
                    window.location.reload();
                    component.set("v.userMilestones", userMilestone);
                }else{
                    message = "Something went wrong. Please try again later."
                    type = "Error";
                }
                
                var resultToast = $A.get("e.force:showToast");
                resultToast.setParams({
                  message: message,
                  type: type
                });
                resultToast.fire();
      		}
    	});
        
    	$A.enqueueAction(updateParticipantMilestoneMetric);
    }
});