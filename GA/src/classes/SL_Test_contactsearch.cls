@isTest
private class SL_Test_contactsearch {
	
	@isTest 
	static void test_method_one()
	{
		Account a = new Account();
		a.Name = 'Test Name';

		insert a;
		
		SL_Candidate_Search__c objCandidateSearch = new SL_Candidate_Search__c(Name = 'Search', Search_Name__c = '|- 2015-09-12|test|Industry=Consulting');
		insert objCandidateSearch;
		
		Attachment objAttachment = new Attachment(Name = 'Search', Body = Blob.valueOf('[{"apiName":"Industry__c","fltVal":"Consulting","fldType":"picklist"}]'), ParentId = objCandidateSearch.Id);
		insert objAttachment;
		
		Contact c = new Contact();
		c.Function__c = 'Finance';
		c.LastName = 'Smith';
		c.Industry__c = 'Consulting';
		insert c;

		SL_ctrl_CandidateSrch cont = new SL_ctrl_CandidateSrch();
		SL_ctrl_CandidateSrch.getLkupFltrStrStatic('AccountId');
		SL_ctrl_CandidateSrch.getLkupObjStatic('AccountId');
		SL_ctrl_CandidateSrch.typeAheadFunc('Test','Account');
		SL_ctrl_CandidateSrch.queryCandidates('[{"apiName":"Function__c","fltVal":"Finance","fldType":"picklist"}]','');
		SL_ctrl_CandidateSrch.queryCandidates(NULL,objAttachment.Id);	
		SL_ctrl_CandidateSrch.getSearchCriteria();	
		SL_ctrl_CandidateSrch.substituteFieldLabels('[{"Id":"0000039333","Function__c":"Finance","Industry__c":"Consulting"}]');
	}
	
}