@isTest
public class CandidateEnrichmentServiceTest {

    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('[{"name":{"official":"United States of America"},"region":"Americas"}]');
            return res;
        }
    }

    @isTest
    static void testEnrichCandidate() {
        Candidate__c candidate = new Candidate__c();
        insert candidate;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        CandidateEnrichmentService.enrichCandidate(candidate.Id, 'United States');
        Test.stopTest();

        Candidate__c updated = [
            SELECT Current_Company__c FROM Candidate__c WHERE Id = :candidate.Id
        ];
        System.assert(
            updated.Current_Company__c.contains('United States of America'),
            'Current Company should be updated with API data.'
        );
    }
}