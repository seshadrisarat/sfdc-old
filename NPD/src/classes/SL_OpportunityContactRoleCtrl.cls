/**  
* \arg ClassName        : SL_OpportunityContactRoleCtrl
* \arg JIRATicket       : NPD-120
* \arg CreatedOn        : 14/Sep/2015
* \arg LastModifiedOn   : 28/Spe/2015
* \arg CreatededBy      : Sanath
* \arg ModifiedBy       : Sandeep
* \arg Description      : 
*/
public with sharing class SL_OpportunityContactRoleCtrl 
{
	public List <OpportunityContactRole> lstOppContactRole      { get;set; }
	public Opportunity objOpprtunity                            { get;set; }
	public map<Id, Contact> mapContactIdToContact {get;set;}
	private Id opportunityId ;

	public SL_OpportunityContactRoleCtrl() 
	{
		lstOppContactRole = new List <OpportunityContactRole>();
		objOpprtunity = new Opportunity();
		opportunityId = ApexPages.currentPage().getParameters().get('oppId');
		if (opportunityId != null)
		{
			objOpprtunity = [Select Id, Name FROM Opportunity WHERE Id = : opportunityId];
			lstOppContactRole = [Select Id, ContactId, OpportunityId, IsPrimary, Role FROM OpportunityContactRole Where OpportunityId = : objOpprtunity.Id];
			
			for (Integer i = 0; i < 10; i++) 
				lstOppContactRole.add(new OpportunityContactRole());
			fetchContactAddress();
		}
	}
	/*
        * MethodName        : save
        * param             : 
        * Description       : This method will save the opportunity contact
    */
	public pagereference save() 
	{
		List<OpportunityContactRole> lstOppContactRoleToUpsert = new List <OpportunityContactRole>();
		List<Contact> lstContactToUpdate = new List<Contact>();
		for (OpportunityContactRole objOppContactRole: lstOppContactRole) 
		{
			if (objOppContactRole.ContactId != null ) 
			{
			    if(objOppContactRole.Role == null && objOppContactRole.IsPrimary == true)
			    {
			        objOppContactRole.IsPrimary.addError(' The primary contact must be assigned a contact role');
			        return null;
			    }
				if (objOppContactRole.OpportunityId != null)
					lstOppContactRoleToUpsert.add(objOppContactRole);
				if (objOppContactRole.OpportunityId == null)
				{
					objOppContactRole.OpportunityId = opportunityId;
					lstOppContactRoleToUpsert.add(objOppContactRole);
				}
				if(mapContactIdToContact.containsKey(objOppContactRole.ContactId))
			    {
			        lstContactToUpdate.add(mapContactIdToContact.get(objOppContactRole.ContactId));
			    }
			}
		}
		// Create a savepoint if any error comes while updating contact role. it should roll back 
        Savepoint sp = Database.setSavepoint();
        try{
    		upsert lstOppContactRoleToUpsert;
    		upsert lstContactToUpdate;
            update new Opportunity(Id = opportunityId);
    		PageReference objPageReference = new PageReference('/' + opportunityId);
    		objPageReference.setRedirect(true);
    		return objPageReference;
        }
        catch(Exception ex){
            Database.rollback(sp);// roll back 
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'The contact you selected belongs to a different Account. Please select a Contact that belongs to the Account this Opportunity is related to. If the Contact does not exist under this Account, please create it.'));}
            return null;
	}
	
	/*
        * MethodName        : get
        * param             : 
        * Description       : This method will redirect to opportuntiy record
    */
    public void fetchContactAddress() 
	{
	    set<Id> setContactId = new set<Id>();
		for(OpportunityContactRole objContactRole: lstOppContactRole)
		{
		    if(objContactRole.ContactId != null)
		        setContactId.add(objContactRole.ContactId);
		}
    	mapContactIdToContact = new map<Id, Contact>([SELECT MailingStreet, MailingCity,  MailingPostalCode,  MailingCountryCode, MailingStateCode,
    	                                                     OtherStreet, OtherCity,  OtherPostalCode,  OtherCountryCode, OtherStateCode
		                                                     FROM Contact WHERE Id IN: setContactId]);
	}
	
	
	/*
        * MethodName        : cancel
        * param             : 
        * Description       : This method will redirect to opportuntiy record
    */
    public pagereference cancel() 
	{
	    PageReference P = new PageReference('/' + opportunityId);
		return p;
	}
}