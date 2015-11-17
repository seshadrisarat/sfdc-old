/**
	@ClassName    : SL_User_Handler
	@JIRATicket   : YNHH-109,YNHH-139
	@CreatedOn    : 7/17/2015
	@CreatedBy    : Sandeep
	@ModifiedBy   : 
	@Description  : This is the handler class for Contact trigger(SL_Contact).
*/
public class SL_Contact_Handler 
{

    private static Map<String, String> fieldMapping = new Map<String, String>{
          'Process_Level_1__c'  => 'Process_Level_1__c',
        'FederationIdentifier'  => 'Federation_ID__c',
                    'LastName'  => 'LastName',
                   'FirstName'  => 'FirstName',
                  'Department'  => 'Department',
            'Position_Name__c'  => 'Position_Name__c',
               'EMP_Status__c'  => 'EMP_Status__c',
                      'FTE__c'  => 'FTE__c',
               'FID_Amount__c'  => 'FID_Amount__c',
                       'Email'  => 'Email',
              'PTO_Balance__c'  => 'Eligible_Balance__c',
              'PTO_Accrual__c'  => 'BW_Accrual__c',
           'PTO_Hours_Used__c'  => 'Hours_Used__c',
              'Valid_as_of__c'  => 'Valid_As_Of__c',
                 'Job_Code__c'  => 'Job_Code__c',
              'Employee_ID__c'  => 'Employee_Number__c',
              'Union__c'        => 'Union__c'
    };

    private static Id profileId = [SELECT Id FROM Profile WHERE Name =: 'YNHH Employee'].Id;

    /*Recursion*/
    public static Boolean isUpdateAllowed=true;
    /*Recursion*/

    public static List<Related_Employee__c> rels;
    public static List<User> users;
    
   /**
		@MethodName : onBeforeInsert
		@Param 		: List<Contact> lstContact
		@Description: This method called on Before insert of Contact record 
    **/
    public void onBeforeInsert(List<Contact> lstContact)
    {
        System.debug('bdf '+lstContact.size());
        List<Related_Employee__c> subEmployees = new List<Related_Employee__c>();
        Set<String> fedIds = new Set<String>();
        for(Contact c :lstContact)
            if(c.Federation_ID__c != null)
                fedIds.add(c.Federation_ID__c);
        List<Contact> parentContacts = [Select Id, Federation_ID__c FROM Contact WHERE Federation_ID__c IN :fedIds];
        Map<String, Contact> fedIdToContact = new Map<String, Contact>();
        if(parentContacts.size()>0)
            for(Contact c :parentContacts)
                fedIdToContact.put(c.Federation_ID__c, c);

        for(Contact c :lstContact){
            Contact parent = fedIdToContact.get(c.Federation_ID__c);
            if(parent != null){
                Related_Employee__c sub = new Related_Employee__c();
                for(String fieldName :fieldMapping.values()){
                    try{
                        sub.put(fieldName, c.get(fieldName));
                    }catch(Exception e){
                        // handle invalid field
                    }
                }
                sub.Name = c.FirstName+' '+c.LastName;
                sub.Primary_Contact__c = parent.Id;
                subEmployees.add(sub);
                //c.addError('Duplicate Federation ID Found.  Sub-Contact added instead');
            }
        }
        System.debug('bdf2 '+lstContact.size());
        System.debug('bdf3 '+subEmployees);
        rels = subEmployees.deepClone();
    }
    
    /**
		@MethodName : onBeforeUpdate
		@Param 		: map<Id, Contact> mapNewContact, map<Id, Contact> mapOldContact
		@Description: This method called on Before update of Contact record
    **/
    public void onBeforeUpdate(map<Id, Contact> mapNewContact, map<Id, Contact> mapOldContact)
    {
        // Find matching User and make the Connection
        Set<String> employeeIds = new Set<String>();
        for(Contact objContact : mapNewContact.values())
            if(objContact.Employee_Number__c != null)
                employeeIds.add(objContact.Employee_Number__c);

        Map<String, User> mapEmpIdToUser = new Map<String, User>();
        for(User u :[SELECT Id, Employee_ID__c FROM User WHERE Employee_ID__c IN :employeeIds])
        {
            mapEmpIdToUser.put(u.Employee_ID__c, u);
        }

        for(Contact objContact : mapNewContact.values())
            if(mapEmpIdToUser.containsKey(objContact.Employee_Number__c) && mapEmpIdToUser.get(objContact.Employee_Number__c).Id != Null)
                objContact.Portal_User__c = mapEmpIdToUser.get(objContact.Employee_Number__c).Id;

        for(Contact objContact: mapNewContact.values())
        {
            User u = mapEmpIdToUser.get(objContact.Employee_Number__c);
            if(u != null){
                for(String uField :fieldMapping.keySet())
                {
                    String fieldName = fieldMapping.get(uField);
                    if(fieldName != null && (fieldName != 'Email' || objContact.get(fieldName) != null))
                    {
                        u.put(uField, objContact.get(fieldName));
                    }
                }
                u.HrContactId__c = objContact.Id;
            }
        }
        users = mapEmpIdToUser.values();//.deepClone();
    }
    
