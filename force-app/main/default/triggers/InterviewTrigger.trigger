trigger InterviewTrigger on Interview__c (before insert, before update) {
    InterviewTriggerHandler.handleConflictCheck(Trigger.new);
}