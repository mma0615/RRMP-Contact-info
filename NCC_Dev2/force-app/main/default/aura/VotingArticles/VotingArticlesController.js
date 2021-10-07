({
	doInit:function(component, event, helper) {
        var dataId=component.get('v.recordId');
        component.set('v.articleids',dataId);
        var actionVote = component.get("c.Voteslike");
        actionVote.setParams({ getId : dataId});
        actionVote.setCallback(this, function(response) {
            var states = response.getState();
            if(states === 'SUCCESS') {
                component.set("v.likess",response.getReturnValue());
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(actionVote);
        var actionVotedown = component.get("c.VotesdisLikes");
        actionVotedown.setParams({ getId : dataId})
        actionVotedown.setCallback(this, function(response) {
            var states = response.getState();
            if(states === 'SUCCESS') {
                component.set("v.dislike",response.getReturnValue());
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(actionVotedown);
        
        
    },
    
    handlelike:function(component, event, helper){
        var voteDownValue = component.get("v.disableVotedown");
        var getids = component.get("v.articleids");
        var voteUp = component.get("v.likess");
        var voteDown = component.get("v.dislike");
        if(voteDownValue === true){
          component.set('v.dislike',voteDown-1);
          component.set('v.likess',voteUp+1);
         
        }
        else{
           component.set('v.likess',voteUp+1); 
        }
        var aftervoteUp = component.get("v.likess");
        var aftervoteDown = component.get("v.dislike");
        
        var action = component.get("c.insertVoteup");
        action.setParams({ LikeView : aftervoteUp,disLikeView : aftervoteDown,values:voteDownValue,getId:getids})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('getresponse ',response.getReturnValue());
                
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
        component.set('v.disableVoteUp',true);
         component.set('v.disableVotedown',false);
	},
   
    handledislike : function(component, event, helper){
        var getids = component.get("v.articleids");
        var voteUpValue = component.get("v.disableVoteUp");
        var voteUp = component.get("v.likess");
        var voteDown = component.get("v.dislike");
        if(voteUpValue === true){
          component.set('v.likess',voteUp-1);
         component.set('v.dislike',voteDown+1);
        }
        else{
           component.set('v.dislike',voteDown+1); 
        }
        var aftervoteUp = component.get("v.likess");
        var aftervoteDown = component.get("v.dislike");
       
        var action = component.get("c.insertvotedown");
        action.setParams({ disLikeView : aftervoteDown,likeview:aftervoteUp,values:voteUpValue,getId:getids})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('getresponse ',response.getReturnValue());
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
        component.set('v.disableVoteUp',false);
        component.set('v.disableVotedown',true);
	},
    handleClick:function(component, event, helper)
    {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://articles.coronafacts.com/s/"
        });
        urlEvent.fire();
    }
})