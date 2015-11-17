/**
 
* \author Rahul Sharma
 
* \date 30/06/2011
 
* \see http://silverline.jira.com/browse/STONEPII-5
 
* \brief : Create New Renewal Opportunities 60 days prior to the Lease_End_Date__c with Same Contact roles
 
* \Batch Class

* \ Modified: Shailendra - date: 18/March/2013 
 
*/
  
global class SL_BatchToCreateRenewalOpportunity implements Database.Batchable<sObject>, Database.AllowsCallOuts
{
   
   /* Start - Global Variables */
   global date PriorLeaseEndDate;
   global String query = '';
   global Id RenewalOppRecordId;
   global List<Contact_Role__c> lstContactRoles = new List<Contact_Role__c>();
   global List<Opportunity> lstOpportunitytoCreate = new List<Opportunity>();
   global List<Contact_Role__c> lstCRtoCreate = new List<Contact_Role__c>();
   global List<Property_to_Opportunity_Connector__c> lstPropertyConnector = new List<Property_to_Opportunity_Connector__c>();
   global List<Property_to_Opportunity_Connector__c> lstPropOpportunityConnector = new List<Property_to_Opportunity_Connector__c>();
   //global List<User> lstOpportunityOwner = new List<User>();
   global static Boolean runTestMethod = false;
   global List<Id> lstPropertyId = new List<Id>();
   global Map<Id, String> mapPropertyIdToCurrentTenantAccount = new Map<Id, String>();
   
   /* End - Global Variables */
   
    
   /**
   
   * \Start Constructor   
   
   * \Name        : SL_BatchToCreateRenewalOpportunity
   
   * \Parameters  : String, Map
   
   * \Description : Get data to be processed
   
   */
   global SL_BatchToCreateRenewalOpportunity(String strQuery,date PriorLeaseEDate)
   {
       PriorLeaseEndDate = PriorLeaseEDate;
       system.debug('@@Constructor:');
       RenewalOppRecordId = [Select Id from Recordtype where name = 'Renewal Opportunity'].Id;
       query = strQuery;
       //lstOpportunityOwner = [select Id, Name from user where name = 'Marc Kaplan'];
       
   }
   
   /**
   
   * \Start Method
   
   * \Name         : start
   
   * \Parameters   : Database.BatchableContext
   
   * \Description  : Get the records from query
   
   */
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
       system.debug('@@Start:');    
       String strName = 'Test Opportunity 001' + '%';
       if(runTestMethod)   
       {
           query += ' AND Name like :strName limit 200';
       }
       
       return Database.getQueryLocator(query);
   }
   
  
  
   
   /*  
    @MethodName : execute
    @param      : Database.BatchableContext BC, List<Property__c> lstProperty
    @Description: Process the batch (Create Renewal opportunity along with Contact Roles)
    // Added by Shailendra 12/Feb/2013 as part of enhancement on STONEPII-111 and STONEPII-112
    */
    global void execute(Database.BatchableContext BC, List<Property__c> lstProperty)
    {
        lstOpportunitytoCreate = new List<Opportunity>();
        lstContactRoles = new List<Contact_Role__c>();
        lstPropertyId = new List<Id>();
        mapPropertyIdToCurrentTenantAccount = new Map<Id, String>();
        Map<Id,Id> mapPropertyIdToOppId = new Map<Id, Id>();
        
        for(Property__c objProperty : lstProperty)
        {
            lstPropertyId.add(objProperty.Id);
        }
        
        for(Current_Tenant__c objCT : [Select Id, Role__c, Contact__r.Name, Property__c FROM Current_Tenant__c 
                                       WHERE Property__c IN : lstPropertyId AND
                                       Role__c = 'Tenant' AND Contact__c != NULL])
        {
            mapPropertyIdToCurrentTenantAccount.put(objCT.Property__c, objCT.Contact__c + '~' + objCT.Contact__r.Name);
        }
        
        for(Property__c objProperty : lstProperty) 
        {
            Date endDate = objProperty.Lease_End_Date__c;
            Integer lastDay = Date.daysInMonth(endDate.year(),endDate.month());
            Date newEndDate = date.newInstance(endDate.year() + 1, endDate.month(), lastDay);
            
            if(mapPropertyIdToCurrentTenantAccount.containsKey(objProperty.Id))
            {
                if(objProperty.Building__c != null && objProperty.Building__r.Renewal_Leasing_Agent__c != null)
                {
                    lstOpportunitytoCreate.add(new Opportunity 
                                                       (
                                                           Name = mapPropertyIdToCurrentTenantAccount.get(objProperty.Id).split('~')[1] + '-Renewal-' + objProperty.Name ,
                                                           AccountId = mapPropertyIdToCurrentTenantAccount.get(objProperty.Id).split('~')[0],
                                                           Property__c = objProperty.Id,                                                  
                                                           CloseDate = objProperty.Lease_End_Date__c,   
                                                           RecordTypeId = RenewalOppRecordId,
                                                           StageName = 'Pending Proposed Rent',
                                                           OwnerId = objProperty.Building__r.Renewal_Leasing_Agent__c,
                                                           Previous_Opportunity__c = objProperty.Opportunity__c,
                                                           Lease_Start_date__c = objProperty.Lease_End_Date__c + 1,
                                                           Lease_End_Date__c = newEndDate,
                                                           Apartment_Lease__c = 'FM Lease Renewal'
                                                       )
                                         );
                }
            }
        }
        
        if(!lstOpportunitytoCreate.isEmpty())   insert lstOpportunitytoCreate; 
        
        for(Opportunity objOpp : lstOpportunitytoCreate)
        {
            // Create a map of Opportunity PropertyId To Opportunity Id
            mapPropertyIdToOppId.put(objOpp.Property__c , objOpp.Id);
        }
        
        
        
        for(Property__c objProperty : lstProperty)
        {
        	   Integer intOrderNumber  = 1;
               for(Current_Tenant__c objCT: objProperty.Current_Tenants__r)
               {
                    if(mapPropertyIdToOppId.containsKey(objProperty.Id) && objCT.Contact__c != null)
                    {
                    	
                        lstCRtoCreate.add(new Contact_Role__c
                                               (
                                                   Opportunity__c = mapPropertyIdToOppId.get(objProperty.Id),
                                                   Contact__c = objCT.Contact__c,
                                                   Role__c = objCT.Role__c,
                                                   Signature_Order_Number__c = intOrderNumber
                                               )
                                         );
                        ++intOrderNumber;
                    }
               }
    
         }
         
         if(!lstCRtoCreate.isEmpty())   
         	database.insert(lstCRtoCreate,false);
         
    }
   
   /*
   
           global void execute(Database.BatchableContext BC, List<Opportunity> lstOldOpportunity)
   {
       set<Id> setOppId = new set<Id>();
       List<Id> lstPropertyId = new List<Id>();
       Map<Id,String> mapProperty = new Map<Id,String>();
       lstOpportunitytoCreate = new List<Opportunity>();
       Map<Id, String> mapPropertyIdToCurrentTenantAccountName = new Map<Id, String>();
       Map<Id,List<Current_Tenant__c>> mapPropertyIdToListOfCurrentTenant = new Map<Id,List<Current_Tenant__c>>();
       
       // Added by Shailendra on 8/Feb/2013 as part of enhancement on STONEPII-111 
       
        for(Opportunity objOpp : lstOldOpportunity)
        {
            if(objOpp.Property__c != null)
                lstPropertyId.add(objOpp.Property__c);
        }
       
        if(!lstPropertyId.isEmpty())
        {
            for(Current_Tenant__c objCT : [Select Id, Role__c, Contact__r.Name, Property__c FROM Current_Tenant__c 
                                           WHERE Property__c IN : lstPropertyId AND
                                           Role__c = 'Tenant'])
            {
                mapPropertyIdToCurrentTenantAccountName.put(objCT.Property__c, objCT.Contact__r.Name);
                
                if(!mapPropertyIdToListOfCurrentTenant.containsKey(objCT.Property__c))
                {
                    mapPropertyIdToListOfCurrentTenant.put(objCT.Property__c, new List<Current_Tenant__c>{objCT});
                }
                else
                {
                    mapPropertyIdToListOfCurrentTenant.get(objCT.Property__c).add(objCT);
                }
            }
        }
        
        // Added by Shailendra on 8/Feb/2013 as part of enhancement on STONEPII-111 
       
       
       for(Opportunity objOpp : lstOldOpportunity)
       {
           if(objOpp.Renewal_Opportunities__r.isEmpty())
           {
               system.debug('@@Creating Renewal Opportunity for --'+objOpp.Name);
               Date endDate = objOpp.Lease_End_Date__c;
               Integer lastDay = Date.daysInMonth(endDate.year(),endDate.month());
               Date newEndDate = date.newInstance(endDate.year() + 1, endDate.month(), lastDay);
               //Property__c objProperty = new Property__c(Id = objOpp.Property__c, Name = objOpp.Property__r.Name);
               mapProperty.put(objOpp.Property__c,objOpp.Property__r.Name);
               system.debug('*******mapProperty*********'+mapProperty);
               lstOpportunitytoCreate.add(new Opportunity
                                               (
                                                   Name = objOpp.Name,
                                                   AccountId = objOpp.AccountId,
                                                   Property__c = objOpp.Property__c,
                                                   //CloseDate = objOpp.Lease_End_Date__c.addDays(61),
                                                   CloseDate = objOpp.Lease_End_Date__c.addDays(-30),       //  Changed By Rahul, 8th August, http://silverline.jira.com/browse/STONEPII-5
                                                   RecordTypeId = RenewalOppRecordId,
                                                   StageName = 'Renewal Pending',
                                                   OwnerId = lstOpportunityOwner[0].Id,
                                                   Previous_Opportunity__c = objOpp.Id,
                                                   Lease_Start_date__c = objOpp.Lease_End_Date__c + 1,
                                                   Lease_End_Date__c = newEndDate
                                               )
                                   );
               setOppId.add(objOpp.Id);
               system.debug('*************lstPropOpportunityConnector >>>******'+lstPropOpportunityConnector);     
           }  
           else
           {
               system.debug('@@Renewal Opportunity Exists for --'+objOpp.Name);
           }                       
       }
       
       system.debug('@@Inside execute- will create Opportunity');
       if(!lstOpportunitytoCreate.isEmpty())
       {
           //lstContactRoles = [Select Role__c, Opportunity__c, Contact__c From Contact_Role__c where Opportunity__c =: setOppId];
           //system.debug('@@Inside execute- will Insert Opportunity');
           insert lstOpportunitytoCreate;
           insert lstPropOpportunityConnector;
           //system.debug('@@Inside execute- Inserted Opportunity----lstOpportunitytoCreate'+lstOpportunitytoCreate+'-----'+lstOpportunitytoCreate[0].Id);
           lstCRtoCreate = new List<Contact_Role__c>();
           
           for(Integer i = 0; i < lstOpportunitytoCreate.size(); i++)
           {
               for(Current_Tenant__c objCT: mapPropertyIdToListOfCurrentTenant.get(lstOpportunitytoCreate[i].Property__c))
               {
                   //if(objCR.Opportunity__c == lstOpportunitytoCreate[i].Previous_Opportunity__c)
                  // {
                       system.debug('--'+lstOpportunitytoCreate[i].Id);
                       lstCRtoCreate.add(new Contact_Role__c
                                               (
                                                   Contact__c = objCT.Contact__c,
                                                   Opportunity__c = lstOpportunitytoCreate[i].Id,
                                                   Role__c = objCT.Role__c
                                               )
                                         );
                  // }
               }
           }
           
           lstPropOpportunityConnector = new List<Property_to_Opportunity_Connector__c>();
           
           for(Integer i = 0; i < lstOpportunitytoCreate.size(); i++)
           {
               system.debug('*********lstOpportunitytoCreate***********>>>>>>>>>>>>>>>>*'+lstOpportunitytoCreate[i].Property__c);
               lstPropOpportunityConnector.add(new Property_to_Opportunity_Connector__c
                                               (
                                                   Name = lstOpportunitytoCreate[i].Name + ' ' +mapProperty.get(lstOpportunitytoCreate[i].Property__c),
                                                   Property__c = lstOpportunitytoCreate[i].Property__c,
                                                   Opportunity__c = lstOpportunitytoCreate[i].Id
                                                   //Show_Date__c = objOpp.CreatedDate
                                                   //Status__c = objPOC.Status__c
                                               )
                                       );              
               
           }
           system.debug('@@Inside execute- will Insert Contact Role');
           if(!lstCRtoCreate.isEmpty())
               Database.Insert(lstCRtoCreate, false);
           system.debug('@@Inside execute- Inserted Contact Role'+lstCRtoCreate);
           
           if(!lstPropOpportunityConnector.isEmpty())
               //Database.Insert(lstPropOpportunityConnector, false);
               insert lstPropOpportunityConnector;
           system.debug('@@Inside execute- Inserted Contact Role'+lstPropOpportunityConnector);
       }       
       
   }
   
   
   
   */
   
   
   /**
   
   * \Start Method 
   
   * \Name         : finish
   
   * \Parameters   : Database.BatchableContext
   
   * \Description  :
   
   * \Return       : void
   
   */
   global void finish(Database.BatchableContext BC)
   {
       system.debug('@@@@Finish:');
   }
   
   
}