    /**
		@MethodName : onAfterInsert
		@Param 		: List<Contact> lstContact
		@Description: This method called on after insert of Contact record 
    **/
    public void onAfterInsert(List<Contact> lstContact)
    {
        createUserCorrespondToContact(lstContact, new map<Id, Contact>());
        if(rels != null && rels.size()>0)
            upsert rels Employee_Number__c;

    }
    
    /**
		@MethodName : onAfterUpdate
		@Param 		: map<Id, Contact> mapNewContact, map<Id, Contact> mapOldContact
		@Description: This method called on after update of Contact record
    **/
    public void onAfterUpdate(map<Id, Contact> mapNewContact, map<Id, Contact> mapOldContact)
    {
        Map<String, List<String>> processLevelsByContactId = new Map<String, List<String>>();
        Map<String, List<String>> jobCodesByContactId = new Map<String, List<String>>();
        if(rels != null && rels.size()>0){
            upsert rels Employee_Number__c;
            for(Related_Employee__c r :rels){
                List<String> pLevels = processLevelsByContactId.get(r.Primary_Contact__c);
                if(pLevels == null) pLevels = new List<String>();
                pLevels.add(r.Process_Level_1__c);
                processLevelsByContactId.put(r.Primary_Contact__c, pLevels);

                List<String> jCodes = jobCodesByContactId.get(r.Primary_Contact__c);
                if(jCodes == null) jCodes = new List<String>();
                jCodes.add(r.Job_Code__c);
                jobCodesByContactId.put(r.Primary_Contact__c, jCodes);
            }
        }

        List<User> usersForUpdate = new List<User>();
        for(User u :users){
            List<String> pl = processLevelsByContactId.get(u.HrContactId__c);
            if(pl != null && pl.size()>0){
                String strProcessLevel = u.Process_Level_1__c + ',' + String.join(pl, ',');
                u.Process_Level_1__c = strProcessLevel; 
            }
            usersForUpdate.add(u);
        }
        
        updateUsersAsync(JSON.serialize(usersForUpdate));
    }

    @future
    public static void updateUsersAsync(String strNewUsers)
    {
        List<User> lstNewUserFromString = new List<User>();
        lstNewUserFromString = (List<User>)JSON.deserialize(strNewUsers, List<User>.Class);
        update lstNewUserFromString;
    }
    
    /**
		@MethodName : checkUserContactRelationship(Added for YNHH-139)
		@Param 		: List<Contact> lstNewContact, map<Id, Contact> mapOldContact
		@Description: This method will create User to update the contact portal user field.
    **/
    public void createUserCorrespondToContact(List<Contact> lstNewContact, map<Id, Contact> mapOldContact)
    {   
        if(!system.isFuture() && profileId != null)
            futureMethodForInsertUser(JSON.serialize(lstNewContact)); //call future method to avoid mix DML error
    }
    
    //future method to create User record and update contact record(avoiding mix dml error)
    @Future
    public static void futureMethodForInsertUser(String strContacts)
    {
        List<Contact> lstContactToUpdate = new List<Contact>();
        Map<String, User> mapEmpIdToUser = new Map<String, User>();
        
        Integer ALIAS_LENGTH = 8;
        
        List<Contact> lstContact = (List<Contact>)JSON.deserialize(strContacts, List<Contact>.Class);
        
        Id roleId = null;
        List<UserRole> roles = [SELECT Id FROM UserRole WHERE DeveloperName = 'YNHH_Employee'];
        if(roles.size()>0) roleId = roles[0].Id;

        for(Contact objContact : lstContact)
        {
            String strEmail = (objContact.Email != null) ? objContact.Email : objContact.Employee_Number__c.replaceAll(' ', '') + '@ynhh.com';

            User u = new User( LocaleSidKey ='en_US',
                               //UserRoleId = roleId,
                               LanguageLocaleKey ='en_US',
                               EmailEncodingKey = 'UTF-8',
                               HrContactId__c = objContact.Id,
                               LastName = objContact.LastName,
                               Firstname = objContact.Firstname,
                               TimeZoneSidKey ='America/New_York',
                               Employee_ID__c = objContact.Employee_Number__c,
                               UserName = objContact.Employee_Number__c.replaceAll(' ', '') + '@ynhh.com',
                               Alias = objContact.Employee_Number__c.substring(0 , (objContact.Employee_Number__c.length() < ALIAS_LENGTH - 1) ? objContact.Employee_Number__c.length() : ALIAS_LENGTH));
            for(String cField :fieldMapping.values())
            {
                String fieldName = fieldMapping.get(cField);
                if(fieldName != null)
                    u.put(fieldName, objContact.get(cField));
            }
            if(u.Email == null) u.Email = strEmail;
            mapEmpIdToUser.put(objContact.Employee_Number__c, u);
        }
        
        /* Here we need to catch the insert errors, and do an 
            update for those records -- updating only the fields 
            in the fieldMapping map (see lines 224-228) */
        database.insert(mapEmpIdToUser.values(), false);
    }
}