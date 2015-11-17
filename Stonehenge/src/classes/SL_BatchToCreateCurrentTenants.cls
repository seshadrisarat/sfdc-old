/**
 
* \author Rahul Sharma
 
* \date 2ng August 2011
 
* \see http://silverline.jira.com/browse/stonePII-15
 
* \brief : Create Current Tenants records with mapping provided in the ticket
 
* \Schedulable Class
 
*/
 
global class SL_BatchToCreateCurrentTenants implements Database.Batchable<sObject>, Database.AllowsCallOuts
{ 
        
        /* Start - Global Variables */
        
        global Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        global Map<Id, Property__c> mapProperty = new Map<Id, Property__c>();
        global Map<String, Current_Tenant__c> mapCurrentTenants = new Map<String, Current_Tenant__c>();
        global List<Current_Tenant__c> lstCurrentTenant = new List<Current_Tenant__c>();
        global String query = '';
        
        /* End - Global Variables */
        
         
        /**
        
        * \Start Constructor   
        
	   * \Name        : SL_BatchToCreateCurrentTenants
	   
	   * \Parameters  : strQuery
	   
	   * \Description : Get data to be processed
	   
	   */
        global SL_BatchToCreateCurrentTenants(String strQuery)
        {
                query = strQuery;
        }
        
        /**
        
        * \Start Method
	        
	   * \Name             : start
	   
	   * \Parameters   : Database.BatchableContext
	   
	   * \Description  : Get the records from query
	   
	   */
        global Database.QueryLocator start(Database.BatchableContext BC)
	   {
	       Date CurrentDate = system.today();
	       return Database.getQueryLocator(query);
	   }
   
   /**
        
        * \Start Method
        
   * \Name             : execute
   
   * \Parameters   : Database.BatchableContext
   
   * \Description  : Create Current Tenants Records and update Opportunity and Properties accordingly
   
   * \Return           : void
   
   */
   global void execute(Database.BatchableContext BC, List<Sobject> Scope)
   {
       CreateCurrentTenants((List<Opportunity>) Scope);
   }
   
   /**
        
        * \Start Method
        
   * \Name             : CreateCurrentTenants
   
   * \Parameters   : List<Opportunity>
   
   * \Description  : Create Current Tenants Records and update Opportunity and Properties accordingly
   
   * \Return           : void
   
   */
   global void CreateCurrentTenants(List<Opportunity> lstOpportunity)
   {
   	   
       mapOpportunity = new Map<Id, Opportunity>(lstOpportunity);
       mapProperty = new Map<Id, Property__c>();
       mapCurrentTenants = new Map<String, Current_Tenant__c>();
       lstCurrentTenant = new List<Current_Tenant__c>();
       List<Contact_Role__c> lstContactRoleToUpdate = new List<Contact_Role__c>();
       
       
       // Added by Shailendra on 19/March/2013
       Set<String> setStr = new Set<String>();
       
       //      Collect all the properties related to the opportunity
       for(Property__c objProperty : [Select Id, Account__c, Opportunity__c from Property__c 
       								  where Id IN (Select Property__c from Opportunity 
       								  			   where Id IN: mapOpportunity.keyset())])
               mapProperty.put(objProperty.Id, objProperty);  
       
       //      Create a map to find duplicates 
       for(Current_Tenant__c objCT : [Select Role__c, Property__c, Lease_Start_Date__c, Lease_End_Date__c, Id, Contact__c From Current_Tenant__c where Property__c IN: mapProperty.keySet()])
               mapCurrentTenants.put(objCT.Property__c + '_' + objCT.Role__c + '_' + objCT.Contact__c, objCT);
       
       
       //      Update Opportunity and Property
       for(Opportunity objOpp : lstOpportunity)
       {
               objOpp.Tenants_Processed__c = true; 
               mapProperty.get(objOpp.Property__c).Opportunity__c = objOpp.Id;
               mapProperty.get(objOpp.Property__c).Account__c = objOpp.AccountId;
       }
       
       
       for(Contact_Role__c objCR : [Select Role__c, Opportunity__r.Property__c, Opportunity__r.Lease_End_Date__c,
                                    Opportunity__r.Lease_Start_date__c, Opportunity__c, Id, Contact__c From Contact_Role__c
                                    where Opportunity__c IN: mapOpportunity.keyset() and Opportunity__r.RecordType.DeveloperName =: 'Renewal_Opportunity'
                                    and Tenants_Processed__c=: false])
       {
               if(mapCurrentTenants.Containskey(String.valueOf(objCR.Opportunity__r.Property__c + '_' + objCR.Role__c + '_' + objCR.Contact__c)))
               {
                       //      Duplicate Case, only Update the Lease End Date of Current Tenant
                       mapCurrentTenants.get(String.valueOf(objCR.Opportunity__r.Property__c + '_' + objCR.Role__c + '_' + objCR.Contact__c)).Lease_End_Date__c = objCR.Opportunity__r.Lease_End_Date__c;
                       
                       if(!setStr.contains(String.valueOf(objCR.Opportunity__r.Property__c + '_' + objCR.Role__c + '_' + objCR.Contact__c)))
                       {
	                       lstCurrentTenant.add(mapCurrentTenants.get(String.valueOf(objCR.Opportunity__r.Property__c + '_' + objCR.Role__c + '_' + objCR.Contact__c)));
                       	   setStr.add(String.valueOf(objCR.Opportunity__r.Property__c + '_' + objCR.Role__c + '_' + objCR.Contact__c));
                       }
               }
               else
               {
                       //      Create a new Current Tenant Record with mapping provided
                       system.debug('@@@@Insert: ');
                       lstCurrentTenant.add(new Current_Tenant__c
                                                            (
                                                                    Contact__c = objCR.Contact__c,
                                                                    Role__c = objCR.Role__c,
                                                                    Lease_End_Date__c = objCR.Opportunity__r.Lease_End_Date__c,
                                                                    Lease_Start_Date__c = objCR.Opportunity__r.Lease_Start_date__c,
                                                                    Property__c = objCR.Opportunity__r.Property__c
                                                  			 )
                                            );
               }
               objCR.Tenants_Processed__c = true;
               lstContactRoleToUpdate.add(objCR);
       }
       
       
       for(Contact_Role__c objCR : [Select Role__c, Opportunity__r.Property__c, Opportunity__r.Lease_End_Date__c,
                                    Opportunity__r.Lease_Start_date__c, Opportunity__c, Id, Contact__c From Contact_Role__c
                                    where Opportunity__c IN: mapOpportunity.keyset() and Opportunity__r.RecordType.DeveloperName =: 'New_Lease_Opportunity'   
                                    and Tenants_Processed__c=: false])
       {
       		lstCurrentTenant.add(new Current_Tenant__c
                                                            (
                                                                    Contact__c = objCR.Contact__c,
                                                                    Role__c = objCR.Role__c,
                                                                    Lease_End_Date__c = objCR.Opportunity__r.Lease_End_Date__c,
                                                                    Lease_Start_Date__c = objCR.Opportunity__r.Lease_Start_date__c,
                                                                    Property__c = objCR.Opportunity__r.Property__c
                                                  			 )
                                            );
            objCR.Tenants_Processed__c = true;
            lstContactRoleToUpdate.add(objCR);
       }
       
       
       
       /*      Dml Begin's     */
       
       database.update(lstOpportunity,false);
       system.debug('@@@@lstOpportunity: '+lstOpportunity);
       
       database.update(mapProperty.values(),false);
       system.debug('@@@@mapProperty.values(): '+mapProperty.values());
       
       if(!lstCurrentTenant.isEmpty())
          database.upsert(lstCurrentTenant,false);
       system.debug('@@@@lstCurrentTenant: '+lstCurrentTenant);
       
       if(!lstContactRoleToUpdate.isempty())
       	  database.update(lstContactRoleToUpdate,false);
       	
       
       /*      Dml End's       */
   }
   
   
    
    /**
        
        * \Start Method
        
   * \Name             : finish
   
   * \Parameters   : Database.BatchableContext
   
   * \Description  :
   
   * \Return           : void
   
   */
   global void finish(Database.BatchableContext BC)
   {
       
   }
   
        /* Start - Test Method */
   public static testmethod void SL_BatchToCreateCurrentTenants()
   {
       Account objAcc = new Account(Name = 'Test Account');
       insert objAcc;
       
   	   Property__c objProp = new Property__c(Name = 'Test Property 001');
       insert objProp;
       
       Opportunity objOpp = new Opportunity(Property__c = objProp.Id, Name = 'Test Opportunity 001', CloseDate = system.today(), StageName = 'Signed Lease', AccountId = objAcc.Id, Lease_Approved__c = true, Application_Approved__c = true);
       insert objOpp;
       
       Current_Tenant__c  objCurrentTenant  = new Current_Tenant__c(Property__c = objProp.Id,Contact__c = objAcc.Id );
       insert objCurrentTenant;
       
       Contact_Role__c objContactRole = new Contact_Role__c(Contact__c = objAcc.Id,Opportunity__c =objOpp.id);
       insert objContactRole;
     
       Test.startTest();
       		database.executeBatch(new SL_BatchToCreateCurrentTenants('Select AccountId, Property__c, Tenants_Processed__c, StageName, Lease_Start_date__c, Lease_End_Date__c From Opportunity' + 
                			' where StageName = \'Signed Lease\' and Tenants_Processed__c = false And Property__c != \'\''));
       Test.stopTest();            
   }           
   /* End - Test Method */
}