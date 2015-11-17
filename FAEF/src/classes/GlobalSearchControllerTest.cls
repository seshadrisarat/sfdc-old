@isTest
private class GlobalSearchControllerTest {
	
	@isTest(SeeAllData=true) static void testGlobalSearchController() {
		Account a = new Account(
			name = 'Test Account'
		);
		insert a;

		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'Test',
			AccountId = a.id
		);
		insert c;
		
		ID[] fixedSearchResults = new ID[2];
		fixedSearchResults[0] = a.id;
		fixedSearchResults[1] = c.id;
		
		Test.setFixedSearchResults(fixedSearchResults);

		GlobalSearchController gsc = new GlobalSearchController();
		gsc.searchString = 'Tes';
		gsc.search();
	}
	
}