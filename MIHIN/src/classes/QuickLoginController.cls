public class QuickLoginController 
{
    public String password { get; set; }

    public PageReference login() 
    {
        String username = System.currentPageReference().getParameters().get('un');
        password = System.currentPageReference().getParameters().get('pss');
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String strSiteUrl = System.currentPageReference().getParameters().get('siteUrl');
        strSiteUrl = strSiteUrl.substring(0, (strSiteUrl.length() - 1));// removing last forward slash from site url
        if(strSiteUrl.contains('https'))
        	strSiteUrl = strSiteUrl.replace('https', 'http');//replacing http with https
        	
        if(startUrl == '' || startUrl == null) 
        	startUrl = '/home/home.jsp';// + Schema.SObjectType.Account.getkeyprefix() + '/o';
        
        Blob key = Blob.valueOf('1234567890123456');
        //Blob encryptedData = EncodingUtil.base64Decode(password);
        if (password != null)
            password = Crypto.decryptWithManagedIV('AES128', key, EncodingUtil.base64Decode(password)).toString();
        
        PageReference pr = Site.login(username, password, startUrl);
        System.debug('========pr========'+pr);
        
        if (pr == null)
        {
            PageReference pageRef = new PageReference(strSiteUrl);
            pageRef.getParameters().put('err', username);
            pageRef.getParameters().put('startURL', startUrl);
            return pageRef;
        }
        return pr;
    }
    
    @IsTest(SeeAllData=true) 
    public static void testQuickLoginController () 
    {
	      System.currentPageReference().getParameters().put('siteUrl','http://full-mihin.cs11.force.com/eTHIN');
	      QuickLoginController controller = new QuickLoginController ();
	      controller.login();
  	}

}