global class WorkAuthNotificationScheduleJob implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        WorkAuthNotificationJobHandler.sendWorkAuthNotification();
    }
}