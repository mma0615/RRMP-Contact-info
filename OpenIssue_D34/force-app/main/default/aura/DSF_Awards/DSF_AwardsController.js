({
    doInit : function(component, event, helper) {
        component.set("v.currUserId", $A.get("$SObjectType.CurrentUser.Id"));
    },

    handleLoadedUser : function(component, event, helper) {
        let user = component.get("v.currUser");
        if(user.ContactId == null) {
            component.set("v.isContactLoaded", true);
        }
    },

    handleContactUpdated : function(component, event, helper) {
        component.set("v.isContactLoaded", true);
    },

    handleLoadedApplications : function(component, event, helper) {
        let apps = component.get("v.rawApplications");

        if(apps.length > 0) {
            apps.sort(function(a, b){
                let x = a.Application_Submission_Year__c;
                let y = b.Application_Submission_Year__c;
                return y - x;
            });

            let condition = "Application__c IN (\'";

            for (let a in apps) {
                condition += apps[a].Id + '\', \'';
                if (a == apps.length-1) {
                    condition = condition.substring(0, condition.length-3) + ")";
                }
            }
            component.set("v.condition", condition);
        }

        component.set("v.applications", apps);
    },

    handleLoadedStudentTerms : function(component, event, helper) {
        let terms = component.get("v.rawStudentTerms");
        
        if (terms.length > 0) {
            let apps = component.get("v.applications");
            let seasons = [
                {season: "Fall", value: 0, label: component.get("v.seasonFall")},
                {season: "Winter", value: 1, label: component.get("v.seasonWinter")},
                {season: "Spring", value: 2, label: component.get("v.seasonSpring")}
            ];
            let appTerms = [];
            let appsFiltered = [];
            
            apps.map(app => {
                appTerms = terms.filter(term => term.Application__c == app.Id);
                
                if (appTerms.length != 0) {
                    appTerms.sort((a, b) => {
                        let x;
                        let y;
                        seasons.map(s => {
                            if (a.Term_Semester__c == s.season) {
                                x = s.value;
                            } else if (b.Term_Semester__c == s.season) {
                                y = s.value;
                            }
                        })
                        return x - y;
                    });
            
                    appTerms.map(t => {
                        seasons.map(s => {
                            if (t.Term_Semester__c == s.season) {
                                t.Term_Semester__c = s.label;
                            }
                        });
                    });

                    app.Student_Terms = appTerms;
                    appsFiltered.push(app);
                }
            });
            
            component.set("v.filteredApplications", appsFiltered);
        }
    }
})