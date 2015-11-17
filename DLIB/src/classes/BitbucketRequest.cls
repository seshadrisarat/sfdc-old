public class BitbucketRequest {
	public integer TEST_FLAG = 1; // for Commits
	public HttpRequest req;
    public HttpResponse res;
    public string Project = 'slff';
    
    public string endpoint = null;
    
    public static string nextendpoint = null;
    public static integer statusCode = null;  
    
  	/* SANDBOX */ 
    private static string BITBUCKET_ENDPOINT = 'https://bitbucket.org';
	private static string BITBUCKET_USERNAME = '';
	private static string BITBUCKET_PASSWORD = '';
	private static string BITBUCKET_PREFIX = '/!api/2.0/repositories/silverline';
    
    public BitbucketRequest() { init(); }

    public BitbucketRequest( String sProject, Integer nTestFlag, String sEndpoint ) {
        this.Project = sProject;
        this.TEST_FLAG = nTestFlag;
        this.endpoint = sEndpoint;
        init();
    }
    
    private void init() {
        JiraIntegration__c cfg = JiraIntegration__c.getInstance();
        BITBUCKET_USERNAME = cfg.BitbucketUserName__c;
        BITBUCKET_PASSWORD = cfg.BitbucketPassword__c;
    }

    public HttpResponse sendrequest()
    {
        req = new HttpRequest();
        res = new HttpResponse();
        Http http = new Http();
        
        if (endpoint==null) endpoint = BITBUCKET_ENDPOINT+BITBUCKET_PREFIX+'/'+Project+'/commits/?pagelen=100';
 
        Blob headerValue = Blob.valueOf(BITBUCKET_USERNAME+':'+BITBUCKET_PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
 		res = http.send(req);
 		statusCode = res.getStatusCode();
        return res;
    }
}