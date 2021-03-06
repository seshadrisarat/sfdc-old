public class caseHandler{

    public static void runCaseAssignmentRules(list<case> caseList){
        List<case> newCaseList = new List<case>();
        List<case> finalCaseList = new List<case>();
        set<id> caseIdSet = new set<id>();
        for(case c:caseList){
            caseIdSet.add(c.id);
             system.debug('@@case'+c);
        system.debug('@@origin'+c.origin);
        system.debug('@@origin'+c.IsWebOrigin__c);
        system.debug('@@origin'+c.External_Contact_Name__c);
        }
        newCaseList =[select id from case where id in:caseIdSet];
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        //dmlOpts.assignmentRuleHeader.useDefaultRule= true;
        system.debug('@@newCase AR.id'+AR.id);
        
        //Setting the DMLOption on Case instance
        for(case newCase: newCaseList){
            system.debug('@@newCase'+dmlOpts);
            newCase.setOptions(dmlOpts);
            finalCaseList.add(newCase);
        }
        update finalCaseList;
    }
    
    public static void assignRecType(list<case> newCaseList){
        for(case c:newCaseList){
        system.debug('@@case'+c);
        system.debug('@@origin'+c.origin);
        system.debug('@@origin'+c.IsWebOrigin__c);
        system.debug('@@origin'+c.External_Contact_Name__c);
        
            if(c.Origin=='Web' || c.IsWebOrigin__c==true || c.External_Contact_Name__c=='Web'){
                system.debug('@@origin'+c.IsWebOrigin__c);
                if(c.Case_Type__c=='Public Relations'){
                    c.RecordtypeId='012E00000005zDi';
                    system.debug('@@in web PR'+c.RecordtypeId);
                }
                else{
                    c.RecordtypeId='012E00000005zDj';
                    system.debug('@@in web PR Excluded'+c.RecordtypeId);
                }    
            }
            else{
                if(c.Case_Type__c=='Public Relations'){
                    c.RecordtypeId='012E00000005zDh';
                }
                else{
                    c.RecordtypeId='012E00000005zDg';
                }                
            }
        }
    }
}