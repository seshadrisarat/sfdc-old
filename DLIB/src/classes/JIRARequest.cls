public class JIRARequest {
    public integer TEST_FLAG = 1; // for Issues
    public HttpRequest req;
    public HttpResponse res;
     
    public string fields = 'key,id,customfield_10233,description,summary,comment,timetracking,assignee,reporter,versions';
    public string jql = 'updated>-1d';
    public string maxResults = '1000';
    public string endpoint = '/search?fields=&maxResults=1000&jql=';
    public string endpointHost = 'https://silverlinetest.atlassian.net';
    public string password = '';
    public string username = '';
    public integer startAt = 0;
    public string JIRA_PREFIX = '/rest/api/2';

    public JiraIntegration__c cfg;
    
    public JIRARequest() {
        init();
        this.endpoint = '/search?fields='+fields+'&jql='+EncodingUtil.urlEncode(jql, 'UTF-8')+'&maxResults='+maxResults+'&startAt='+startAt;
    }

    public JIRARequest(string fields, string jql) {
        init();
        this.fields = fields;
        this.jql = jql + '';
        this.endpoint = '/search?fields='+fields+'&jql='+EncodingUtil.urlEncode(jql, 'UTF-8')+'&maxResults='+maxResults+'&startAt='+startAt;
    }

    public JIRARequest( String sJQL, Integer nMaxResults ) {
        init();
        this.jql = sJQL;
        this.maxResults = String.valueOf( nMaxResults );
        this.endpoint = '/search?fields=' + fields + '&jql=' + EncodingUtil.urlEncode( jql, 'UTF-8' ) + '&maxResults=' + maxResults + '&startAt=' + startAt;
    }

    public JIRARequest( String sJQL, Integer nMaxResults, Integer nStartAt ) {
        init();
        this.jql = sJQL;
        this.startAt = nStartAt;
        this.maxResults = String.valueOf( nMaxResults );
        this.endpoint = '/search?fields=' + fields + '&jql=' + EncodingUtil.urlEncode( jql, 'UTF-8' ) + '&maxResults=' + maxResults + '&startAt=' + startAt;
    }

    public JIRARequest( String sFields, String sJQL, Integer nMaxResults, Integer nStartAt ) {
        init();
        this.fields = sFields;
        this.jql = sJQL;
        this.startAt = nStartAt;
        this.maxResults = String.valueOf( nMaxResults );
        this.endpoint = '/search?fields=' + fields + '&jql=' + EncodingUtil.urlEncode( jql, 'UTF-8' ) + '&maxResults=' + maxResults + '&startAt=' + startAt;
    }

    /*public JIRARequest( String sFields, String sJQL, Integer nMaxResults, Integer nStartAt ) {
        this.endpointHost = 'https://silverline.jira.com';
        this.username = 'daniel';
        this.password = 'danforc3';

        this.fields = sFields;
        this.jql = sJQL;
        this.startAt = nStartAt;
        this.maxResults = nMaxResults + '';
        this.endpoint = '/search?fields=' + fields + '&jql=' + EncodingUtil.urlEncode( jql, 'UTF-8' ) + '&maxResults=' + maxResults + '&startAt=' + startAt;
    }*/
    
    public JIRARequest(string endpoint) {
        init();
        this.endpoint = endpoint;
    }
    
    public void init() {
        this.cfg = JiraIntegration__c.getInstance();
        this.endpointHost = cfg.endpointHost__c;
        this.jql = cfg.jql__c;
        this.fields = cfg.fields__c;
        this.maxResults = Integer.valueOf(cfg.maxResults__c) + '';
        this.startAt = Integer.valueOf(cfg.startAt__c);
        this.password = cfg.Password__c;
        this.username = 'sladmin';
        this.username = cfg.IntegrationUserName__c;
    }

    public HttpResponse sendrequest()
    {
        req = new HttpRequest();
        res = new HttpResponse();
        Http http = new Http();
 
        Blob headerValue = Blob.valueOf(username+':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        
     
        req.setMethod('GET');
        req.setEndpoint(endpointHost+JIRA_PREFIX+endpoint);
        system.debug(endpointHost+JIRA_PREFIX+endpoint);
        req.setTimeout(120000);
        if(!Test.isRunningTest()) res = http.send(req);
        else                      res = testResponse();
        return res;
    }
    
    public HttpResponse sendrequestPOST(string body)
    {
        req = new HttpRequest();
        res = new HttpResponse();
        Http http = new Http();
        
        //for test jira, but don't forget to check JIRAUSerName in Contacts
        /*endpointHost = 'https://silverlinetest.atlassian.net';
    	username = 'integration';
    	password = 'juliaforc3';
    	JIRA_PREFIX = '/rest/api/2';
		*/
    	
        Blob headerValue = Blob.valueOf(username+':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        //string newIssue = getTestJSONFromStaticResources('json_CreateIssueTest');
        //body = newIssue;
        system.debug('---------body='+body);
        if (body!='') {
            req.setBody(body);
        }
     
        req.setMethod('POST');
        req.setEndpoint(endpointHost+JIRA_PREFIX+endpoint);
        system.debug(endpointHost+JIRA_PREFIX+endpoint);
        req.setTimeout(120000);
        if(!Test.isRunningTest()) res = http.send(req);
        else                      res = testResponse();
        return res;
    }
    
    public Httpresponse testResponse()
    {
        String body='';
        
        if (TEST_FLAG==1) { // for Issues
            body = getTestJSONFromStaticResources('json_Issues');
        } else if (TEST_FLAG==2) { // for Worklogs
            body = getTestJSONFromStaticResources('json_Worklogs');
        } 
        
        Httpresponse resp = new Httpresponse();
        resp.setBody(body);
        return resp;
        
    }
    
    private static String getTestJSONFromStaticResources(String resource)
    {
        return [SELECT body, name from StaticResource where Name =:resource].body.toString();       
    }
    
}