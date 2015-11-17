/**
 * @ClassName    : SL_VCard 
 * @JIRATicket   : SOCINT-246
 * @CreatedOn    : 19/Nov/13
 * @ModifiedBy   : Sruti
 * @Description  : This is the class for Showing VCard
 */
 
 /**
 @ Sruti
 Percentage of best practices followed   : 100%
 Add a comment to this line
 No of SOQL queries used                 : 
 No of collections used                  : 
 Exception Handling implemented          : 
 Coding standards followed               : Yes
 Naming conventions followed             : Yes
 Third party integrations                : No
 Maximum of No of records tested with    : 
 Customer Approval                       : 
 Last Modified Date                      : 
 Approved by                             : 
 */
 
public with sharing class SL_VCard 
{
    public String email {get;set;} /// variable to store user's email id
    public String firstName {get;set;} /// variable to store user's first name
    public String homePhone {get;set;} /// variable to store user's home phone number
    public String lastName {get;set;} /// variable to store user's last name
    public String mobilePhone {get;set;} /// variable to store user's mobile phone number
    public String strPhoto {get;set;} /// variable to store user's photo
    public String prefix {get;set;} /// variable to store prefix
    public String title {get;set;} /// variable to store user's title
    public String website {get;set;} /// variable to store user's website
    public String workCity {get;set;} /// variable to store user's workcity
    public String workCountry {get;set;} /// variable to store user's work country
    public String workPhone {get;set;} /// variable to store user's work phone
    public String workPostalCode {get;set;} /// variable to store user's postal code
    public String workStateProvince {get;set;} /// variable to store user's state
    public String workStreet {get;set;} /// variable to store user's work street
    public String vcardName {get;set;} /// variable to store vcard name
    public String department {get;set;} /// variable to store user's department
    public String company {get;set;} /// variable to store user company name
    public String myOffices {get;set;} /// variable to store my offices
    public map<String, String> mapFieldSelection_ObjectField{get; set;} /// map to store field selection as key and object field as value
    
    /* Start : Constructor*/  
    public SL_VCard()
    {
    	mapFieldSelection_ObjectField = new map<String, String>();
		String photoURL='';
		String strUserId  = '';
		
		if(Apexpages.currentpage().getparameters().containsKey('id') && Apexpages.currentpage().getparameters().get('id') != null && Apexpages.currentpage().getparameters().get('id') != '')
		{
			strUserId = Apexpages.currentpage().getparameters().get('id');
		}
		else
		{
			strUserId = userinfo.getuserid();
		}
        List<User> lstUser = new List<User>();/// list to store user object
        
        lstUser =    [select FullPhotoUrl from User where Id=:strUserId limit 1];
        photoURL = lstUser[0].FullPhotoUrl;
        
        if(!test.isRunningTest())
        {
        	/// get the base64 of user profile picture
        	strPhoto = EncodingUtil.base64encode(new PageReference(photoURL).getContent());
        }
        
        /// form a query
       	String query = 'select ';
    	String str = 'Name, FirstName, LastName, CompanyName, Title, Phone, MobilePhone, Fax, Email, City, State, Country, Street, PostalCode, SmallPhotoUrl,Department,User_Offices__c ';
       	query +=  str + ' from User where Id =: strUserId';
       	
       	for(User u : database.query(query))
       	{
   			getUserVCF(u);
        	break;
   		}
   		
        vcardName = vcardName.replaceAll('#','_').replaceAll('\\\\;','_').replaceAll(' ', '_');
    }
    /* End : Constructor*/  
    
    /* @Name           - getUserVCF
       @Parameters     - User object 
       @Return Type    - void
       @Description    - Function to assign values to the variables used in the page
    */
    public void getUserVCF(User u)
    {
        email			   = (mapFieldSelection_ObjectField.containsKey('Email')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Email')))) : checkforNull(u.Email) ;
    	firstName		   = (mapFieldSelection_ObjectField.containsKey('First Name')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('First Name')))) : checkforNull(u.FirstName) ;
        homePhone		   = (mapFieldSelection_ObjectField.containsKey('Home Phone')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Home Phone')))) : '';
        lastName		   = (mapFieldSelection_ObjectField.containsKey('Last Name')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Last Name')))) : checkforNull(u.LastName) ;
        mobilePhone		   = (mapFieldSelection_ObjectField.containsKey('Mobile Phone')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Mobile Phone')))) : checkforNull(u.MobilePhone) ;
        title			   = (mapFieldSelection_ObjectField.containsKey('Title')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Title')))) : checkforNull(u.Title) ;
        website			   = (mapFieldSelection_ObjectField.containsKey('Website')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Website')))) : '' ;
    	workCity		   = (mapFieldSelection_ObjectField.containsKey('Work City')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Work City')))) : checkforNull(u.City) ;
    	workCountry		   = (mapFieldSelection_ObjectField.containsKey('Work Country')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Work Country')))) : checkforNull(u.Country) ;
        workPhone		   = (mapFieldSelection_ObjectField.containsKey('Work Phone')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Work Phone')))) : checkforNull(u.Phone) ;
    	workPostalCode	   = (mapFieldSelection_ObjectField.containsKey('Work Postal Code')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Work Postal Code')))) : checkforNull(u.PostalCode) ;
    	workStateProvince  = (mapFieldSelection_ObjectField.containsKey('Work State Province')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Work State Province')))) : checkforNull(u.State) ;
        workStreet		   = (mapFieldSelection_ObjectField.containsKey('Work Street')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Work Street')))) : checkforNull(u.Street) ;
        vcardName		   = (mapFieldSelection_ObjectField.containsKey('vcardName')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('vcardName')))) : checkforNull(u.Name);
        prefix			   = (mapFieldSelection_ObjectField.containsKey('Prefix')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Prefix')))) : '' ;
    	department		   = (mapFieldSelection_ObjectField.containsKey('Department')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('Department')))) : checkforNull(u.Department);
    	company		  	   = (mapFieldSelection_ObjectField.containsKey('CompanyName')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('CompanyName')))) : checkforNull(u.CompanyName);
    	myOffices		   = (mapFieldSelection_ObjectField.containsKey('User_Offices__c')) ? checkforNull(String.valueOf(u.get(mapFieldSelection_ObjectField.get('User_Offices__c')))) : checkforNull(u.User_Offices__c);
    }
    
    /* @Name           - checkforNull
       @Parameters     - User field 
       @Return Type    - String
       @Description    - Function to check null values
    */
    public string checkforNull(string str)
    {
        List<String> lstStr;
        String str1 = (str != null) ? str : '';
        str1 = str1.replaceAll('\\\\','\\\\' + '\\\\').replaceAll('\r\n','\n').replaceAll('\n','\\\\n').replaceAll(';' , '\\\\;');
        return str1;
    }
}