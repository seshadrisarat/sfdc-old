public class Pusher {
    public class PusherException extends Exception {  }

    String authKey;
    String authSecret;
    String appid;
    String apiURL;
    private Http http;
    
	public Pusher()
	{
		Pusher_Settings__c p=Pusher_Settings__c.getInstance();
		authKey=p.Auth_Key__c;
		authSecret=p.Auth_Secret__c;
		appid=p.App_ID__c;
		apiURL=p.API_URL__c;
	}
	
    public Pusher(String authKey, String authSecret, String appid) {
        this.authKey = authKey;
        this.authSecret = authSecret;
        this.appid = appid;
        this.apiURL='https://api.pusherapp.com';
    }

    public void push(String channel, String name, String message) 
    {
        callOut(buildRequest(channel, name, message));
    }
    
    public HttpRequest buildRequest(String channel, String name, String message)
    {
    	String authTimestamp = String.valueOf(Datetime.now().getTime() / 1000);
        String authVersion = '1.0';
        String bodyMd5 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',
          Blob.valueOf(message)));
        String path = '/apps/'+appid+'/channels/'+channel+'/events';

        String stringToSign = 'POST\n'+path+'\nauth_key='+authKey+
            '&auth_timestamp='+authTimestamp+'&auth_version='+authVersion+
            '&body_md5='+bodyMd5+'&name='+name;

        String authSignature =
            EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256',
              Blob.valueOf(stringToSign), Blob.valueOf(authSecret)));

        String endpoint = apiURL+path+
            '?auth_key='+authKey+
            '&auth_timestamp='+authTimestamp+
            '&auth_version='+authVersion+
            '&body_md5='+bodyMd5+
            '&name='+name+
            '&auth_signature='+authSignature;

        HttpRequest req = new HttpRequest(); 

        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody(message); 

        return req;
    }
    
    public void callOut(HttpRequest req)
    {
    	Http http = new Http();
    	HTTPResponse res = http.send(req);
    	
    	if (res.getStatusCode() != 202)  throw new PusherException(res.getStatusCode() + ' ' + res.getStatus());
    }
    
    static testMethod void test()
    {
    	Pusher p=new Pusher();
    	p=new Pusher('0687037a693c89393237', '3530b3d9f1dfe0f7c0a1', '10661');
    	p.buildRequest('admin_channel', 'update', 'Hello from Apex');
    	p.push('admin_channel', 'update', 'Hello from Apex');
    }
}