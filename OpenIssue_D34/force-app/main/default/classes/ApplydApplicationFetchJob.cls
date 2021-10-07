global class ApplydApplicationFetchJob implements Schedulable {
  private static final String CRON_EXP = '0 0 0/1 1/1 * ? *';

  global void execute(SchedulableContext sc) {
    ApplicationSubmissionService.fetchApplydApplications();
  }

  global static String schedule(String jobName, String cron) {
    if (jobName == null) { jobName = 'Applyd Application Fetch Job'; }
    if (cron == null) { cron = ApplydApplicationFetchJob.CRON_EXP; }
    return System.schedule(jobName, cron, new ApplydApplicationFetchJob());
  }

  global static void runJob() {
    ApplicationSubmissionService.fetchApplydApplications();
  }
}