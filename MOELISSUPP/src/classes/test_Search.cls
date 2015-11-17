public with sharing class test_Search {
    //Object fields in global query: 
    private String AccountFldList      = 'ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name';
    private String ContactFldList      = 'ID,Name,Phone,Owner.Alias,OwnerId,Email,Account.Name,Account.ID,AccountId,ReportsToId,ReportsTo.Name';
    private String DealFldList         = 'ID,Name,Status__c,Client__r.Name,Client__c,Company_Counsel_Firm__c,Company_Counsel_Firm__r.Name,Company_Financial_Advisor_Firm__c,Company_Financial_Advisor_Firm__r.Name,Financial_Sponsor__c,Financial_Sponsor__r.Name,Lenders_Counsel_Firm__c,Lenders_Counsel_Firm__r.Name,Lenders_Financial_Advisor_Firm__c,Lenders_Financial_Advisor_Firm__r.Name,Official_Committee_Financial_Advisor__c,Official_Committee_Financial_Advisor__r.Name,Judge__c,Judge__r.Name';
    private String DealIdeaFldList     = 'ID,Name,RecordType.Name,RecordTypeId,Client__r.Name,Client__c,Category__c';
    private String EmployeeFldList     = 'ID,Name,Title__c,Speciality_Sectors__c,Office_Location__c,Last_Name__c,First_Name__c,Group__c';
    private String TargetBuyersFldList = 'ID,Name,TargetBuyer__c,TargetBuyer__r.Name';
    private String Parent_Financial_Sponsor_FldList     = 'Id,Name,Company_Name__c,Company_Name__r.Name,Financial_Sponsor_Name__c,Financial_Sponsor_Name__r.Name';	// Financial_Sponsors__c
    private String Deal_Client_Contact_FldList          = 'Id,Name,Client_Contact__c,Client_Contact__r.Name'; 							// Project_Client_Contact__c
    private String Deal_Team_FldList                    = 'Id,Name,Banker__c,Banker__r.Name';											// Project_Resource__c
    private String Deal_Related_Party_FldList           = 'Id,Name,Company__c,Company__r.Name';											// Deal_Related_Parties__c
    private String Key_Constituents_FldList             = 'Id,Name,KC_Contact__c,KC_Contact__r.Name';									// Key_Constituents__c
    private String Target_Buyer_Contacts_FldList        = 'Id,Name,Contact__c,Contact__r.Name';											// Potential_Buyer_Investor_Contact__c
    private String Deal_Idea_Client_FldList             = 'Id,Name,Client_Contact__c,Client_Contact__r.Name';							// Research_Client_Contact__c
    private String Moelis_Employee_Relationship_FldList = 'Id,Name,Company__c,Contact__c,Contact__r.Name,Employee__c,Employee__r.Name';	// Employee_Relationships__c

	private Integer ElemPerPage = 75;

	public List<Account> getAscQuery() {
		/*
		String searchQuery = 
					'FIND \''+'te*'+'\' IN ALL FIELDS RETURNING ' + 
					'Account ('+AccountFldList+' order by Name Limit '+(ElemPerPage+1)+'), ' + 
					'Contact            ('+ContactFldList+'      order by Name Limit '+(ElemPerPage+1)+') ' + 
					//'Ibanking_Project__c('+DealFldList+'         order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Employee_Profile__c('+EmployeeFldList+'     order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Potential_Buyer_Investor__c   ('+TargetBuyersFldList+' order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Financial_Sponsors__c     ('+Parent_Financial_Sponsor_FldList+' where Financial_Sponsor_Name__r.Name LIKE \'%a%\' order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Project_Client_Contact__c ('+Deal_Client_Contact_FldList+'          order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Project_Resource__c       ('+Deal_Team_FldList+'                    order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Deal_Related_Parties__c   ('+Deal_Related_Party_FldList+'           order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Potential_Buyer_Investor_Contact__c  ('+Target_Buyer_Contacts_FldList+'        order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Employee_Relationships__c ('+Moelis_Employee_Relationship_FldList+' order by Name Limit '+(ElemPerPage+1)+')'+
					'';
		List<List<sObject>> searchList = search.query(searchquery);*/
		String searchQuery;
		List<List<sObject>> searchList;
		
		searchQuery = 'FIND \''+'te*'+'\' IN ALL FIELDS RETURNING ' + 
					'Account ('+AccountFldList+' order by Name Limit '+(ElemPerPage+1)+')';
		searchList = search.query(searchQuery);
		
		List<Account> tmp = (List<Account>)searchList[0];
		/*List<List<Account>> tmp = [
			FIND 'te*'
			IN ALL FIELDS
			RETURNING Account(ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name
			order by Name Limit 40)
		];*/
		/*FIND 'te*' IN ALL FIELDS 
		RETURNING Account(ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name 
		where Name>='AECOM Technology Corporation' and ID not in ('001S000000C0e71IAB') 
		order by Name  Limit 11)];*/
		return tmp;
	}
	public List<Account> getDescQuery() {

		String searchQuery = 
					'FIND \''+'te*'+'\' IN ALL FIELDS RETURNING ' + 
					'Account ('+AccountFldList+' where Name <= \'AMERICAN SYSTEMS Corporation\' order by Name DESC Limit '+(ElemPerPage+1)+'), ' + 
					'Contact ('+ContactFldList+' where Name <= \'AMERICAN SYSTEMS Corporation\' order by Name DESC Limit '+(ElemPerPage+1)+') ' + 
					//'Ibanking_Project__c('+DealFldList+'         order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Employee_Profile__c('+EmployeeFldList+'     order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Potential_Buyer_Investor__c   ('+TargetBuyersFldList+' order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Financial_Sponsors__c     ('+Parent_Financial_Sponsor_FldList+' where Financial_Sponsor_Name__r.Name LIKE \'%a%\' order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Project_Client_Contact__c ('+Deal_Client_Contact_FldList+'          order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Project_Resource__c       ('+Deal_Team_FldList+'                    order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Deal_Related_Parties__c   ('+Deal_Related_Party_FldList+'           order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Potential_Buyer_Investor_Contact__c  ('+Target_Buyer_Contacts_FldList+'        order by Name Limit '+(ElemPerPage+1)+'), ' +
					//'Employee_Relationships__c ('+Moelis_Employee_Relationship_FldList+' order by Name Limit '+(ElemPerPage+1)+')'+
					'';
		List<List<sObject>> searchList = search.query(searchquery);
		List<Account> tmp = (List<Account>)searchList[0];

		/*List<List<Account>> tmp = [
			FIND 'te*'
			IN ALL FIELDS
			RETURNING Account(ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name
			where Name='Allied Irish Banks plc' 
			order by Name DESC Limit 15)
		];*/
		/*FIND 'te*' IN ALL FIELDS 
		RETURNING Account(ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name 
		where Name<='Ambul' and ID not in ('001S000000ETZRDIA5') 
		order by Name DESC Limit 10)];*/
		return tmp;
	}
	
	private static testmethod void test_Search_Test(){
		test_Search cls = new test_Search();
		cls.getAscQuery();
		cls.getDescQuery();
	}
}