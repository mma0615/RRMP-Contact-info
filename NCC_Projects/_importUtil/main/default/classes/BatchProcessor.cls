global class BatchProcessor implements Database.batchable<SObject> 
{
    SObject[] source;
    
    global BatchProcessor(SObject[] source) 
    {
        this.source = source;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) 
    {
        BatchSObjectFeeder bf = new BatchSObjectFeeder(source);
        return bf;
    }
    
    global void execute(Database.BatchableContext bc, SObject[] scope) 
    {
        insert scope;
    }
    
    global void finish(Database.BatchableContext bc) 
    {
    
    }
}