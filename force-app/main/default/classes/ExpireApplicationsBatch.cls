public class ExpireApplicationsBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutoffDate = Date.today().addDays(-30);
        return Database.getQueryLocator([
            SELECT Id, Status__c, Last_Activity_Date__c
            FROM Application__c
            WHERE Status__c NOT IN ('Hired', 'Rejected', 'Expired', 'Withdrawn')
            AND Last_Activity_Date__c <= :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Application__c> applications) {
        for (Application__c app : applications) {
            app.Status__c = 'Expired';
        }
        update applications;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('ExpireApplicationsBatch completed.');
    }
}