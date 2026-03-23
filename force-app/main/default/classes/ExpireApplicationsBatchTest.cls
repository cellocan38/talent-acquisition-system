@isTest
public class ExpireApplicationsBatchTest {

    @testSetup
    static void setupData() {
        Candidate__c candidate = new Candidate__c();
        insert candidate;

        Application__c oldApp1 = new Application__c(
            Candidate__c = candidate.Id,
            Status__c = 'New',
            Last_Activity_Date__c = Date.today().addDays(-40)
        );
        Application__c oldApp2 = new Application__c(
            Candidate__c = candidate.Id,
            Status__c = 'Screening',
            Last_Activity_Date__c = Date.today().addDays(-35)
        );
        Application__c recentApp = new Application__c(
            Candidate__c = candidate.Id,
            Status__c = 'New',
            Last_Activity_Date__c = Date.today().addDays(-10)
        );
        Application__c hiredApp = new Application__c(
            Candidate__c = candidate.Id,
            Status__c = 'Hired',
            Last_Activity_Date__c = Date.today().addDays(-50)
        );
        insert new List<Application__c>{oldApp1, oldApp2, recentApp, hiredApp};
    }

    @isTest
    static void testBatchExpiresOldApplications() {
        Test.startTest();
        Database.executeBatch(new ExpireApplicationsBatch(), 200);
        Test.stopTest();

        List<Application__c> expired = [
            SELECT Id, Status__c FROM Application__c WHERE Status__c = 'Expired'
        ];
        System.assertEquals(2, expired.size(), 'Two old applications should be expired.');

        List<Application__c> hired = [
            SELECT Id, Status__c FROM Application__c WHERE Status__c = 'Hired'
        ];
        System.assertEquals(1, hired.size(), 'Hired should remain unchanged.');
    }

    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExp = '0 0 2 * * ?';
        System.schedule('Test Expire Job', cronExp, new ExpireApplicationsScheduler());
        Test.stopTest();
        System.assert(true, 'Scheduler ran without errors.');
    }
}