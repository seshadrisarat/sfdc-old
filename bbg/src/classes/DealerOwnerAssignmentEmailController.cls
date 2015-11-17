public class DealerOwnerAssignmentEmailController {
    public DealerOwnerAssignmentEmailController(){
        s = getSelectFields();
        ownerValues = new map<String,String>();
    }
    private string s;
    public final string thisOwnerId{get;set;}
    
    public string selectQry{
        get{
            system.debug('SELECT Id,'+s+' FROM Account WHERE Id = ' + thisOwnerId);
            return 'SELECT Id,'+s+' FROM Account WHERE Id = ' + thisOwnerId;
        }set;
    }
    
    public Account theOwner{
        get{
            if(theOwner==null){
                try{
                    return [SELECT Id, Brand_of_Interest__c, Brand__c,
                            PersonLeadSource,  
                            CreatedDate,
                            LastModifiedDate,
                            Lead_Form_Name__pc, 
                            //Type_of_Inquiry__c,
                            Name, 
                            PersonEmail, 
                            PersonMailingStreet, 
                            PersonMailingCity, 
                            PersonMailingState, 
                            PersonMailingPostalCode, 
                            PersonMailingCountry, 
                            Boat_Model_Interest__pc, 
                            Boat_Class_Interest__pc, 
                            Boat_Category_of_Interest__pc,
                            Buying_horizon__pc, 
                            Email_Opt_in__pc, 
                            Best_Time_to_Contact__pc,
                            Monthly_Payment_Range__pc, 
                            Preferred_method_of_contact__pc, 
                            Best_Phone__pc, 
                            Phone, 
                            PersonMobilePhone,
                            PersonHomePhone,
                            Work_Phone__pc, 
                            Current_Boat_Owner__pc, 
                            Current_Owned_Brand__pc, 
                            Current_Owned_Model__pc, 
                            Current_Owned_Boat_Class__pc, 
                            Currently_Owned_Year__pc, 
                            Current_Monthly_Payment__pc, 
                            Preference_for_New_or_Used__pc, 
                            First_Time_Boat_Owner__pc, 
                            Previously_Owned_Boat_Brand__pc, 
                            Notes__pc, 
                            Parts_Comments__pc, 
                            Hull_Identification_Number_HIN__pc, 
                            Spouse__c, 
                            Trading_in_a_Boat__pc, 
                            Trade_In_Make__pc, 
                            Trade_In_Model__pc, 
                            Trade_In_Year__pc, 
                            Trade_In_Comments__pc, 
                           	pi__score__pc,
                            Comments__pc,
                            Event_Name__pc FROM Account WHERE Id = :thisOwnerId];
                }catch(Exception e){
                    Account l = new Account(PersonLeadSource='Fake Source',Lead_Form_Name__pc = 'Fake Form Name');
                    return l;
                }
            }
            return theOwner;
        }set;
    }
    
    public List<Owner_Boat_Relationship__c> OwnedBoats {
    	get {
			if (thisOwnerId == null) {
				return new List<Owner_Boat_Relationship__c>();
			}
			return [
				select
					hin_number__r.name,
					hin_number__r.color__c,
					hin_number__r.Boat_Class__c,
					hin_number__r.brand_del__c,
					hin_number__r.Model_Year__c,
					hin_number__r.Boat_Model__c,
					Purchase_Date__c,
					Status__c
				from Owner_Boat_Relationship__c
				where owner__r.id = :thisOwnerId and Status__c = 'Active'
			];
    	}
	}
	
	public List<Owner_Boat_Relationship__c> PreviouslyOwnedBoats {
		get {
			if (thisOwnerId == null) {
				return new List<Owner_Boat_Relationship__c>();
			}
			return [
				select
					hin_number__r.name,
					hin_number__r.color__c,
					hin_number__r.Boat_Class__c,
					hin_number__r.brand_del__c,
					hin_number__r.Model_Year__c,
					hin_number__r.Boat_Model__c,
					Purchase_Date__c,
					Status__c
				from Owner_Boat_Relationship__c
				where owner__r.id = :thisOwnerId and Status__c = 'Inactive'
			];
		}
	}
    
    public map<string,string> ownerValues{
        get{
            Account l = theOwner;
            ownerValues.put('Lead Source',l.PersonLeadSource);
            
            if(l.Lead_Form_Name__pc==null){
                ownerValues.put('Lead Form Name','null');
            }else{
                ownerValues.put('Lead Form Name',l.Lead_Form_Name__pc);
            }
            
            
            return ownerValues;
        }set;
    }
    
    public string getSelectFields(){
        list<string> fieldNames = new list<String>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            system.debug('#######' + dfield );
            fieldNames.add(dfield.getname());
        }
        String selectFields = '';
        if(!fieldNames.isEmpty()){
            selectFields = string.join(fieldNames,',');
        }
        return selectFields;
    }
}