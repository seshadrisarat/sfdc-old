/*
 * \author Vladimir Dobrelya
 * \date Feb 06, 2014
 * \see https://silverline.jira.com/browse/SLFF-18
 */
@isTest
public class psaProjectRefeshTest {
	
	@isTest static void psaRefreshProject_UnitTest() {
		createData();

		Test.startTest();
			psaProjectRefesh.refreshProject( pProject.Id );
		Test.stopTest();
		
		doAsserts();
	}
	
	public static void createData() {
		insert pProject;
		insert pParentMilestone;
		insert new List<pse__Milestone__c>{
			pChildMilestone_Open_1,
			pChildMilestone_Open_2,
			pChildMilestone_Canceled,
			pParentMilestoneWithoutChild
		};
	}

	public static void doAsserts() {
		refreshNeededData();

		system.assertNotEquals( pParentMilestone.Actual_Hours__c, pChildMilestone_Open_1.Actual_Hours__c + pChildMilestone_Open_2.Actual_Hours__c + pChildMilestone_Canceled.Actual_Hours__c );
		system.assertNotEquals( pParentMilestone.Estimated_Hours__c, pChildMilestone_Open_1.Estimated_Hours__c + pChildMilestone_Open_2.Estimated_Hours__c + pChildMilestone_Canceled.Estimated_Hours__c );

		system.assertEquals( pParentMilestone.Actual_Hours__c, pChildMilestone_Open_1.Actual_Hours__c + pChildMilestone_Open_2.Actual_Hours__c );
		system.assertEquals( pParentMilestone.Estimated_Hours__c, pChildMilestone_Open_1.Estimated_Hours__c + pChildMilestone_Open_2.Estimated_Hours__c );
		
		system.assertEquals( pProject.Actual_Hours__c, pParentMilestone.Actual_Hours__c );
		//system.assertEquals( pProject.Estimated_Hours__c, pParentMilestone.Estimated_Hours__c );
		system.assertEquals( pProject.Estimated_Hours__c, pChildMilestone_Open_1.Estimated_Hours__c + pChildMilestone_Open_2.Estimated_Hours__c);

		system.assertEquals( pParentMilestoneWithoutChild.Actual_Hours__c, 0 );
		system.assertEquals( pParentMilestoneWithoutChild.Estimated_Hours__c, 0 );
	}

	private static void refreshNeededData() {
		pProject = [ SELECT Actual_Hours__c, Estimated_Hours__c FROM pse__Proj__c WHERE Id = :pProject.Id ];
		pParentMilestone = [ SELECT Actual_Hours__c, Estimated_Hours__c FROM pse__Milestone__c WHERE Id = :pParentMilestone.Id ];
		pParentMilestoneWithoutChild = [ SELECT Actual_Hours__c, Estimated_Hours__c FROM pse__Milestone__c WHERE Id = :pParentMilestoneWithoutChild.Id ];
	}

	private static pse__Proj__c pProject {
		get {
			if ( pProject == null ) {
				pProject = new pse__Proj__c(
					Name = 'Test_pProject',
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
					Estimated_Hours__c = 0
				);
			}
			return pParentMilestone;
		} set;
	}

	private static pse__Milestone__c pParentMilestoneWithoutChild {
		get {
			if ( pParentMilestoneWithoutChild == null ) {
				pParentMilestoneWithoutChild = new pse__Milestone__c(
					Name = 'Test_pParentMilestoneWithoutChild',
					RecordTypeId = psaUtils.idRTParentTask,
					pse__Project__c = pProject.Id,
					Start_Date__c = Date.today(),
					End_Date__c = Date.today().addDays( 1 ),
					pse__Target_Date__c = Date.today(),
					pse__Status__c = 'Open',
					pse__Milestone_Amount__c = 1,
					Actual_Hours__c = 1,
					Estimated_Hours__c = 1
				);
			}
			return pParentMilestoneWithoutChild;
		} set;
	}

	private static pse__Milestone__c pChildMilestone_Open_1 {
		get {
			if ( pChildMilestone_Open_1 == null ) {
				pChildMilestone_Open_1 = new pse__Milestone__c(
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
			return pChildMilestone_Open_1;
		} set;
	}

	private static pse__Milestone__c pChildMilestone_Open_2 {
		get {
			if ( pChildMilestone_Open_2 == null ) {
				pChildMilestone_Open_2 = new pse__Milestone__c(
					Name = 'Test_pChildMilestone_Open_2',
					RecordTypeId = psaUtils.idRTChildTask,
					pse__Project__c = pProject.Id,
					Start_Date__c = Date.today(),
					End_Date__c = Date.today().addDays( 1 ),
					pse__Target_Date__c = Date.today(),
					pse__Status__c = 'Open',
					pse__Milestone_Amount__c = 1,
					Parent_Milestone__c = pParentMilestone.Id,
					Actual_Hours__c = 2,
					Estimated_Hours__c = 2.2
				);
			}
			return pChildMilestone_Open_2;
		} set;
	}

	private static pse__Milestone__c pChildMilestone_Canceled {
		get {
			if ( pChildMilestone_Canceled == null ) {
				pChildMilestone_Canceled = new pse__Milestone__c(
					Name = 'Test_pChildMilestone_Canceled',
					RecordTypeId = psaUtils.idRTChildTask,
					pse__Project__c = pProject.Id,
					Start_Date__c = Date.today(),
					End_Date__c = Date.today().addDays( 1 ),
					pse__Target_Date__c = Date.today(),
					pse__Status__c = 'Canceled',
					pse__Milestone_Amount__c = 1,
					Parent_Milestone__c = pParentMilestone.Id,
					Actual_Hours__c = 10,
					Estimated_Hours__c = 10.10
				);
			}
			return pChildMilestone_Canceled;
		} set;
	}
}