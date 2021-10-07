global class OpenOrderUpdater implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
    // system.schedule('OpenOrderUpdater', '0 0 * * * ?',  new OpenOrderUpdater());

    global void execute(SchedulableContext scMain) {
        Open_Order_Updater_Config__c conf = Open_Order_Updater_Config__c.getOrgDefaults();
        if (conf == null || conf.Interval__c == null) throw new OpenOrderException('Custom setting not specified');

        // check last time this job was run and make sure X hours have passed since it last ran (go to the nearest 30 min)
        // if it has never run, go ahead and run it now
        ApexClass ac = [select Id from ApexClass where Name = 'OpenOrderUpdater'];
        DateTime dt1 = truncateToHour(System.now());

        list<AsyncApexJob> jobs = [SELECT CreatedDate FROM AsyncApexJob where JobType = 'BatchApex' and ApexClass.Name = 'OpenOrderUpdater' order by CompletedDate desc limit 1];
        if (jobs.isEmpty() || Math.round((dt1.getTime() - truncateToHour(jobs[0].CreatedDate).getTime()) / (1000.0 * 60 * 60)) >= conf.Interval__c) {
            Database.executeBatch(new OpenOrderUpdater(), Integer.valueOf(conf.Batch_Size__c));
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select id from orderitem where order.Is_Open__c = true');
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        // just need to touch the records
        Database.update(scope, false);
    }
    global void finish(Database.BatchableContext BC) {
    }
    public DateTime truncateToHour(DateTime dt) {
        return DateTime.newInstanceGMT(dt.yearGmt(), dt.monthGmt(), dt.dayGmt(), dt.hourGmt(), 0, 0);
    }
    class OpenOrderException extends Exception {}
}