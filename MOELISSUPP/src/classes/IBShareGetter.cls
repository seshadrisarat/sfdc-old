public class IBShareGetter {

    public string getSharesStr(list<Project_Resource__c> teamsList) {
        List<Ibanking_Project__Share> lShares = new List<Ibanking_Project__Share>();
        
        string sQuery;
        if (teamsList.size()>0) {
            system.debug('debug (0): ' + teamsList.get(0));
            sQuery = '(ParentId = \''+teamsList.get(0).Project__c+'\' and UserOrGroupId = \''+teamsList.get(0).Banker__r.User_Id__c+'\')';
        }
        
        for (integer i = 1; i<teamsList.size(); i++) {
            sQuery += ' or (ParentId = \''+teamsList.get(i).Project__r.id+'\' and UserOrGroupId = \''+teamsList.get(i).Banker__r.User_Id__c+'\')';
        }
        
        return sQuery;
    }
    
    public testMethod static void testThis() {
    	Project_Resource__c pr = new Project_Resource__c();
//    	insert pr;
    	List<Project_Resource__c> prList = new List<Project_Resource__c>();
    	prList.add(pr);
    	
    	
    	IBShareGetter share = new IBShareGetter();
    	share.getSharesStr(prList);
    }
}