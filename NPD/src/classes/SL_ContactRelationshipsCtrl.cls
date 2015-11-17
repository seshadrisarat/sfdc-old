/*
* \arg ClassName      : SL_ContactRelationshipsCtrl
* \arg JIRATicket     : NPD-216
* \arg CreatedOn      : 14/Oct/15
* \arg LastModifiedOn : 16/Oct/15
* \arg CreatededBy    : Praful Gadge
* \arg ModifiedBy     : Sanath kumar
* \arg Description    : This class is used as a generic class to create Contact Relationships records from Account and Contact
*/
public with sharing class SL_ContactRelationshipsCtrl {
    
    /***Global Variables Start***/
    
    // SelectOption lists for public consumption
    public List<SelectOption> leftOptions { get; set; }
    public List<SelectOption> rightOptions { get; set; }
    
    public Boolean isDisbled {get;set;}
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(leftOptions, value); 
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(rightOptions, value);
        }
    }
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) { 
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    private sObject objSObject;
    
    private static final String practiceAccountsRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Practice Account').getRecordTypeId();
    
    private String strSObjectType; // To get the SObject Type
    private String strSObjectId; // To get the SObject Id
    private String strrightListOriginal ; 
    
    private set<Id> setIdAccountorContact ;
    private List<Contact_Relationship__c> lstContactRelationshipToInsert ;
    private map<Id , Id> mapIdToId ;
    /***Global Variables End ***/
    
    /* Constructor - Start*/
    
    public SL_ContactRelationshipsCtrl() {
        
        strSObjectId = ApexPages.currentPage().getParameters().get('Id');
        strSObjectType = String.valueOf(((Id)strSObjectId).getSObjectType());/*((Id)strSObjectId).getSObjectType().getDescribe().getName();*/
        
        lstContactRelationshipToInsert = new List<Contact_Relationship__c>();
        rightOptions = new List<SelectOption>(); 
        leftOptions = new List<SelectOption>();
        setIdAccountorContact = new set<Id>();
        mapIdToId = new map<Id , Id>();
        
        isDisbled = true;
        
        String queryStr = '';
       
        if(strSObjectType == 'Account')
        {
            queryStr = 'SELECT Id, Company_Account__c FROM Account WHERE Id =: strSObjectId';
        } 
        else if(strSObjectType == 'Contact')
        {
            queryStr = 'SELECT Id, AccountId FROM Contact WHERE Id =: strSObjectId';
        }
        
        objSObject = Database.query(queryStr);
        
        if(strSObjectType == 'Account')
        {
            for(Contact_Relationship__c objRelationship : [Select Contact__r.LastName , Id,
                                                                  Contact__c 
                                                            from Contact_Relationship__c 
                                                            where Account__c =: strSObjectId]) 
            {
                rightOptions.add(new SelectOption(objRelationship.Contact__c, objRelationship.Contact__r.LastName));
                mapIdToId.put(objRelationship.Contact__c , objRelationship.Id);
            }
            
            for(Contact con : [SELECT Id, LastName 
                                FROM Contact 
                                WHERE AccountId =: (Id)objSObject.get('Company_Account__c') 
                                      AND Id NOT IN:mapIdToId.keyset()]) 
            {
                leftOptions.add(new SelectOption(con.Id, con.LastName));
            }    
            
        }
        else if(strSObjectType == 'Contact')
        {
            for(Contact_Relationship__c objRelationship : [Select Account__r.Name , Account__c  , Id
                                                           from Contact_Relationship__c 
                                                           where Contact__c =: strSObjectId]) 
            {
                rightOptions.add(new SelectOption(objRelationship.Account__c, objRelationship.Account__r.Name));
                mapIdToId.put(objRelationship.Account__c , objRelationship.Id);
            }
            
            for(Account acc : [SELECT Id, Name 
                              FROM Account 
                              WHERE Company_Account__c =: (Id)objSObject.get('AccountId') 
                                    AND RecordTypeId =: practiceAccountsRT 
                                    AND ID NOT IN:mapIdToId.keyset() ]) 
            {
                leftOptions.add(new SelectOption(acc.Id, acc.Name));
            }
        }
    }
    /* Constructor - End */
    
    /*
       * MethodName : save
       * Param 		: -
       * Description: Create new Contact Relationship records
    */
    
    public PageReference save() 
    {
        List<Contact_Relationship__c> lstContactRelationshipstoDelete = new List<Contact_Relationship__c>();
        set<Id> setRelationShipsToRetains = new set<Id>();
        
        for(SelectOption so : rightOptions) 
        {
            setRelationShipsToRetains.add(so.getValue());
            if(!mapIdToId.containsKey(so.getValue()))
            {
                if(strSObjectType == 'Account')
                {
                    lstContactRelationshipToInsert.add(new Contact_Relationship__c(Account__c = (Id)objSObject.get('Id'), Contact__c = so.getValue(), Parent_Account__c = (Id)objSObject.get('Company_Account__c')));    
                }
                else if(strSObjectType == 'Contact')
                {
                    lstContactRelationshipToInsert.add(new Contact_Relationship__c(Account__c = so.getValue(), Contact__c = (Id)objSObject.get('Id'), Parent_Account__c = (Id)objSObject.get('AccountId')));   
                }
            }
        }
        
        for(Id idToDelete : mapIdToId.keyset())
        {
            if(!setRelationShipsToRetains.contains(idToDelete))
            {
                lstContactRelationshipstoDelete.add(new Contact_Relationship__c(Id=mapIdToId.get(idToDelete)));
            }
        }
        
        if(!lstContactRelationshipstoDelete.isEmpty())
            delete lstContactRelationshipstoDelete;
        
        if(!lstContactRelationshipToInsert.isEmpty())
            insert lstContactRelationshipToInsert;
        
        return cancel();
    }
    
    /*
       * MethodName : cancel
       * Param 		: -
       * Description: Return to Record detail page
    */
    
    public PageReference cancel()
    {
        PageReference pgRef = new PageReference('/'+(Id)objSObject.get('Id'));
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /*
       * MethodName : enableSaveButton
       * Param 		: -
       * Description: enables/disbles save button
    */
    
    public void enableSaveButton()
    {
        set<Id> setRelationsIds = new set<Id>();
        for(SelectOption so : rightOptions) 
        {
            setRelationsIds.add(so.getValue());
        }
        isDisbled = (mapIdToId.keyset().equals(setRelationsIds));
    }
}