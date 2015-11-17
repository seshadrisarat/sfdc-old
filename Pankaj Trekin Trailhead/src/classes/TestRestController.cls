@RestResource(urlMapping = '/createAccount/*')
global with sharing class TestRestController 
{
	@HttpPost
	global static Id createAccountRecord(String actName)
	{
		Account objAccount = new Account(Name = actName);
		insert objAccount;
		return objAccount.Id;		
	}
	
	@HttpGet
	global static List<Account> getAccountDetails()
	{
		return [select Name from Account where Name =: 'Test Account 2'];
	}
	
	@HttpDelete
	global static void delAccounts()
	{
		delete [select Id from Account where Name =: RestContext.request.params.get('cName')];
		Restresponse res = RestContext.response;
		res.responseBody = Blob.valueOf('{"Status":"Sucsess"}');
	}
	
	@HttpPut
	global static String createAttachment()
	{
		RestRequest req = RestContext.request;
		system.debug('=======headers==========='+req.headers);
		system.debug('=======httpMethod==========='+req.httpMethod);
		system.debug('=======params==========='+req.params);
		system.debug('=======remoteaddress==========='+req.remoteAddress);
		system.debug('=======body==========='+String.valueOf(req.requestBody));
		system.debug('=======request uri==========='+req.requestURI);
		system.debug('=======resource path==========='+req.resourcePath);
		//insert new Attachment(ParentId = Id.valueOf(req.requestURI.substring(req.requestURI.lastIndexOf('/')+1)), Name='Test.png', Body = req.requestBody);
		return 'Created';
	}
	
	@HttpPatch
	global static void updateAccount()
	{
		RestRequest req = RestContext.request;
		update new Account(Id = Id.valueOf(req.requestURI.substring(req.requestURI.lastIndexOf('/')+1)),Rating = 'Warm');
	}
}