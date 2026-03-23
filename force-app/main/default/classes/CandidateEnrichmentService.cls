public class CandidateEnrichmentService {

    @future(callout=true)
    public static void enrichCandidate(Id candidateId, String countryName) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://restcountries.com/v3.1/name/' 
            + EncodingUtil.urlEncode(countryName, 'UTF-8'));
        req.setMethod('GET');
        req.setTimeout(10000);

        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                List<Object> countries = 
                    (List<Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> country = 
                    (Map<String, Object>) countries[0];
                Map<String, Object> name = 
                    (Map<String, Object>) country.get('name');

                String officialName = (String) name.get('official');
                String region = (String) country.get('region');

                update new Candidate__c(
                    Id = candidateId,
                    Current_Company__c = officialName + ' (' + region + ')'
                );
            }
        } catch (Exception e) {
            System.debug('Callout error: ' + e.getMessage());
        }
    }
}