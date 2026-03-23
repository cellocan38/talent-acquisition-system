public class InterviewTriggerHandler {

    public static void handleConflictCheck(List<Interview__c> newInterviews) {

        Set<Id> applicationIds = new Set<Id>();

        for (Interview__c interview : newInterviews) {
            if (interview.Application__c != null) {
                applicationIds.add(interview.Application__c);
            }
        }

        List<Interview__c> existingInterviews = [
            SELECT Id, Application__c, Scheduled_DateTime__c
            FROM Interview__c
            WHERE Application__c IN :applicationIds
        ];

        Map<Id, List<Interview__c>> existingMap = new Map<Id, List<Interview__c>>();

        for (Interview__c ei : existingInterviews) {
            if (!existingMap.containsKey(ei.Application__c)) {
                existingMap.put(ei.Application__c, new List<Interview__c>());
            }
            existingMap.get(ei.Application__c).add(ei);
        }

        for (Interview__c newInt : newInterviews) {
            if (newInt.Scheduled_DateTime__c == null) {
                continue;
            }

            List<Interview__c> existing = existingMap.get(newInt.Application__c);
            if (existing == null) {
                continue;
            }

            for (Interview__c ei : existing) {
                Long newTime = newInt.Scheduled_DateTime__c.getTime();
                Long existTime = ei.Scheduled_DateTime__c.getTime();
                Long diff = Math.abs(newTime - existTime);
                Long oneHourMs = 3600000L;

                if (diff < oneHourMs && newInt.Id != ei.Id) {
                    newInt.addError(
                        'A conflicting interview exists within 1 hour of this time. Please choose a different time slot.'
                    );
                    break;
                }
            }
        }
    }
}