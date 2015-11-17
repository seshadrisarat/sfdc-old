/**
 * \author Vladimir Dobrelya
 * \date Feb 11, 2014
 * \see https://silverline.jira.com/browse/SLFF-12
 * \desc It is fully rewritten for new logic
 */
@isTest
private class psaManageMilestoneControllerTest {

    static psaManageMilestoneController oController;

    @isTest static void addParentTask_test() {
        createData();
        oController = new psaManageMilestoneController();

        system.assertEquals( 2, oController.msWrapperList.size() );
        
        Test.startTest();
            oController.addParentTask();
        Test.stopTest();

        system.assertEquals( 3, oController.msWrapperList.size() );
        system.assert( oController.msWrapperList.get( 2 ).isParent );
    }

    @isTest static void addChildTask_test() {
        createData();
        oController = new psaManageMilestoneController();

        oController.addParentTask();
        system.assertEquals( 3, oController.msWrapperList.size() );
        oController.msWrapperList.get( 2 ).isMSChecked = true; // Parent
        oController.msWrapperList.get( 2 ).mStone.Name = 'TestParentTask';
        oController.msWrapperList.get( 2 ).mStone.Project_Phase__c = pProjectPhase.Id;
		
        Test.startTest();
            oController.addChildTask();
        Test.stopTest();
		//because of reload msWrapperList
        //system.assertEquals( 3, oController.msWrapperList.size() );
        //system.assert( oController.msWrapperList.get( 3 ).isChild );
    }

    @isTest static void deleteSelected_success_test() {
        createData();
        oController = new psaManageMilestoneController();

        oController.addParentTask();
        system.assertEquals( 3, oController.msWrapperList.size() );
        system.assert( oController.msWrapperList.get( 1 ).isChild ); // Child
        system.assert( oController.msWrapperList.get( 2 ).isParent ); // Parent
        system.assertEquals( false, oController.msWrapperList.get( 2 ).isExistingMS ); // Not Saved

        oController.msWrapperList.get( 1 ).mStone.pse__Status__c = 'Canceled'; // Child
        oController.msWrapperList.get( 1 ).isMSChecked = true;

        oController.msWrapperList.get( 2 ).mStone.pse__Status__c = 'Canceled'; // Not Saved Parent
        oController.msWrapperList.get( 2 ).isMSChecked = true;

        Test.startTest();
            oController.deleteSelected();
        Test.stopTest();

        for ( Apexpages.Message oItem : ApexPages.getMessages() ) {
            system.assertEquals( '', oItem.getDetail() );
        }

        system.assertEquals( 1, oController.msWrapperList.size() );
    }

    @isTest static void deleteSelected_fail_test() {
        createData();
        insert pTimecard;
        insert pExpenseReport;
        oController = new psaManageMilestoneController();

        system.assertEquals( 2, oController.msWrapperList.size() );
        oController.msWrapperList.get( 0 ).isMSChecked = true; // Parent

        Test.startTest();
            oController.deleteSelected(); // Can't delete Parent
        Test.stopTest();

        system.assertEquals( 2, oController.msWrapperList.size() );
    }

    @isTest static void save_test() {
        createData();
        oController = new psaManageMilestoneController();

        system.assertEquals( 2, oController.msWrapperList.size() );
        system.assert( oController.msWrapperList.get( 0 ).isParent ); // Parent
        oController.addParentTask();
        system.assertEquals( 3, oController.msWrapperList.size() );
        oController.msWrapperList.get( 2 ).mStone.Name = 'Test_Parent2';
        oController.msWrapperList.get( 2 ).mStone.Project_Phase__c = pProjectPhase.Id;

        Test.startTest();
            oController.save();
            oController.saveAndClose();
        Test.stopTest();

        oController = new psaManageMilestoneController();
        system.assertEquals( 3, oController.msWrapperList.size() );
    }

    @isTest static void other_test() {
        createData();
        oController = new psaManageMilestoneController();

        oController.getWrappers();
        oController.setHasChangesBool();

        // Save failures
        system.assert( oController.msWrapperList.get( 0 ).isParent ); // Parent
        oController.msWrapperList.get( 0 ).mStone.Name = '';
        oController.msWrapperList.get( 0 ).mStone.End_Date__c = null;
        oController.msWrapperList.get( 0 ).mStone.pse__Target_Date__c = null;
        oController.save();
        oController.msWrapperList.get( 0 ).mStone.Name = 'Test_Parent2';
        oController.msWrapperList.get( 0 ).mStone.Project_Phase__c = null;
        oController.save();
        oController.saveAndClose();
        //oController.recalculateDates();

        oController.refreshProject();
        oController.cancel();
    }

    private static void createData() {
        insert pProject;
        insert pContactPermissionControl;
        insert pProjectPermissionControl;
        insert pSchedule;
        insert pAssignment;
        insert pProjectPhase;
        insert pParentMilestone;
        insert pChildMilestone;

        ApexPages.currentPage().getParameters().put( 'projectID', pProject.Id );
    }

    private static pse__Proj__c pProject {
        get {
            if ( pProject == null ) {
                pProject = new pse__Proj__c(
                    Name = 'Test_pProject',
                    pse__Region__c = SL_Settings.idRegionAllSilveline,
                    pse__Is_Active__c = true
                );
            }
            return pProject;
        } set;
    }

