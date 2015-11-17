/**
* \arg ClassName        : SL_ManageContactAddress
* \arg JIRATicket       : AMSEC-292, 293
* \arg CreatedOn        : 21/MAY/2015
* \arg LastModifiedOn   : 22/MAY/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Lodhi
* \arg Description      : Controller class for SL_ManageContactAddress page.
*/
public with sharing class SL_ManageContactAddress 
{
    /* Start - Variables */
    public List<contactBusinessWrapper> lstContactWrapper   {   get;set;    }
    public Account objAccount                               {   get;set;    }
    public Id objectId                                      {   get;set;    }
    public String strObjectName;
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageContactAddress()
    {
        /* Start - variable initialization*/
        strObjectName = ''; 
	    objAccount = new Account();
	    lstContactWrapper = new List<contactBusinessWrapper>();
        /* End - variable initialization*/
        
        objectId = Apexpages.currentPage().getParameters().containsKey('Id') ? Apexpages.currentPage().getParameters().get('Id') : null;
	    
	    if(objectId != null)
	    {
    		strObjectName = (objectId.getSobjectType() == Account.getSobjectType())
    		                 ? 'Account' : 'Contact';
    		                 
            lstContactWrapper = fetchRecords(strObjectName, objectId);		                 
	    }
    }
    /* End - Constructor */
    
    /*
        * MethodName	: initialization()
        * param			: NA
        * Description	: This method is used for initialize the variables. 
 	*/
	private void initialization()
	{
	    strObjectName = ''; 
	    objAccount = new Account();
	    lstContactWrapper = new List<contactBusinessWrapper>();
	}
	/* End */
	
	/* Start - Contact wrapper class */
	public class contactBusinessWrapper
	{
	    public Sobject sObj                 {   get;set;    }
	    public String strBusinessAddType    {   get;set;    }
	    
	    public contactBusinessWrapper(Sobject sObj)
	    {
	        this.sObj = sObj;
	        this.strBusinessAddType = '';
	    }
	}
	/* End - Contact wrapper class */
	
	/*
        * MethodName	: getSobjectRecords()
        * param			: Object fields, where clause and object id
        * Description	: This method is used to fetch the sobject records based on the given parameters. 
 	*/
 	private List<Sobject> getSobjectRecords(String strFielAPIs, String strWhereClause, Id objectId)
 	{
 	    return Database.query('SELECT '+ strFielAPIs + strWhereClause + '\'' + objectId +'\'');
 	}
 	/* End */
 	
 	/*
        * MethodName	: getBusinessOptions()
        * param			: NA
        * Description	: This method is used to fetch the business address options. 
 	*/
 	public List<Selectoption> getBusinessOptions()
 	{
 	    return new List<Selectoption>{new Selectoption('business1','Business1'), new Selectoption('business2','Business2')};
 	}
 	/* End */
	
	/*
        * MethodName	: fetchRecords()
        * param			: object name and object id
        * Description	: This method is used to fetch the account and contact record to manage contact addresses. 
 	*/
 	private List<contactBusinessWrapper> fetchRecords(String strObjectName, Id objectId)
 	{
 	    String strAccountId = null;
 	    String strWhereClauseContact = '';
 	    String strWhereClauseAccount = ' FROM Account WHERE Id = ';
 	    List<contactBusinessWrapper> lstContactWrapper = new List<contactBusinessWrapper>();
 	    
 	    String strAccountFields = 'Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet,' +
 	                              ' IsPersonAccount, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry ';
        String strContactFields = 'Id, Name, AccountId, MailingCity, MailingStreet, MailingState, MailingPostalCode, MailingCountry '; 	                              
 	    
 	    if(strObjectName == 'Account')
 	    {
 	        strWhereClauseContact = ' FROM Contact WHERE AccountId = ';
 	        List<Account> lstAccount = getSobjectRecords(strAccountFields, strWhereClauseAccount, objectId);
            
            if(!lstAccount.isEmpty())
            {
                objAccount = lstAccount[0];
                strAccountId = objAccount.Id;
                for(Sobject sObj : getSobjectRecords(strContactFields, strWhereClauseContact, strAccountId))  
                {
                    lstContactWrapper.add(new contactBusinessWrapper(sObj));
                }
            }    
 	    }
 	    
 	    else
 	    {
 	        strWhereClauseContact = ' FROM Contact WHERE Id = ';
 	        
 	        List<Contact> lstContact = getSobjectRecords(strContactFields, strWhereClauseContact, objectId);
 	        if(!lstContact.isEmpty())
 	        {
 	            if(lstContact[0].AccountId != null)
 	                strAccountId = lstContact[0].AccountId;
 	            else 
 	                return lstContactWrapper;
                lstContactWrapper.add(new contactBusinessWrapper(lstContact[0]));
 	        }
 	        
 	        List<Account> lstAccount = getSobjectRecords(strAccountFields, strWhereClauseAccount, strAccountId);
            if(!lstAccount.isEmpty())
                objAccount = lstAccount[0];
 	    }
 	    return lstContactWrapper;
 	}
 	/* End */
 	
 	/*
        * MethodName	: save()
        * param			: NA
        * Description	: This method is used to update the business addresses on the contact records. 
 	*/
 	public void save()
 	{
 	    List<Contact> lstContactToUpdate = new List<Contact>();
 	    
 	    //Iterating on list of contact wrapper to overwrite the business address with the seleceted Account business address.
 	    for(contactBusinessWrapper objWrapper : lstContactWrapper)
 	    {
 	        if(objWrapper.strBusinessAddType == 'business1')
 	            lstContactToUpdate.add(new Contact(Id = (Id)objWrapper.sObj.get('Id'), MailingCity = objAccount.BillingCity, 
 	                                               MailingStreet = objAccount.BillingStreet, MailingState = objAccount.BillingState, 
 	                                               MailingPostalCode = objAccount.BillingPostalCode, MailingCountry = objAccount.BillingCountry));
 	        
 	        if(objWrapper.strBusinessAddType == 'business2')
 	            lstContactToUpdate.add(new Contact(Id = (Id)objWrapper.sObj.get('Id'), MailingCity = objAccount.ShippingCity, 
 	                                               MailingStreet = objAccount.ShippingStreet, MailingState = objAccount.ShippingState, 
 	                                               MailingPostalCode = objAccount.ShippingPostalCode, MailingCountry = objAccount.ShippingCountry));
 	    }
 	    update lstContactToUpdate;
 	}
	/* End */
}
/* End */