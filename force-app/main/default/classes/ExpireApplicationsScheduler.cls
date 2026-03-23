public class ExpireApplicationsScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        ExpireApplicationsBatch batch = new ExpireApplicationsBatch();
        Database.executeBatch(batch, 200);
    }
}