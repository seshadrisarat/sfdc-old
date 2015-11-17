public with sharing class SL_SFDCEnergyConnectorController {

	public string response {get; set;}
	public string echo {get; set;}
	
	String username = 'E3SyncUser';
	//String password = 'naBLOFF6'; //dev
	String password = 'fejEAB*29#'; //prod
	
	//private string echo;
	//private string response;l
	public SL_SFDCEnergyConnectorController() {
		echo = 'Echo test string';
	}
	public void callout()
	{


		password = 'naBLOFF6'; //dev

		Http h = new http();
		HttpRequest req = new HttpRequest();
  		//Set auth header
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'BASIC ' +
		EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);	

		req.setEndpoint('http://ec2-54-68-184-10.us-west-2.compute.amazonaws.com/Services/E3Sync.svc/EchoTest?j=' + echo);
		req.setMethod('GET');
		HttpResponse res = h.send(req); 
		response = res.getBody();
	}
	
	public void getVersion()
	{
		
		Http h = new http();
		HttpRequest req = new HttpRequest();
	
		String password = 'fejEAB*29#'; //prod
		
  		//Set auth header
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'BASIC ' +
		EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);			
		
		//req.setEndpoint('http://ec2-54-68-184-10.us-west-2.compute.amazonaws.com/Services/E3Sync.svc/GetVersion');
		req.setEndpoint('https://sf.petroheat.com/Services/E3Sync.svc/GetVersion');
		req.setMethod('GET'); 
		HttpResponse res = h.send(req); 
		response = res.getBody();
	}
	
	public void testConnectivity()
	{
		
		Http h = new http();
		HttpRequest req = new HttpRequest();
	
		String password = 'fejEAB*29#'; //prod
		
  		//Set auth header
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'BASIC ' +
		EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);			
		
		//req.setEndpoint('http://ec2-54-68-184-10.us-west-2.compute.amazonaws.com/Services/E3Sync.svc/GetVersion');
		req.setEndpoint('https://sf.petroheat.com/Services/E3Sync.svc/TestConnectivity?cid=10');
		req.setMethod('GET');
		HttpResponse res = h.send(req); 
		response = res.getBody();
	}



}