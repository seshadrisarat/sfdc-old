@isTest
private class Test_SL_MassEdit {
    public class Controller extends SL_MassEdit {
        public override Boolean castAndSave(List<SObject> lst) {
            return true;
        }
        public override SObject getNewTargetObject() {
            return new Contact();
        }
        public override List<LookUpPickListValue> getCustomPicklistValues(String parentId, String picklistName)
        {
            return new List<LookUpPickListValue>();
        }
    
        public Controller() {
            super();
            sortExpression = 'Name'; 
            targetObjectName = 'Contact';
            targetObjectParentFieldName = 'AccountId';
            String pId = ApexPages.currentPage().getParameters().get('accId');
            parentObject = [SELECT Id, Name FROM Account WHERE Id = :pId];
            parentObjectName = 'Account';
            fieldNamesNotColumns = new List<String> {'AccountId', 'Account.RecordTypeId'};
            fieldNamesNotNulls = new List<String> {'AccountId'};
            columns = new List<ColumnInfo>{
                 new ColumnInfo('Name','Name','Name',true,true)
                ,new ColumnInfo('FirstName','FirstName','FirstName',true,true)
                ,new ColumnInfo('Account.Name','Account.Name','Account.Name',true,true)
            };
            refetchColumnHeaders();
            refetchMembers();
        }
    }

    public static testMethod void testMethod1() {
        Account acc = new Account(Name = 'TestAcc1');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Test');
        insert contact;
        Contact contact2 = new Contact(AccountId=acc.Id, FirstName='Test2', LastName='Test2');
        insert contact2;
        Contact contact3 = new Contact(AccountId=acc.Id, FirstName='Test0', LastName='Test0');
        insert contact3;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accId', ''+acc.Id);
        Controller controller = new Controller();
        
        system.debug('==== compareField(1,2) ==== >>>> '+controller.compareField('1','2'));
        system.debug('==== getField ==== >>>> '+controller.getField(contact, 'Account.Name'));
        
        controller.sortDirection = 'DESC';
        controller.sortExpression = 'FirstName';
        controller.changeSorting();
        controller.voidAction();
        controller.getLimits();
        
        controller.startEdit();
        controller.stopEdit();
        //controller.save();
        controller.saveClose();
        
        controller.getColumnsShown();
        controller.getUnselectedColumns();
        controller.getSelectColumns();
        controller.saveColumns('Name;FirstName;Account.Name');
        controller.getSelectColumnsOrdered();
        //controller.loadColumnOrder();
        
        controller.getColumnPermutation();
        
        controller.cb_columns = 'Name;FirstName;Account.Name';
        controller.cb_filters = 'REFERENCE___AccountId___equal___ABS Capital Partners___000000000000000##REFERENCE___AccountId___equal___ABS Capital Partners___001P0000003pJmH';
        controller.cb_advfilters = '1 AND 2';
        controller.saveColumnsFilters();

        controller.cb_filters = 'REFERENCE___AccountId___notequal___ABS Capital Partners___000000000000000##REFERENCE___AccountId___notequal___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___lessThan___ABS Capital Partners___000000000000000##REFERENCE___AccountId___lessThan___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___greaterThan___ABS Capital Partners___000000000000000##REFERENCE___AccountId___greaterThan___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___lessOrEqual___ABS Capital Partners___000000000000000##REFERENCE___AccountId___lessOrEqual___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___greaterOrEqual___ABS Capital Partners___000000000000000##REFERENCE___AccountId___greaterOrEqual___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___startsWith___ABS Capital Partners___000000000000000##REFERENCE___AccountId___startsWith___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___contains___ABS Capital Partners___000000000000000##REFERENCE___AccountId___contains___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___notContain___ABS Capital Partners___000000000000000##REFERENCE___AccountId___notContain___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___includes___ABS Capital Partners___000000000000000##REFERENCE___AccountId___includes___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        controller.cb_filters = 'REFERENCE___AccountId___excludes___ABS Capital Partners___000000000000000##REFERENCE___AccountId___excludes___ABS Capital Partners___001P0000003pJmH';
        controller.saveColumnsFilters();
        
        controller.getFiltersJSON();
        controller.getFiltersString();
        String s;
        s = controller.target;
        s = controller.event;
        s = controller.picklistName;
        ApexPages.currentPage().getParameters().put('event', 'load');
        ApexPages.currentPage().getParameters().put('target', 'Contact');
        controller.EventHandler();
        
        ApexPages.currentPage().getParameters().put('picklist', 'leadsource');
        controller.EventHandler();
        controller.getLCPickListValue();
        ApexPages.currentPage().getParameters().put('picklist', 'recordtypeid');
        controller.getLCPickListValue();
        
        //controller.isEqual(new List<Integer>{1, 2, 3}, new List<Integer>{1, 2, 3});
        
        system.debug('============================= membersCount: ' + controller.membersList.size());
        controller.sortDirection = 'DESC';
        controller.sortExpression = 'FirstName';
        controller.changeSorting();
        
        controller.getCompiledQuery();
        controller.selectedColumnsCallback = 'Id;Name;FirstName';
        controller.refetchMembers();
        
        controller.fillDescribe();
        //controller.saveSelectedColumns();
        system.debug('==== compareField(1,2) ==== >>>> '+controller.compareField('1','2'));
        
        controller.changeSorting();
        controller.changeSorting();
        controller.voidAction();
        controller.getLimits();
        controller.selectedColumnsCallback = 'Name';
        
        controller.refetchMembers();
        controller.save();
        controller.saveClose();
        SL_MassEdit.PermutationInfo pInfo = new SL_MassEdit.PermutationInfo(1,2);
        
        controller.startEdit();
        controller.getSelectColumns();
        controller.stopEdit();
        Test.stopTest();
    }

    public static testMethod void testMethod2() { //With invalid data
        Account acc = new Account(Name = 'TestAcc1');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Test');
        insert contact;
        Contact contact2 = new Contact(AccountId=acc.Id, FirstName='Test2', LastName='Test2');
        insert contact2;
        Contact contact3 = new Contact(AccountId=acc.Id, FirstName='Test0', LastName='Test0');
        insert contact3;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('accId', ''+acc.Id);
        Controller controller = new Controller();
        
        controller.getSelectColumns();
        //controller.getSelectColumnsOrdered();
        controller.saveColumns('Name');
        //controller.loadColumnOrder();     
        
        Test.stopTest();
    }
}