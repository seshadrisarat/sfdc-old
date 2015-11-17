public class Session 
{
	public static testMethod void TestHarness()
	{
		Session.Put('test', 'test');
		Session.Get('test');	
	}
	
	public static String CapitalIQSession = 'CapitalIQ_Session';
	
	private static final Map<String, Object> session = new Map<String, Object>();
	
	public static Account Account { get; set; }
	public static Contact Contact { get; set; }
	
	public static Object Get(String key)
	{
		System.debug('Session : Getting Entry at ' + key +  ' for Session ' + UserInfo.getSessionId());
		return session.get(key);
	}
	
	public static void Put(String key, Object value)
	{
		System.debug('Session : Putting Entry ' + value + ' at ' + key + ' for Session ' + UserInfo.getSessionId());
		session.put(key, value);
	}
	
	public static String getASPNETSessionId()
	{
		if(Session.Get(CapitalIQSession) == null)
		{
			AuthenticateServiceHTTP auth = new AuthenticateServiceHTTP();
			String myASPNetSessionId = auth.LoginOrRetrieveSession(); //this won't actually do a login unless its a fresh hit.
			Session.Put(CapitalIQSession, myASPNetSessionId);
		}
		return String.valueOf(Session.Get(CapitalIQSession));
	}
}