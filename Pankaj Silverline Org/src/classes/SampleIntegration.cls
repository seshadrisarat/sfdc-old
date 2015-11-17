public class SampleIntegration
{
    public static void integration()
    {
        HttpRequest obj = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String username = 'pankaj.ganwani@trekbin.forum';
        String pwd = 'Pankaj123@';
        String reqBody = 'grant_type=password&client_id=3MVG9ZL0ppGP5UrDSUSAvgS2A4A1na8ggYshVrJAdM_wuHqvf0VYg4pCB9alTxKKqwiQIQRtZgMfXCu9kO0v0&client_secret=661274095057800454&username='+username+'&password='+pwd;
        obj.setMethod('POST');
        obj.setEndPoint('https://login.salesforce.com/services/oauth2/token');
        obj.setBody(reqBody);
        res = http.send(obj);
        OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
        
        Http h1 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer '+objAuthenticationInfo.access_token);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setMethod('DELETE');
        String strName = 'Test Pankaj 3';
        req1.setEndpoint('https://ap2.salesforce.com/services/apexrest/createAccount?cName='+EncodingUtil.urlEncode(strName, 'UTF-8'));//URL will be your Salesforce REST API end point where you will do POST,PUT,DELETE orGET
        system.debug('======req1========'+req1);
        HttpResponse res1 = h1.send(req1);
        system.debug('==========res1============'+res1.getBody());
    }
}