global class UpdateTokenCodeBatch_Schedule implements Schedulable{
    global void execute(SchedulableContext sc) {
       UpdateTokenCodeBatch pop = new UpdateTokenCodeBatch();
        Database.executeBatch(pop);
    }
}