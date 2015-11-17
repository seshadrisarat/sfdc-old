public class AuthenticateServiceHTTP 
{
    public static testMethod void TestHarness()
    {
        String sTestString;
        String sTestSessionId = 'userLoggedIn=rt1cgda1hjjzaavmn0itnd30|10/21/2008 12:41:58 PM|211713; path=/machineIdCookie=879392803; expires=Sun, 19-Apr-2009 16:21:57 GMT; path=/ASP.NET_SessionId=rt1cgda1hjjzaavmn0itnd30; path=/; HttpOnly';

        AuthenticateServiceHTTP c = new AuthenticateServiceHTTP();
        
        String testString = c.LoginOrRetrieveSession();
    }
    
    public CapitalIQOrganization__c getOrgInfo()
    {
        return [Select org.Username__c, org.Password__c, org.WebServiceUrl__c
                From CapitalIQOrganization__c org LIMIT 1];
    }
	
    public String LoginOrRetrieveSession() 
    {
        CapitalIQOrganization__c myOrg;
        
        if(Session.get(Session.CapitalIQSession) != null)
        {       
        	return String.valueOf(Session.get(Session.CapitalIQSession));
        }
        
        try
        {
            myOrg = getOrgInfo();
        }
        catch(Exception e)
        {
            System.Debug('@@@ AuthenticateServiceHTTP.Login()--> GetOrgInfo() threw : ' + e);
        }
        
        String url;
        if(myOrg == null)
        { 
        	return null;
        }
        url= myOrg.WebServiceUrl__c;
        
        if(!url.endsWith('/'))
        {
            url = url + '/';
        }
        
        Authenticator.AuthenticateServiceSoap http = new Authenticator.AuthenticateServiceSoap();
        http.inputHttpHeaders_x = new Map<String,String>();
        http.inputHttpHeaders_x.put('Accept-Encoding', 'gzip, deflate');
        http.outputHttpHeaders_x = new Map<String, String>();
        
        Boolean b = http.Login(myOrg.Username__c, myOrg.Password__c);
        Session.Put(Session.CapitalIQSession, http.outputHttpHeaders_x.get('Set-Cookie'));
        
        return String.valueOf(Session.Get(Session.CapitalIQSession));
    }
}