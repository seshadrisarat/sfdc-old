public class BitbucketCommits {
    public integer pagelen;
    public list<BBCommit> values;
    public integer page;
    public String next;
    
    public class BBCommit {
        public String hash;
        public String message;
        public Author author;
    }
    
    public class Author {
        public String raw;
    }
    
    public void getCommits(string Project, string endpoint) {
        HttpResponse res;
        BitbucketRequest br = new BitbucketRequest();
        br.Project = Project;
        br.TEST_FLAG = 1;
        br.endpoint = endpoint;
        br.sendrequest();
        try {
            res = br.res;
            system.debug('-----res.getBody()='+res.getBody());
            BitbucketCommits obj = (BitbucketCommits) System.JSON.deserialize(res.getBody(), BitbucketCommits.class);
            system.debug('-----obj='+obj);
            List<SF_Commit__c> lstCommits = new List<SF_Commit__c>();
            SF_Commit__c curCommit;
            set<string> setIssueNames = new set<string>();
            map<string,Id> mapIssueName2Ids = new map<string,Id>();
            if (obj!=null) {
                for (BBCommit cmt:obj.values) {
                    curCommit = new SF_Commit__c();
                    curCommit.Hash__c = cmt.hash;
                    curCommit.Message__c = cmt.message.left(254);
                    curCommit.Author__c = cmt.author.raw;
                    setIssueNames.add(BitbucketMethods.getIssueName(curCommit.Message__c));
                    lstCommits.add(curCommit);
                }
            }
            
            for (SF_Issue__c item:[Select Id, Name FROM SF_Issue__c WHERE Name IN :setIssueNames])
            {
                mapIssueName2Ids.put(item.Name, item.Id);
            }
            
            for (SF_Commit__c item:lstCommits)
            {
                if (mapIssueName2Ids.containsKey(item.Message__c)) {
                    item.SF_Issue__c = mapIssueName2Ids.get(item.Message__c);
                }
            }
            
            if (lstCommits.size()>0) upsert lstCommits Hash__c;
            BitbucketRequest.nextendpoint = obj.next;
        
        } catch (System.CalloutException e) {
            System.debug(res.toString());
        }
    }

    public static void createSFCommits( String sProject, String sEndpoint ) {
        BitBucketWrappers.HTTP_Response oResponse;
        try {
            if ( Test.isRunningTest() ) {
                oResponse = new BitBucketWrappers.HTTP_Response();
                oResponse.values = BitbucketMethodsTest.createHttpCommits();
            } else {
                oResponse = ( BitBucketWrappers.HTTP_Response ) System.JSON.deserialize( BitBucketWrappers.prepareJSON(new BitbucketRequest( sProject, 1, sEndpoint ).sendRequest().getBody()), BitBucketWrappers.HTTP_Response.class );
            }

            BitbucketMethods.createRecords( oResponse.values );
            BitbucketRequest.nextendpoint = oResponse.next;
        } catch ( Exception e ) {
            System.debug(
                LoggingLevel.ERROR, '### Exception: ' + e.getMessage() + '; line: ' + e.getLineNumber() +
                '\n### oResponse : ' + oResponse
            );
        }
    }
}