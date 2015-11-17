/**
    * \arg ClassName      : SL_EnhancedContactRelatedListCtrl
    * \arg JIRATicket     : NPD-85
    * \arg CreatedOn      : 31/August/2015
    * \arg LastModifiedOn : 
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : 
    * \arg Description    : This class for the SL_EnhancedContactRelatedList page.
*/
public with sharing class SL_EnhancedContactRelatedListCtrl 
{
    /* Start - Variables */
    public Map<Id, ContactWrapper> mapContactIdToContactWrapper {get;set;} // map to contain contact id to contactwrapper
    public Map<String, boolean> mapFieldNameToIsEditable        {get;set;} // map to contain field api name to editable accessibility
    public Id idSelectedContactId                               {get;set;} // this will contain the selected contact id for delete
    private Id idParentAccountId;                                       // this is the standard controller account id
    /* End - Variables */
    
     /* Start - Constructor */
    public SL_EnhancedContactRelatedListCtrl(ApexPages.StandardController stdController)
    {
        mapFieldNameToIsEditable = new Map<String, boolean>();
        idParentAccountId = stdController.getRecord().id; // assign the account id to variable
        fetchContacts(); 
    }
    /* End - Constructor */
    
    /**
    @MethodName : fetchContacts
    @Param      : 
    @Description: This method will fetch the all contact related to accounts 
    **/
    public void fetchContacts()
    {
        mapContactIdToContactWrapper = new Map<Id, ContactWrapper>();
        List<String> lstContactFields = new List<String>();
        
        //preparing dynamic query based on field set values
        String strQueryContact = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.SL_EnhancedContact.getFields()) 
        {
            lstContactFields.add(f.getFieldPath());
            //if the field is parent account's or user's field then set the iseditable value to false
            if(f.getFieldPath().contains('.'))
                mapFieldNameToIsEditable.put(f.getFieldPath(), false);
            else
                mapFieldNameToIsEditable.put(f.getFieldPath(), true);
        }
        
        strQueryContact += String.join( lstContactFields, ', ');
        strQueryContact = lstContactFields.size()>0 ? strQueryContact+', ' : strQueryContact;
        strQueryContact += 'Id, Name,(SELECT Id, Account__r.Practice__r.Name, Contact__c FROM Contact_Relationships__r WHERE Account__r.Practice__r.Name != null)'+
                            ' FROM Contact WHERE AccountId =:idParentAccountId';
        
        for(Contact objContact : Database.Query(strQueryContact))
        {
            List<String> lstNames = new List<String>();
            for(Contact_Relationship__c objContactRelationship:objContact.Contact_Relationships__r)
            {
                lstNames.add(objContactRelationship.Account__r.Practice__r.Name);
            }
            mapContactIdToContactWrapper.put(objContact.Id, new ContactWrapper(objContact, String.join(lstNames, ', ')));
        }
        
        //describe token call for getting the caontact field and check if it is reference type then set the iseditable to false
        for(Schema.SobjectField objField: Contact.SObjectType.getDescribe().fields.getMap().Values())
        {
            if(objField.getDescribe().getType() == Schema.DisplayType.REFERENCE && mapFieldNameToIsEditable.containsKey(objField.getDescribe().getName()))
                mapFieldNameToIsEditable.put(objField.getDescribe().getName(), false);
        }
    }
    //Wrapper class for contact
    public class ContactWrapper
    {
        public Contact objContact {get;set;}
        public String strName {get;set;}
        public ContactWrapper(Contact objContact, String strName)
        {
            this.objContact = objContact;
            this.strName = strName;
        }
    }
    
    /**
    @MethodName : delContactRecord
    @Param      : 
    @Description: This method will delete the contact record
    **/
    public void delContactRecord()
    {
        //delete the selected contact record
        delete new contact(Id = idSelectedContactId);
        fetchContacts();
    }
}