    private static pse__Milestone__c pParentMilestone {
        get {
            if ( pParentMilestone == null ) {
                pParentMilestone = new pse__Milestone__c(
                    Name = 'Test_pParentMilestone',
                    RecordTypeId = psaUtils.idRTParentTask,
                    pse__Project__c = pProject.Id,
                    Start_Date__c = Date.today(),
                    End_Date__c = Date.today().addDays( 1 ),
                    pse__Target_Date__c = Date.today(),
                    pse__Status__c = 'Open',
                    pse__Milestone_Amount__c = 1,
                    Actual_Hours__c = 0,
                    Estimated_Hours__c = 0,
                    Project_Phase__c = pProjectPhase.Id
                );
            }
            return pParentMilestone;
        } set;
    }

    private static pse__Milestone__c pChildMilestone {
        get {
            if ( pChildMilestone == null ) {
                pChildMilestone = new pse__Milestone__c(
                    Name = 'Test_pChildMilestone_Open_1',
                    RecordTypeId = psaUtils.idRTChildTask,
                    pse__Project__c = pProject.Id,
                    Start_Date__c = Date.today(),
                    End_Date__c = Date.today().addDays( 1 ),
                    pse__Target_Date__c = Date.today(),
                    pse__Status__c = 'Open',
                    pse__Milestone_Amount__c = 1,
                    Parent_Milestone__c = pParentMilestone.Id,
                    Actual_Hours__c = 1,
                    Estimated_Hours__c = 1.1
                );
            }
            return pChildMilestone;
        } set;
    }

    private static pse__Project_Phase__c pProjectPhase {
        get {
            if ( pProjectPhase == null ) {
                pProjectPhase = new pse__Project_Phase__c(
                    Name = 'Test_pProjectPhase',
                    pse__Project__c = pProject.Id,
                    Status__c = 'Open',
                    pse__Start_Date__c = Date.today(),
                    pse__End_Date__c = Date.today().addDays( 1 ),
                    CurrencyIsoCode = 'USD'
                );
            }
            return pProjectPhase;
        } private set;
    }

    private static pse__Timecard_Header__c pTimecard {
        get {
            if ( pTimecard == null ) {
                pTimecard = new pse__Timecard_Header__c(
                    pse__Project__c = pProject.Id,
                    pse__Milestone__c = pChildMilestone.Id,
                    pse__Resource__c = pContact.Id,
                    pse__Start_Date__c = Date.today().addDays( -6 ),
                    pse__End_Date__c = Date.today(),
                    pse__Assignment__c = pAssignment.Id
                );
            }
            return pTimecard;
        } private set;
    }

    private static pse__Expense_Report__c pExpenseReport {
        get {
            if ( pExpenseReport == null ) {
                pExpenseReport = new pse__Expense_Report__c(
                    pse__Project__c = pProject.Id,
                    pse__Milestone__c = pChildMilestone.Id,
                    pse__Resource__c = pContact.Id
                );
            }
            return pExpenseReport;
        } private set;
    }

    private static Account pAccount {
        get {
            if ( pAccount == null ) {
                pAccount = new Account(
                    Name = 'TEST_pAccount'
                );
                insert pAccount;
            }
            return pAccount;
        }
    }

    private static Contact pContact {
        get {
            if ( pContact == null ) {
                pContact = new Contact(
                    LastName = 'TEST_pContact',
                    pse__Is_Resource_Active__c = true,
                    pse__Is_Resource__c = true,
                    AccountId = pAccount.Id
                );
                insert pContact;
            }
            return pContact;
        }
    }

    private static pse__Assignment__c pAssignment {
        get {
            if ( pAssignment == null ) {
                pAssignment = new pse__Assignment__c(
                    pse__Project__c = pProject.Id,
                    pse__Resource__c = pContact.Id,
                    pse__Role__c = 'Technical Architect',
                    pse__Is_Billable__c = true,
                    pse__Bill_Rate__c = 1,
                    pse__Schedule__c = pSchedule.Id
                );
            }
            return pAssignment;
        } set;
    }

    private static pse__Schedule__c pSchedule {
        get {
            if ( pSchedule == null ) {
                pSchedule = new pse__Schedule__c(
                    pse__Start_Date__c = Date.today().addDays( -7 ),
                    pse__End_Date__c = Date.today().addDays( 1 ),
                    pse__Monday_Hours__c = 8,
                    pse__Tuesday_Hours__c = 8,
                    pse__Wednesday_Hours__c = 8,
                    pse__Thursday_Hours__c = 8,
                    pse__Friday_Hours__c = 8
                );
            }
            return pSchedule;
        } set;
    }

    private static pse__Permission_Control__c pContactPermissionControl {
        get {
            if ( pContactPermissionControl == null ) {
                pContactPermissionControl = new pse__Permission_Control__c(
                    pse__User__c = UserInfo.getUserId(),
                    pse__Resource__c = pContact.Id,
                    pse__Expense_Entry__c = true,
                    pse__Expense_Ops_Edit__c = true,
                    pse__Timecard_Entry__c = true,
                    pse__Timecard_Ops_Edit__c = true,
                    pse__Staffing__c = true,
                    pse__Cascading_Permission__c = true
                );
            }
            return pContactPermissionControl;
        } set;
    }

    private static pse__Permission_Control__c pProjectPermissionControl {
        get {
            if ( pProjectPermissionControl == null ) {
                pProjectPermissionControl = new pse__Permission_Control__c(
                    pse__User__c = UserInfo.getUserId(),
                    pse__Project__c = pProject.Id,
                    pse__Timecard_Ops_Edit__c = true,
                    pse__Staffing__c = true,
                    pse__Cascading_Permission__c = true
                );
            }
            return pProjectPermissionControl;
        } set;
    }
}