/**
* \arg \b ClassName      : SL_ShowListsNameWithHyperlink
* \arg \b JIRATicket     : WP-99
* \arg \b CreatedOn      : 15/07/2013
* \arg \b ModifiedBy     : -
* \arg \b Description    : This is the controller class for SL_ShowListsNameWithHyperlink page. This class will take Id from page url and identify the object.
						   If object is company/contact type than it will fetch the data from Lists field on that object and than it will show that lists name in hyperlink. 
				 		     
*/
public with sharing class SL_ShowListsNameWithHyperlink 
{
	private Schema.Sobjecttype sObjectType;//This variable is use to store sObject type.
	private Set<Id> setCompanyListId;//This set is use to store company List Ids
	
	public List<String> lstListsNames				{get;set;}//This is to store all Lists names
	public Id sObjectId								{get;set;}//This variable is use to store sObject Id
	public String strListsNames						{get;set;}//This will store all selected lists names to show on company/contact detail page.
	
	/* Main constructor*/
	public SL_ShowListsNameWithHyperlink(ApexPages.StandardController sc)
	{
		/*This is to initalize all members of main class.*/
		initialize();
		
		sObjectId = Apexpages.currentPage().getParameters().get('id');//To store id from page url.
		
        /* If Id is not null*/
        if(sObjectId !=null) 
		{
			sObjectType = sObjectId.getSObjectType();
		}
		
		/*This is to query all contact list members where company/contact Id is equals to sObject Id.*/                            
		for(Company_List_Member__c objCompanyListMember : [	Select Id, Name, Company_List__c
	                                                       	From Company_List_Member__c
	                                                       	Where (Company__c =: sObjectId OR Contact__c =: sObjectId) 
	                                                      ])
        {
        	 setCompanyListId.add(objCompanyListMember.Company_List__c);
        }	
        
        /*This is to query all List member associated with the contact/company list member*/
        for( Company_List__c objCompanyList : [ Select Id,Name
                                                From Company_List__c
                                                Where Id IN:setCompanyListId 
                                                order by Name 
                                               ] ) 
        {  
        	if(strListsNames == null || strListsNames == '')
        	{
        		strListsNames = objCompanyList.Name;
        	}
        	else
        	{
        		strListsNames = strListsNames + ', '+objCompanyList.Name;
        	}
        	
        }
        
        /*If List is empty than checking it's sObject type and assigning default values*/
        if(strListsNames == null || strListsNames == '')
        {    
        	/*If sObject type is Account*/
        	system.debug('--------------String.valueOf(sObjectType)------'+String.valueOf(sObjectType));
        	if(String.valueOf(sObjectType) == 'Account')
        	{
        		strListsNames = 'No Company List Selected';
        	}
        	/*If sObject type is Contact*/
        	else if(String.valueOf(sObjectType) == 'Contact')
        	{
        		strListsNames = 'No Contact List Selected';
        	}
        }
        
	}
	
	/*!
      *  @MethodName: initialize
      *  @param None: None.
      *  @Description: This method is use to initalize all members.
    */
	private void initialize()
	{
	    sObjectId = null;
		setCompanyListId = new set<ID>();
		lstListsNames = new List<String>();
		strListsNames = '';
	}
}