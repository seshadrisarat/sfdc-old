public class QuickAddContactController {
    public Contact cInput { get; private set; }
    public Account aInput { get; private set; }
    private RecordType prospectType;
    
    public QuickAddContactController() {
        cInput = new Contact();
        aInput = new Account();
        
        prospectType = [SELECT ID, DeveloperName, Name FROM RecordType WHERE DeveloperName = 'DealCompany' AND SobjectType = 'Account' AND IsActive=TRUE LIMIT 1];
    }
    
    public PageReference save() {
        PageReference ref;
        
        SavePoint sp = Database.setSavePoint();
        
        try {
            for (Account a : [SELECT ID, Name FROM Account WHERE Name = :aInput.Name LIMIT 1]) {
                aInput = a;
            }
            
            if (aInput.Id == null) {
                aInput.RecordTypeId = prospectType.Id;
                aInput.Status__c = null;
                aInput.Phone = cInput.Phone;
                insert aInput;
            }
            
            if (cInput.LastName != null) {
                cInput.AccountId = aInput.Id;
                insert cInput;

                ref = new PageReference('/' + cInput.Id);
            }
        } catch (Exception e) {
            ApexPAges.addMessages(e);
            Database.rollback(sp);
            return null;
        }
        
        return ref;
    }   

    public String getAutoCompleteList() {
        
        String AC_LIST = '';
        
        if(System.currentPageReference().getParameters().get('s') != null && System.currentPageReference().getParameters().get('objectname') != null) { 
    
            String sobjectname = System.currentPageReference().getParameters().get('objectname');
            String stext = '%'+String.escapeSingleQuotes(System.currentPageReference().getParameters().get('s').trim())+'%';
                
            Integer iLimit = 15;
            
            if(stext.length() > 1){
                try{
                    String sql = 'select Id, Name from ' + sobjectname + ' where name like \''+stext+'\'';
                    if(sobjectname == 'Account') sql = sql + ' AND IsDeleted=FALSE ';
                    sql = sql + ' limit '+ iLimit;
                    
                    for(sobject x : Database.query(sql)){
                        String s  = String.escapeSingleQuotes(((String)(x.get('name'))));
                        AC_LIST = AC_LIST + s+', ';
                    }
                    
                }catch(Exception e){
                    AC_LIST = 'Unexpected Error, please contact support';    
                }
            } 
        }
        
        return AC_LIST;         
    }

    static testMethod void testQuickAddContact() {
        QuickAddContactController controller = new QuickAddContactController();
        controller.aInput.Name = 'Name';
        controller.cInput.LastName = 'Last Name';
        controller.save();

		controller = new QuickAddContactController();
        controller.aInput.Name = 'Name';
        controller.cInput.LastName = 'Last Name 2';
        controller.save();
        
    	ApexPages.currentPage().getParameters().put('s','test');
    	ApexPages.currentPage().getParameters().put('objectname','Account');
    	controller.getAutoCompleteList();
    }
}