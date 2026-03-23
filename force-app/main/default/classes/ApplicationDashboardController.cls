public with sharing class ApplicationDashboardController {

    @AuraEnabled(cacheable=true)
    public static List<Application__c> getApplications(String statusFilter) {

        String query = 'SELECT Id, Name, Status__c, Applied_Date__c, ' +
                       'Candidate__r.First_Name__c, Candidate__r.Last_Name__c, ' +
                       'Job_Position__r.Title__c, Job_Position__r.Department__c ' +
                       'FROM Application__c ';

        if (String.isNotBlank(statusFilter) && statusFilter != 'All') {
            query += 'WHERE Status__c = \'' + statusFilter + '\' ';
        }

        query += 'ORDER BY Applied_Date__c DESC LIMIT 100';
        return Database.query(query);
    }

    @AuraEnabled
    public static void updateApplicationStatus(Id appId, String newStatus) {
        update new Application__c(Id = appId, Status__c = newStatus);
    }
}