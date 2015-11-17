/**
 
* \author Shailendra
 
* \date 02/07/2012
 
* \see http://silverline.jira.com/browse/STONEPII-97
 
* \brief SL_SIGN_Agreement_Trigger_Handler handler. Runs onAfterInsert, onAfterUpdate to update the status of Opportunity satge based on Agreement status.
 
*/

public with sharing class SL_SIGN_Agreement_Trigger_Handler 
{
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    
    /* Start - Constructor*/ 
    public SL_SIGN_Agreement_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /* Stop - Constructor*/ 
    
    
    /* Start - OnAfterinsert function */ 
    public void OnAfterInsert(list<echosign_dev1__SIGN_Agreement__c> lstSignAgreement)   
    {
        updateOpportunityStage(lstSignAgreement, new Map<Id,echosign_dev1__SIGN_Agreement__c>());
    }
    /* Stop - OnAfterinsert function */ 
    
    
    /* Start - OnAfterUpdate function */ 
    public void OnAfterUpdate(map<Id,echosign_dev1__SIGN_Agreement__c> mapOldAgreement,map<Id,echosign_dev1__SIGN_Agreement__c> mapNewAgreement)
    {
    	updateOpportunityStage(mapNewAgreement.values(), mapOldAgreement);
    }
    /* Stop - OnAfterUpdate function */
    
    /* Start - updateOppoprtunityStage function */
    public void updateOpportunityStage(list<echosign_dev1__SIGN_Agreement__c> lstSignAgreement, map<Id,echosign_dev1__SIGN_Agreement__c> mapOldAgreement)
    {
    	List<Opportunity> lstOpportnuity = new List<Opportunity>();
   		Map<Id,Boolean> mapOppAgreement = new Map<Id,Boolean>();
    	Set<Id> setOppId = new Set<Id>();
    	Map<Id,Integer> rolesGuarantorMap = new Map<Id,Integer>();
        Map<Id,Integer> agreementsCountMap = new Map<Id,Integer>();
             
       	for(echosign_dev1__SIGN_Agreement__c obj : lstSignAgreement)
        {
            if(mapOldAgreement.containsKey(obj.Id) && mapOldAgreement.get(obj.Id).echosign_dev1__Status__c != obj.echosign_dev1__Status__c)
            	setOppId.add(obj.echosign_dev1__Opportunity__c);
            else if(!mapOldAgreement.containsKey(obj.Id))
            	setOppId.add(obj.echosign_dev1__Opportunity__c);
        }
            
        if(setOppId.isEmpty())
        	return;    
        /////////Start - Added by Shailendra on 10/MAR/2015 to merge the functionality of SetAgreementOppStage trigger//////////////
       	
        
        for( Contact_Role__c role : [SELECT Id, Opportunity__c, Role__c from Contact_Role__c where Opportunity__c IN :setOppId] ) 
        {
            if( role.Role__c != 'Guarantor') continue;
            
            if(rolesGuarantorMap.containsKey(role.Opportunity__c))
            	 rolesGuarantorMap.put(role.Opportunity__c, rolesGuarantorMap.get(role.Opportunity__c) + 1 );
            else 
            	 rolesGuarantorMap.put(role.Opportunity__c, 1 );
        }
            
        for( echosign_dev1__SIGN_Agreement__c agreement :  [SELECT Id, 
        														   echosign_dev1__Opportunity__c 
            												  FROM echosign_dev1__SIGN_Agreement__c 
            											     WHERE echosign_dev1__Opportunity__c IN :setOppId 
            												   AND Name LIKE 'Guarantor Form%' 
            												   AND echosign_dev1__Status__c = 'Signed']) 
        {
        	if(agreementsCountMap.containsKey(agreement.echosign_dev1__Opportunity__c))
        		agreementsCountMap.put(agreement.echosign_dev1__Opportunity__c, agreementsCountMap.get(agreement.echosign_dev1__Opportunity__c) + 1);
        	else
        		agreementsCountMap.put(agreement.echosign_dev1__Opportunity__c, 1);
        }
        
        /////////End - Added by Shailendra on 10/MAR/2015 to merge the functionality of SetAgreementOppStage trigger//////////////
        
        for(echosign_dev1__SIGN_Agreement__c objEcho :[Select echosign_dev1__Opportunity__c, Name,echosign_dev1__Status__c From echosign_dev1__SIGN_Agreement__c  where echosign_dev1__Opportunity__c = :setOppId])
        {
            if(objEcho.echosign_dev1__Status__c !='Signed')
            {
                mapOppAgreement.put(objEcho.echosign_dev1__Opportunity__c, false);                  
            }
            else if(objEcho.echosign_dev1__Status__c =='Signed')
            {
                if(mapOppAgreement.containsKey(objEcho.echosign_dev1__Opportunity__c) && mapOppAgreement.get(objEcho.echosign_dev1__Opportunity__c))
                    continue;
                else if (!mapOppAgreement.containsKey(objEcho.echosign_dev1__Opportunity__c))
                    mapOppAgreement.put(objEcho.echosign_dev1__Opportunity__c, true);
            }
        }
            
        for(echosign_dev1__SIGN_Agreement__c objSignAgreement : lstSignAgreement)
        {
            if(objSignAgreement.echosign_dev1__Opportunity__c != null && objSignAgreement.Id !=null)
            {
                Opportunity objOpportunity = new Opportunity(Id = objSignAgreement.echosign_dev1__Opportunity__c);
                
                if(objSignAgreement.echosign_dev1__Status__c == 'Out for Signature' && !objSignAgreement.Name.startsWith('Guarantor Form -'))
                {
                    objOpportunity.StageName = 'Lease out for Signature';
                }
                else if(objSignAgreement.echosign_dev1__Status__c == 'Waiting for Counter-Signature')
                {
                    objOpportunity.StageName = 'Awaiting Rent/Security Payment';
                }
                
                else if(objSignAgreement.echosign_dev1__Status__c == 'Signed')
                {
                    if(mapOppAgreement.get(objSignAgreement.echosign_dev1__Opportunity__c)== true)
                        objOpportunity.StageName = 'Signed Lease';
                        
                }
                
                /////////Start - Added by Shailendra on 10/MAR/2015 to merge the functionality of SetAgreementOppStage trigger//////////////
                if(agreementsCountMap.containsKey(objSignAgreement.echosign_dev1__Opportunity__c) 
                    &&  rolesGuarantorMap.containsKey(objSignAgreement.echosign_dev1__Opportunity__c)
                    && agreementsCountMap.get(objSignAgreement.echosign_dev1__Opportunity__c) == rolesGuarantorMap.get(objSignAgreement.echosign_dev1__Opportunity__c))
                {
                    objOpportunity.StageName = 'Awaiting Rent/Security Payment';
                }
                /////////End - Added by Shailendra on 10/MAR/2015 to merge the functionality of SetAgreementOppStage trigger//////////////
                 
                 
                lstOpportnuity.add(objOpportunity); 
            }
        }   
        if(lstOpportnuity.size() > 0)   
            update lstOpportnuity;
    }
    /* Stop - updateOppoprtunityStage function */

    
    public static testMethod void SL_SIGN_Agreement_Trigger_Handler_Test()
    {
        
        Account account = new Account(Name='test');
        insert account;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Closed / Won', CloseDate=Date.today(), AccountId = account.Id, Application_Approved__c = true);
        insert opp;
        
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Opportunity__c=opp.Id);
        insert agreement;
        
        agreement.echosign_dev1__Status__c = 'Out for Signature';
        update agreement;
        
        agreement.echosign_dev1__Status__c = 'Waiting for Counter-Signature';
        update agreement;
        
        agreement.echosign_dev1__Status__c = 'Signed';
        update agreement;
        
    }
}