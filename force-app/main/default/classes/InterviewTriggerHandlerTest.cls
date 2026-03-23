@isTest
public class InterviewTriggerHandlerTest {

    @testSetup
    static void setupData() {
        Candidate__c candidate = new Candidate__c();
        insert candidate;

        Application__c app = new Application__c(
            Candidate__c = candidate.Id
        );
        insert app;

        Interview__c existingInterview = new Interview__c(
            Application__c = app.Id,
            Scheduled_DateTime__c = System.now().addDays(1)
        );
        insert existingInterview;
    }

    @isTest
    static void testConflictInterviewBlocked() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Interview__c existingInterview = [
            SELECT Id, Scheduled_DateTime__c
            FROM Interview__c
            LIMIT 1
        ];

        Interview__c conflictingInterview = new Interview__c(
            Application__c = app.Id,
            Scheduled_DateTime__c = existingInterview.Scheduled_DateTime__c.addMinutes(30)
        );

        Test.startTest();
        Database.SaveResult sr = Database.insert(conflictingInterview, false);
        Test.stopTest();

        System.assertEquals(false, sr.isSuccess(), 'Insert should fail due to time conflict.');
        System.assert(
            sr.getErrors()[0].getMessage().contains('A conflicting interview exists within 1 hour'),
            'Expected conflict error message.'
        );
    }

    @isTest
    static void testNonConflictInterviewAllowed() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Interview__c existingInterview = [
            SELECT Id, Scheduled_DateTime__c
            FROM Interview__c
            LIMIT 1
        ];

        Interview__c nonConflictingInterview = new Interview__c(
            Application__c = app.Id,
            Scheduled_DateTime__c = existingInterview.Scheduled_DateTime__c.addHours(2)
        );

        Test.startTest();
        insert nonConflictingInterview;
        Test.stopTest();

        System.assertNotEquals(null, nonConflictingInterview.Id, 'Insert should succeed when there is no conflict.');
    }
}