/**
* \arg \b ClassName      : SL_AddCompanyContactList
* \arg \b JIRATicket     : WP-99
* \arg \b CreatedOn      : 15/07/2013
* \arg \b ModifiedBy     : -
* \arg \b Description    : This is the controller class for SL_AddCompanyContactList page. This class will take Id from page url and identify the object. 
				 		   If object is company/Contact then it will show the all contact Lists where company/contact is the member. Onclick of save it will it will save the 
				 		   all selected lists to the list field of company/contact detail page and if no contact list member is there then it will create the contact list member.  
				 		   	
*/

public with sharing class SL_AddCompanyContactList extends SL_Paginator
{
	public list<WrapperClassToBindCheckBox> lstWrapperClass     		   	{get;set;}	//This list is use to store inner class objects.
	public set<ID> setCompanyListId                                        	{get;set;}	//This set is use to store all company list ids
	public Boolean isHeaderSelected							              	{get;set;}	//This variable is use to store header checkbox value.
	public Id sObjectId														{get;set;}	// This is to store company/contact Id.
								
	private list<Company_List_Member__c> lstCompanyListMember ;	//This list is use to store company list member object.
	private list<Company_List__c> lstCompanyList;	//This list is use to store company_list object.
	private list<Company_List_Member__c> lstCompanyListMemberToInsert;	//This list is use to store all company list member those need to be created. 
	private set<String> setAlreadyAddedListsIds;	//This set is use to store all those company_list who is already selected.	
	private Schema.Sobjecttype sObjectType;	//This is to store sObject type
	
	
	/*!
      *  @ClassName: WrapperClassToBindCheckBox
      *  @Description: Inner class to bind contact id's with checkbox
    */
	public class WrapperClassToBindCheckBox 
	{
		public Company_List__c objCompanyList 		            {get;set;}	//This object is use to bind values of company_List with checkbox.
		public Boolean isChecked								{get;set;}	//This variable is use to store all rows checkbox status
		public Boolean isReadOnly								{get; set;}	                          
		/*Innerclass parametric constructor*/
		public WrapperClassToBindCheckBox(Company_List__c objCompanyList, Boolean isChecked)
		{
			this.objCompanyList = objCompanyList;
			this.isChecked = isChecked;
		}
	}
	
	
	/*Main Constructor*/
	public SL_AddCompanyContactList()
	{
		initialize();	//This is to initalize all members of main class.
		
	    sObjectId = Apexpages.currentPage().getParameters().get('id');	//To store id from page url.
        
        // If Id is not null
        if(sObjectId !=null) 
			sObjectType = sObjectId.getSObjectType();
		
		//This is to query all contact list members where company/contact Id is equals to sObject Id.                            
		for(Company_List_Member__c objCompanyListMember : [	Select Id, Name, Company_List__c
	                                                       	From Company_List_Member__c
	                                                       	Where (Company__c =: sObjectId OR Contact__c =: sObjectId) 
	                                                      ])
        {
        	 setCompanyListId.add(objCompanyListMember.Company_List__c);
        }	
            
        //This is to query all List member associated with the contact list member
        for( Company_List__c objCompanyList : [ Select Id,Name
                                                From Company_List__c
                                                Where Id IN:setCompanyListId 
                                                order by Name 
                                               ] ) 
        {  
        	setAlreadyAddedListsIds.add(objCompanyList.Id);
        }
        String adminProfileId;//To store admin profile Id
       
       	/*This is to get admin profile id*/
        for(Profile objProfile : [Select Id, Name from Profile where Name=:'System Administrator'])
        {
        	adminProfileId = objProfile.Id;
        }
       
        Set<Id> setGroupIds = new Set<Id>();
       
        for(GroupMember objGroupMember : [Select UserOrGroupId, Id, GroupId From GroupMember where UserOrGroupId =: UserInfo.getUserId()])
        {
        	setGroupIds.add(objGroupMember.GroupId);
        }
        
        Map<Id, String> mapRecordPermissions = new Map<Id, String>();
		
        //This is to query all records those are having Read/Write access
	    for(Company_List__Share objShareObject :[Select Id, ParentId, AccessLevel, UserOrGroupId 
	    										From Company_List__Share
	    										
        										])
        {
        	
	    	if(UserInfo.getProfileId() == adminProfileId)
			{
				mapRecordPermissions.put(objShareObject.ParentId, 'ALL');
			}
			else if(objShareObject.UserOrGroupId == UserInfo.getUserId() || setGroupIds.contains(objShareObject.UserOrGroupId))
			{
				mapRecordPermissions.put(objShareObject.ParentId, objShareObject.AccessLevel);
			}
	    	
        }
        
        //This is to query all List member associated with the contact list member
        for( Company_List__c objCompanyList : [ Select Id, OwnerId, Name, Show_in_Quick_Add__c
                                                From Company_List__c
                                                order by Name 
                                               ] ) 
        {     
        	/*If list owner is logged in user then it should have all access*/
        	if(objCompanyList.OwnerId == UserInfo.getUserId())
        	{
        		mapRecordPermissions.put(objCompanyList.Id, 'ALL');
        	}
        	/*If contact/company is already a member then they will come as selected*/
        	if(mapRecordPermissions.containsKey(objCompanyList.id)  && 
        		(mapRecordPermissions.get(objCompanyList.id) == 'Edit' || mapRecordPermissions.get(objCompanyList.id) == 'All'))
        	{
        		if(objCompanyList.Show_in_Quick_Add__c == true)
        		{
        			if(setAlreadyAddedListsIds.contains(objCompanyList.Id))
	            	{
	            		WrapperClassToBindCheckBox objWrapper = new  WrapperClassToBindCheckBox(objCompanyList, true); 
	            		objWrapper.isReadOnly = false;
	            		lstWrapperClass.add(objWrapper);
		            	lstCompanyList.add(objCompanyList) ; 
	            	}
	            	else
	            	{
						WrapperClassToBindCheckBox objWrapper = new  WrapperClassToBindCheckBox(objCompanyList, false); 
		            	objWrapper.isReadOnly = false;
		            	lstWrapperClass.add(objWrapper);
		            	lstCompanyList.add(objCompanyList) ; 
	            	} 
        		}
            	
        	}  
        	else
        	{
        		if(objCompanyList.Show_in_Quick_Add__c == true)
        		{
        			WrapperClassToBindCheckBox objWrapper = new  WrapperClassToBindCheckBox(objCompanyList, false); 
	        		objWrapper.isReadOnly = true;
	        		lstWrapperClass.add(objWrapper);
	            	lstCompanyList.add(objCompanyList) ; 
        		}
        		
        	} 
        }
        
        initPagination();	//Calling method to update header checkbox.
	}
	
	
	/*!
      *  @MethodName: createCompanyListMembers
      *  @param None: None.
      *  @Description: Create Company List members for company/contact.
    */
	public void createCompanyListMembers()
	{
		Set<ID> setCompanyLstIdsToDel = new Set<ID>();//String is use to store all 
		List<ID> lstCompanyListMember = new List<ID>();
		
		/* Iterating wrapper class to create Contact List member*/
		for(WrapperClassToBindCheckBox objWrapperClass : lstWrapperClass)
	    {
	    	/* Creating Contact list member Where checkbox is true*/
			if(objWrapperClass.isChecked == true )
			{
				/* If sObject type is Account then creating Contact list member with Account id*/
				if(String.valueOf(sObjectType) == 'Account' && !setAlreadyAddedListsIds.contains(objWrapperClass.objCompanyList.Id))
				{
					Company_List_Member__c objCompanyListMember = new Company_List_Member__c(Company_List__c = objWrapperClass.objCompanyList.Id, Company__c = sObjectId);
					lstCompanyListMemberToInsert.add(objCompanyListMember);
				}	
				/*If sObject type is Contact then creating a Contact list member with Contact id*/
				else if(String.valueOf(sObjectType) == 'Contact' && !setAlreadyAddedListsIds.contains(objWrapperClass.objCompanyList.Id))
				{
				    Company_List_Member__c objCompanyListMember = new Company_List_Member__c(Company_List__c = objWrapperClass.objCompanyList.Id, Contact__c = sObjectId);
				    lstCompanyListMemberToInsert.add(objCompanyListMember);
				}
			}
			else
			{
				if(setAlreadyAddedListsIds.contains(objWrapperClass.objCompanyList.Id))
					setCompanyLstIdsToDel.add(objWrapperClass.objCompanyList.Id);
			}
	     }
		     
	     /*This is to query all contact list members where company/contact Id is equals to sObject Id.*/                            
		for(Company_List_Member__c objCompanyListMember : [	Select Id, Name, Company_List__c
		                                                   	From Company_List_Member__c
		                                                   	Where (Company__c =: sObjectId OR Contact__c =: sObjectId) 
		                                                   	AND Company_List__c IN:setCompanyLstIdsToDel
		                                                  ])
		{
			 lstCompanyListMember.add(objCompanyListMember.Id);
		}	
		/*If list is not empty */
		if(!lstCompanyListMember.isEmpty())
		{
			Database.delete(lstCompanyListMember, false);
		}
            
		  	/*If company list member list is not empty*/	
			if(!lstCompanyListMemberToInsert.isEmpty())
			{
				Database.insert (lstCompanyListMemberToInsert, false);
			}
   	}
   	
	/*!
      *  @MethodName: goToPage
      *  @param None: None.
      *  @Description: This method will redirect to the page number which is entered.
    */
	public void goToPage() 
	{
		LastPage = math.mod(lstWrapperClass.size(), PageSize) == 0 ? (lstWrapperClass.size()/ PageSize) : (lstWrapperClass.size()/ PageSize) + 1;
		
     	if(page > LastPage || page == 0) 
     	{
			page = LastPage;
			FirstPage = ((page-1) * PageSize);
		} 
      	else 
			FirstPage = ((page-1) * PageSize);
	}
	
	/*!
      *  @MethodName: initPagination
      *  @param None: None.
      *  @Description: This method will initalize the variables which is required in pagination.
    */
	private void initPagination() 
	{
	    page=1;//initally page is 1. 
     	
	    FirstPage = 0; //first page index is initially 0
	    
	   	TotalRows = lstWrapperClass.size();// total rows to be spanned across pages
	    
	    PageSize = 10;// no. of rows you want to show per page
	    
	    LastPage = Math.mod(TotalRows, PageSize) == 0 ? TotalRows / PageSize : TotalRows / PageSize + 1;// calculate the index of last page
        	
	}   
	
	/*!
      *  @MethodName: initialize
      *  @param None: None.
      *  @Description: This method is use to initalize all members.
    */
	private void initialize()
	{
	    isHeaderSelected = false;//Initalizing header checkbox to false
	    lstCompanyListMember = new list<Company_List_Member__c>();
	    lstCompanyList = new list<Company_List__c>();
	    setCompanyListId = new set<ID>();
	    setAlreadyAddedListsIds = new set<String>();
	    lstWrapperClass = new list<WrapperClassToBindCheckBox>();
	    sObjectId = null;//Initalizing id to null.
	    lstCompanyListMemberToInsert = new  list<Company_List_Member__c>();
	}
}