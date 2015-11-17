public class DisplayCaseController {
 
    @AuraEnabled
    public static Case getCaseFromId(Id caseID) {
        if(caseID == null) {
            return [SELECT ID, Subject, Description, STATUS from Case LIMIT 1];
        }
        
        List<Case> cases = [ SELECT Id, Subject, Description, Status from CASE where ID = :caseID ];
        
        if(cases.size() == 0) {
            return [SELECT ID, Subject, Description, STATUS from Case LIMIT 1];
        } else {
            return cases[0];
        }        
    }
    
    
}