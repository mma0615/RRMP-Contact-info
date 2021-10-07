public class WorkAuthorizationEmailTemplateController {
    public static Id projectResourceId {get; set;}
    public static Krow__Project_Resources__c getProjectResource(){
         return [SELECT Id, Name, Krow__External_Resource__c FROM Krow__Project_Resources__c WHERE Id = : projectResourceId].get(0);
    }
    public static List<ProjectWrapper> getProjectWrappers(){
        Map<String,List<Krow__Task_Assignment__c>> taskAssignmentByProject = getTaskAssignmentByProject(); 
        List<ProjectWrapper> projectWrappers = new List<ProjectWrapper>();
        for(String projectName : taskAssignmentByProject.keySet()){
            ProjectWrapper projectWrapper = new ProjectWrapper();
            projectWrapper.name = projectName;
            projectWrapper.totalHoursScheduledInProject = 0;
            projectWrapper.totalHoursLoggedInProject = 0;
            projectWrapper.tasks = new List<TaskWrapper>();
            for (Krow__Task_Assignment__c taskAssignment : taskAssignmentByProject.get(projectName)) {
                projectWrapper.projectOwner = taskAssignment.Krow__Project__r.Owner.Name;
                TaskWrapper taskWrapper = new TaskWrapper();
                taskWrapper.name = taskAssignment.Krow__Krow_Task__r.Name;
                taskWrapper.hoursBillableLogged = taskAssignment.Krow__Billable_Hours_Logged__c;
                taskWrapper.hoursNonBillableLogged = taskAssignment.Krow__Non_Billable_Hours_Logged__c;
                taskWrapper.hoursScheduled = taskAssignment.Krow__Total_Schedule_Hours__c;
                projectWrapper.totalHoursScheduledInProject = projectWrapper.totalHoursScheduledInProject + taskAssignment.Krow__Total_Schedule_Hours__c;
                projectWrapper.totalHoursLoggedInProject = projectWrapper.totalHoursLoggedInProject + taskAssignment.Krow__Total_Hours_Logged__c;
                projectWrapper.tasks.add(taskWrapper);
            }
            projectWrappers.add(projectWrapper);
        }
        return projectWrappers;
    }
    
    public static Map<String,List<Krow__Task_Assignment__c>> getTaskAssignmentByProject(){
        Map<String, List<Krow__Task_Assignment__c>> taskAssignmentsByProject = new Map<String, List<Krow__Task_Assignment__c>>();
        for (Krow__Task_Assignment__c taskAssignment : getTaskAssignmentsByProjectResourcesId(projectResourceId)) {
            if(taskAssignmentsByProject.containsKey(taskAssignment.Krow__Project__r.Name)){
                List<Krow__Task_Assignment__c> taskAssignmentList = taskAssignmentsByProject.get(taskAssignment.Krow__Project__r.Name);
                taskAssignmentList.add(taskAssignment);
                taskAssignmentsByProject.put(taskAssignment.Krow__Project__r.Name, taskAssignmentList);
            }else{
                taskAssignmentsByProject.put(taskAssignment.Krow__Project__r.Name, new List<Krow__Task_Assignment__c>{taskAssignment});     
            }                                                 
        }
        return taskAssignmentsByProject;
    }

    private static List<Krow__Task_Assignment__c> getTaskAssignmentsByProjectResourcesId(String projectResourceId){
        return [SELECT Name, Krow__Krow_Task__r.Name, Krow__Project__r.Name, Krow__Billable_Hours_Logged__c,
                        Krow__Total_Schedule_Hours__c, Krow__Total_Hours_Logged__c, Krow__Non_Billable_Hours_Logged__c, 
                        Krow__Project__r.Owner.Name
                FROM Krow__Task_Assignment__c
                WHERE Krow__Project_Resource__c =:projectResourceId 
                AND Krow__Project__r.ExcludeFromWorkAuthorizationEmail__c != true 
                AND Krow__Project__r.Krow__Project_Status__c NOT IN('Complete','Canceled','Pipeline')
                AND Krow__Project__r.Krow__Archived__c = false
                AND Krow__Status__c NOT IN ('Rejected','Closed')];
                
    }
    
    public class ProjectWrapper{
        public String name {get;set;}
        public String projectOwner {get;set;}
        public Decimal totalHoursScheduledInProject {get;set;}
        public Decimal totalHoursLoggedInProject {get;set;}
        public List<TaskWrapper> tasks {get;set;}
    }

    public class TaskWrapper{
        public String name {get;set;}
        public Decimal hoursBillableLogged {get;set;}
        public Decimal hoursScheduled {get;set;}
        public Decimal hoursNonBillableLogged {get;set;}
    }

}