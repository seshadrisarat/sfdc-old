/**
 
* \author Rahul Sharma
 
* \date 22/06/2011
 
* \see http://silverline.jira.com/browse/STONEPII-1
 
* \brief Contact_Role__c Trigger handler. Runs onBeforeInsert, onBeforeUpdate (Avoid Duplicate Contact Role for a Opportunity)
 
* \test 
 
*/
public without sharing class SL_Contact_Role_Trigger_Handler
{
    /*    Global Variables    */
    Set<Id> setOpptyIds = new Set<Id>(); 
    Set<String> setExistingCRs = new Set<String>(); 
    Set<String> setInTriggerCRs = new Set<String>();  
    Set<String> setContactRole = new Set<String>();
    /*    Global Variables    */
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Contact_Role_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /*    This function is called By SL_Contact_Role Trigger on before Insert    */
    public void OnBeforeInsert(List<Contact_Role__c> lstNewCRs, set<Id> setAccIds)
    {    
		List<Account> lstRelatedAccounts = new List<Account>();
		Map<Id,String> mapAccountEmails = new Map<Id,String>();
        lstRelatedAccounts = [Select PersonEmail, Id From Account Where Id In :setAccIds];
        for(Account acc : lstRelatedAccounts)
        {
        	mapAccountEmails.put(acc.Id,acc.PersonEmail);
        }
        
        for(Contact_Role__c objCR:lstNewCRs)
        {
            system.debug('************objCR='+objCR);
            objCR.Contact_Email__c = mapAccountEmails.geT(objCR.Contact__c);
            if(!setInTriggerCRs.contains(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c))
            {
                setInTriggerCRs.add(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c);
            }           
            else 
            {
                objCR.addError('Contact role with same Opportunity, Contact and Role Exists');
            }
            setOpptyIds.add(objCR.Opportunity__c);
        }
    
        if(!setOpptyIds.isEmpty())
        {
            for(Contact_Role__c objCR: [Select Opportunity__c, Contact__c, Role__c from Contact_Role__c  where Opportunity__c IN: setOpptyIds])
                setContactRole.add(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c);
        
            for(Contact_Role__c objCR: lstNewCRs)
            {
                system.debug('************objCR='+objCR);
                if(setContactRole.contains(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c))
                {
                    objCR.addError('Contact role with same Opportunity, Contact and Role Exists');      
                }
            }
        }          
    }
     
    
    /*    This function is called By SL_Contact_Role Trigger on before Update    */     
    public void OnBeforeUpdate(map<ID,Contact_Role__c> oldCRsMap, map<ID,Contact_Role__c> newCrsMap)
    {
        for(Contact_Role__c objCR: newCrsMap.values())
        {
            if(objCR.Role__c != null && objCR.Role__c != '' && oldCRsMap.get(objCR.Id).Role__c != newCrsMap.get(objCR.Id).Role__c){
            if(!setInTriggerCRs.contains(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c))
                setInTriggerCRs.add(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c);
            else 
                objCR.addError('Contact role with same Opportunity, Contact and Role Exists');
            
            setOpptyIds.add(objCR.Opportunity__c);
            }
        }
    
        if(!setOpptyIds.isEmpty())
        {
            for(Contact_Role__c objCR: [Select Opportunity__c, Contact__c, Role__c from Contact_Role__c  where Opportunity__c IN: setOpptyIds])
            {    
                if(objCR.Role__c != null && objCR.Role__c != '')
                    setContactRole.add(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c);
            }
            for(Contact_Role__c objCR: newCrsMap.values())
            {
                if(setContactRole.contains(objCR.Opportunity__c + '_' + objCR.Contact__c + '_' + objCR.Role__c))
                    objCR.addError('Contact role with same Opportunity, Contact and Role Exists');      
            }
        }
    }
            
    public boolean IsTriggerContext
    {
        get{ return m_isExecuting;}
    }
     
    public boolean IsVisualforcePageContext
    {
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsWebServiceContext
    {
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsExecuteAnonymousContext
    {
        get{ return !IsTriggerContext;}
    }  
    
    /*  Test Method     */
    public static testMethod void myUnitTest()
    {
        //  Start Test Method to Cover Trigger : SL_Contact_Role
        Test.startTest();
        Account objAcc1 = new Account(LastName = 'Test Account 001' );
        insert objAcc1;
        Opportunity objOpp1 = new Opportunity( Name = 'Test Opportunity 001', StageName = 'Appointments', CloseDate = date.today(), AccountId = objAcc1.Id);
        insert objOpp1;
        //Contact_Role__c objCR = new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant');
        //insert objCR;
        Contact_Role__c objCR2 = new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Guarantor');
        insert objCR2;
        try
        {
            objCR2.Role__c = 'Tenant';
            update objCR2;
            Contact_Role__c objCR1 = new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant');
            insert objCR1;
        }
        catch(Exception e)
        {
        }
        try
        {
            List<Contact_Role__c> lstCR = new List<Contact_Role__c>();
            lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant'));
            lstCR.add(new Contact_Role__c(Contact__c = objAcc1.Id, Opportunity__c = objOpp1.Id , Role__c = 'Tenant'));
            insert lstCR;}
        catch(Exception e)
        {
        }
        objCR2.Role__c = '';
        update objCR2;
        
        try
        {
            List<Contact_Role__c> lstCR = new List<Contact_Role__c>([Select Id, Contact__c, Opportunity__c, Role__c from Contact_Role__c where Opportunity__c =: objOpp1.Id]);
            if(!lstCR.isEmpty())
                for(Integer i = 0; i < lstCR.size(); i++)
                    lstCR[i].Role__c = 'Tenant'; 
            update lstCR;
        }
        catch(Exception e)
        {
        }
        SL_Contact_Role_Trigger_Handler objHandler = new SL_Contact_Role_Trigger_Handler(true, 10);
        Boolean isTemp = objHandler.IsTriggerContext;
        isTemp = objHandler.IsExecuteAnonymousContext;
        isTemp = objHandler.IsVisualforcePageContext;
        isTemp = objHandler.IsWebServiceContext;
        Test.stopTest();
        
    }
}