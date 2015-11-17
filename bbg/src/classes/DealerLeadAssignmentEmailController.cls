public class DealerLeadAssignmentEmailController {
    public DealerLeadAssignmentEmailController(){
        s = getSelectFields();
        leadValues = new map<String,String>();
    }
    private string s;
    public final string thisLeadId{get;set;}
    
    public string selectQry{
        get{
            system.debug('SELECT Id,'+s+' FROM Lead WHERE Id = ' + thisLeadId);
            return 'SELECT Id,'+s+' FROM Lead WHERE Id = ' + thisLeadId;
        }set;
    }
    
    public Lead theLead{
        get{
            if(theLead==null){
                try{
                    return [SELECT Id, Brand_Interest__c, Brand_Code__c,
                            LeadSource,  
                            CreatedDate,
                            LastModifiedDate,
                            Lead_Form_Name__c, 
                            Type_of_Inquiry__c,
                            Name, 
                            Email, 
                            Street, 
                            City, 
                            State, 
                            PostalCode, 
                            Country, 
                            Boat_Model_Interest__c, 
                            Boat_Class_Interest__c, 
                            Boat_Category_of_Interest__c,
                            Buying_horizon__c, 
                            Email_Opt_in__c, 
                            Best_Time_to_Contact__c,
                            Monthly_Payment_Range__c, 
                            Preferred_method_of_contact__c, 
                            Best_Phone__c, 
                            MobilePhone, 
                            Phone, 
                            Home_Phone__c, 
                            Work_Phone__c, 
                            Current_Boat_Owner__c, 
                            Current_Owned_Brand__c, 
                            Current_Owned_Model__c, 
                            Current_Owned_Boat_Class__c, 
                            Currently_Owned_Year__c, 
                            Current_Monthly_Payment__c, 
                            Preference_for_New_or_Used__c, 
                            First_Time_Boat_Owner__c, 
                            Previously_Owned_Boat_Brand__c, 
                            Notes__c, 
                            Parts_Comments__c, 
                            Hull_Identification_Number_HIN__c, 
                            Spouse_Name__c, 
                            Trading_in_a_Boat__c, 
                            Trade_In_Make__c, 
                            Trade_In_Model__c, 
                            Trade_In_Year__c, 
                            Trade_In_Comments__c, 
                            pi__score__c,
                            Comments__c,
                            Event_Name__c FROM Lead WHERE Id = :thisLeadId];
                }catch(Exception e){
                    Lead l = new Lead(LeadSource='Fake Source',Lead_Form_Name__c = 'Fake Form Name');
                    return l;
                }
            }
            return theLead;
        }set;
    }
    
    public map<string,string> leadValues{
        get{
            Lead l = theLead;
            leadValues.put('Lead Source',l.LeadSource);
            
            if(l.Lead_Form_Name__c==null){
                leadValues.put('Lead Form Name','null');
            }else{
                leadValues.put('Lead Form Name',l.Lead_Form_Name__c);
            }
            
            
            return leadValues;
        }set;
    }
    
    public string getSelectFields(){
        list<string> fieldNames = new list<String>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Lead').getDescribe().fields.getMap();
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