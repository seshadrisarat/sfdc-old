@isTest
private class SL_PrintInvoiceTest {
	
	@isTest static void test_method_one() {
		Account acc = new Account(Name='blala');
		insert acc;
		Opportunity opp = new Opportunity(Projected_Start_Date__c=Date.today().addMonths(2),AccountId = acc.Id, Name='blabla', CloseDate=Date.today(), StageName='Closed Won');
		insert opp;
		Contact c = new Contact(AccountId = acc.Id, LastName='Test', email='d@silverlinecrm.com');
		insert c;

		AccountContactRole ocr = new AccountContactRole(AccountId=acc.Id);
		ocr.ContactId = c.Id;
		ocr.Role = 'AP';
		insert ocr;
		pse__Proj__c pProject = new pse__Proj__c(
                    Name = 'Test_pProject',
                    pse__Region__c = SL_Settings.idRegionAllSilveline,
                    pse__Is_Active__c = true
                );
		insert pProject;

		Invoice__c inv = new Invoice__c();
		inv.PSA_Project__c = pProject.Id;
		inv.Client__c = acc.Id;
		insert inv;
		Slip__c slip = new Slip__c(Invoice__c = inv.Id);
		insert slip;
		ob1__output_template__c ot = new ob1__output_template__c(
			ob1__template_class__c = 'Service',
			Name = 'Service',
			ob1__Content_Type__c = 'pdf' ,
			ob1__Object_Name__c = 'Invoice__c'

		);
		insert ot;
		system.debug(ot);

		Test.startTest();
		ApexPages.currentPage().getParameters().put( 'role', 'AP' );
		ApexPages.currentPage().getParameters().put( 'id', inv.Id );
		ApexPages.currentPage().getParameters().put( 'oppId', opp.Id );
		ApexPages.currentPage().getParameters().put( 'class', 'Service' );

		SL_PrintInvoice oController = new SL_PrintInvoice();
		oController = new SL_PrintInvoice(   );
		oController.htmlIn = '<div>blah</div>';
		oController.template = 'Service';
		oController.createOutputHistory();
		system.debug(oController.outputHistory);
		oController.send();
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
 
}