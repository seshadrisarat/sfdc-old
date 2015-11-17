/**
 * \author Vladimir Dobrelya
 * \date Mar 14, 2014
 * \brief The test class for SL_DisplayExpenseReportPDF
 */
@isTest
private class SL_test_DisplayExpenseReportPDF {
	
	@isTest static void unitTest() {
		createData();

		ApexPages.currentPage().getParameters().put( 'id', pExpenseReport.Id );
		SL_DisplayExpenseReportPDF oController = new SL_DisplayExpenseReportPDF();
		oController = new SL_DisplayExpenseReportPDF( new ApexPages.StandardController( pExpenseReport ) );
		system.assertEquals( 1, oController.lstAtt.size() );
		system.assertEquals( pExpense.Id, oController.lstAtt.get( 0 ).Id );
		system.assertEquals( 1, oController.lstAtt.get( 0 ).attachments.size() );

		insert pNewAttachment;
		system.assertEquals( 2, SL_DisplayExpenseReportPDF.getAttachments( pExpenseReport.Id ).get( 0 ).attachments.size() );
	}
	
	private static void createData() {
		insert pProject;
		insert pProjectPermissionControl;
		insert pContactPermissionControl;
		insert pExpenseReport;
		insert pExpense;
		insert pAttachment;
	}

	private static pse__Expense__c pExpense {
		get {
			if ( pExpense == null ) {
				pExpense = new pse__Expense__c(
					pse__Amount__c = 1,
					pse__Resource__c = pContact.Id,
					pse__Description__c = 'TEST_pExpense_Description',
					pse__Expense_Report__c = pExpenseReport.Id
				);
			}
			return pExpense;
		} private set;
	}

	private static Attachment pAttachment {
		get {
			if ( pAttachment == null ) {
				pAttachment = new Attachment(
					Name = 'TEST_pAttachment',
					Body = Blob.valueOf( 'TEST_pAttachment_Body' ),
					ParentId = pExpense.Id,
					Description = 'TEST_pAttachment_Description'
				);
			}
			return pAttachment;	
		} private set;
	}

	private static Attachment pNewAttachment {
		get {
			if ( pNewAttachment == null ) {
				pNewAttachment = new Attachment(
					Name = 'TEST_pNewAttachment',
					Body = Blob.valueOf( 'TEST_pNewAttachment_Body' ),
					ParentId = pExpense.Id,
					Description = 'TEST_pNewAttachment_Description'
				);
			}
			return pNewAttachment;	
		} private set;
	}

	static pse__Proj__c pProject {
        get {
            if ( pProject == null ) {
                pProject = new pse__Proj__c(
                    Name = 'Test_pProject',
                    pse__Region__c = SL_Settings.idRegionAllSilveline,
                    pse__Is_Active__c = true
                );
            }
            return pProject;
        } private set;
    }

	private static pse__Expense_Report__c pExpenseReport {
        get {
            if ( pExpenseReport == null ) {
                pExpenseReport = new pse__Expense_Report__c(
                    pse__Project__c = pProject.Id,
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
                    pse__Resource_Role__c = 'Developer',
                    AccountId = pAccount.Id
                );
                insert pContact;
            }
            return pContact;
        }
    }

    private static pse__Permission_Control__c pContactPermissionControl {
        get {
            if ( pContactPermissionControl == null ) {
                pContactPermissionControl = new pse__Permission_Control__c(
                    pse__User__c = UserInfo.getUserId(),
                    pse__Resource__c = pContact.Id,
                    pse__Billing__c = true,
                    pse__Timecard_Entry__c = true,
                    pse__Timecard_Ops_Edit__c = true,
                    pse__Staffing__c = true,
                    pse__Resource_Request_Entry__c = true,
                    pse__Skills_And_Certifications_View__c = true,
                    pse__Skills_And_Certifications_Entry__c = true,
                    pse__Forecast_View__c = true,
                    pse__Forecast_Edit__c = true,
                    pse__View_Task_Manager__c = true,
                    pse__Expense_Entry__c = true,
                    pse__Expense_Ops_Edit__c = true,
                    pse__Invoicing__c = true,
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
                    pse__Billing__c = true,
                    pse__Timecard_Entry__c = true,
                    pse__Timecard_Ops_Edit__c = true,
                    pse__Staffing__c = true,
                    pse__Resource_Request_Entry__c = true,
                    pse__Skills_And_Certifications_View__c = true,
                    pse__Skills_And_Certifications_Entry__c = true,
                    pse__Forecast_View__c = true,
                    pse__Forecast_Edit__c = true,
                    pse__View_Task_Manager__c = true,
                    pse__Expense_Entry__c = true,
                    pse__Expense_Ops_Edit__c = true,
                    pse__Invoicing__c = true,
                    pse__Cascading_Permission__c = true
                );
            }
            return pProjectPermissionControl;
        } set;
    }
}