/*

Modified: Privlad 02/23/2010 - task: 956

*/
public class SSearch_Additional {


    //Object fields in global query:
    private static String AccountFldList      = 'ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name';
    private static String ContactFldList      = 'ID,Name,Phone,Owner.Alias,OwnerId,Email,Account.Name,Account.ID,AccountId,ReportsToId,ReportsTo.Name';
    private static String DealFldList         = 'ID,Name,Status__c,Client__r.Name,Client__c,Company_Counsel_Firm__c,Company_Counsel_Firm__r.Name,Company_Financial_Advisor_Firm__c,Company_Financial_Advisor_Firm__r.Name,Financial_Sponsor__c,Financial_Sponsor__r.Name,Lenders_Counsel_Firm__c,Lenders_Counsel_Firm__r.Name,Lenders_Financial_Advisor_Firm__c,Lenders_Financial_Advisor_Firm__r.Name,Official_Committee_Financial_Advisor__c,Official_Committee_Financial_Advisor__r.Name,Judge__c,Judge__r.Name';
    private static String DealIdeaFldList     = 'ID,Name,RecordType.Name,RecordTypeId,Client__r.Name,Client__c,Category__c';
    private static String EmployeeFldList     = 'ID,Name,Title__c,Speciality_Sectors__c,Office_Location__c,Last_Name__c,First_Name__c,Group__c';
    private static String TargetBuyersFldList = 'ID,Name,TargetBuyer__c,TargetBuyer__r.Name';
    
    private static String Parent_Financial_Sponsor_FldList     = 'Id,Name,Company_Name__c,Company_Name__r.Name,Financial_Sponsor_Name__c,Financial_Sponsor_Name__r.Name';	// Financial_Sponsors__c
    private static String Deal_Client_Contact_FldList          = 'Id,Name,Client_Contact__c,Client_Contact__r.Name'; 									// Project_Client_Contact__c
    private static String Deal_Team_FldList                    = 'Id,Name,Banker__c,Banker__r.Name';																// Project_Resource__c
    private static String Deal_Related_Party_FldList           = 'Id,Name,Company__c,Company__r.Name';													// Deal_Related_Parties__c
    private static String Key_Constituents_FldList             = 'Id,Name,KC_Contact__c,KC_Contact__r.Name';												// Key_Constituents__c
    private static String Target_Buyer_Contacts_FldList        = 'Id,Name,Contact__c,Contact__r.Name';												// Target_Buyer_Contacts__c
    private static String Deal_Idea_Client_FldList             = 'Id,Name,Client_Contact__c,Client_Contact__r.Name';										// Research_Client_Contact__c
    private static String Moelis_Employee_Relationship_FldList = 'Id,Name,Company__c,Contact__c,Contact__r.Name,Employee__c,Employee__r.Name';	// Employee_Relationships__c

	
	 
	public static String getSearchQuery(String SearchTxt, Integer ElemPerPage, String orderedBy, String asc_desc) {
		String searchQuery = 
			//'FIND {' + SearchTxt + '} IN ALL FIELDS RETURNING ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
			'Account (' + AccountFldList+ ' order by Name '+(orderedBy=='Account' ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
			'Contact            (' + ContactFldList+     ' order by Name '+(orderedBy=='Contact'            ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
			'Ibanking_Project__c(' + DealFldList+        ' order by Name '+(orderedBy=='Ibanking_Project__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
			'Employee_Profile__c(' + EmployeeFldList+    ' order by Name '+(orderedBy=='Employee_Profile__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
			'Potential_Buyer_Investor__c   (' + TargetBuyersFldList+' order by Name '+(orderedBy=='Potential_Buyer_Investor__c'   ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +

			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
	   		'Financial_Sponsors__c     (' + Parent_Financial_Sponsor_FldList+    ' order by Name '+(orderedBy=='Financial_Sponsors__c'     ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
    		'Project_Client_Contact__c (' + Deal_Client_Contact_FldList+         ' order by Name '+(orderedBy=='Project_Client_Contact__c' ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
    		'Project_Resource__c       (' + Deal_Team_FldList+                   ' order by Name '+(orderedBy=='Project_Resource__c'       ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
       		'Deal_Related_Parties__c   (' + Deal_Related_Party_FldList+          ' order by Name '+(orderedBy=='Deal_Related_Parties__c'   ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
       		'Potential_Buyer_Investor_Contact__c  (' + Target_Buyer_Contacts_FldList+       ' order by Name '+(orderedBy=='Target_Buyer_Contacts__c'  ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ' +
			'FIND  \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' +
       		'Employee_Relationships__c (' + Moelis_Employee_Relationship_FldList+' order by Name '+(orderedBy=='Employee_Relationships__c' ?asc_desc:'')+' Limit '+(ElemPerPage+1)+')';
       	return searchQuery;
	}


	public static String getSearchQueryWhere(String SearchTxt, Integer ElemPerPage, String orderedBy, String asc_desc, String CurObjName, String CurObjID) {
		if (CurObjName == null) {CurObjName = '';}
		CurObjName = CurObjName.replaceAll('\'', '\\\\\'');
		//String searchQuery = 'FIND {'+SearchTxt+'} IN ALL FIELDS RETURNING ';
		String searchQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';

			searchQuery += 'Account('+AccountFldList;
			if (orderedBy=='Account') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Account'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';
			
			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Contact('+ContactFldList;
			if (orderedBy=='Contact') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Contact'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Ibanking_Project__c('+DealFldList;
			//if (orderedBy=='Ibanking_Project__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			if (orderedBy=='Ibanking_Project__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Ibanking_Project__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';
			
			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Employee_Profile__c('+EmployeeFldList;
			if (orderedBy=='Employee_Profile__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Employee_Profile__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Potential_Buyer_Investor__c('+TargetBuyersFldList;
			if (orderedBy=='Potential_Buyer_Investor__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Potential_Buyer_Investor__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';




			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Financial_Sponsors__c('+Parent_Financial_Sponsor_FldList;
			if (orderedBy=='Financial_Sponsors__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Financial_Sponsors__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Project_Client_Contact__c('+Deal_Client_Contact_FldList;
			if (orderedBy=='Project_Client_Contact__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Project_Client_Contact__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Project_Resource__c('+Deal_Team_FldList;
			if (orderedBy=='Project_Resource__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Project_Resource__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Deal_Related_Parties__c('+Deal_Related_Party_FldList;
			if (orderedBy=='Deal_Related_Parties__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Deal_Related_Parties__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Potential_Buyer_Investor_Contact__c('+Target_Buyer_Contacts_FldList;
			if (orderedBy=='Target_Buyer_Contacts__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Target_Buyer_Contacts__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Employee_Relationships__c('+Moelis_Employee_Relationship_FldList;
			if (orderedBy=='Employee_Relationships__c') searchQuery += getWhere(asc_desc, CurObjName, CurObjID);
			searchQuery += ' order by Name '+(orderedBy=='Employee_Relationships__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')';
//system.debug('searchQuery from getSearchQueryWhere ***********************------------------>'+searchQuery);

			//system.debug('Search query >>>>>>>>>>>>>>>>>>>>>>>>>>> '+searchQuery);
		
		return searchQuery;
	}
	

	private static String getWhere(String asc_desc, String CurObjName, String CurObjID) {
		return ' where Name' + (asc_desc=='DESC'?'<':'>') + '=\'' + CurObjName + '\' and ID not in (\'' + CurObjID + '\')';
	}


	public static String getSearchQueryWhereIn(String SearchTxt, Integer ElemPerPage, String orderedBy, String asc_desc, String sddSQL) {
		//String searchQuery = 'FIND {'+SearchTxt+'} IN ALL FIELDS RETURNING ';
		String searchQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			
			searchQuery += 'Account('+AccountFldList;
			if (orderedBy=='Account') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Account'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Contact('+ContactFldList;
			if (orderedBy=='Contact') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Contact'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Ibanking_Project__c('+DealFldList;
			if (orderedBy=='Ibanking_Project__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Ibanking_Project__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Employee_Profile__c('+EmployeeFldList;
			if (orderedBy=='Employee_Profile__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Employee_Profile__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Potential_Buyer_Investor__c('+TargetBuyersFldList;
			if (orderedBy=='Potential_Buyer_Investor__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Potential_Buyer_Investor__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';




			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Financial_Sponsors__c('+Parent_Financial_Sponsor_FldList;
			if (orderedBy=='Financial_Sponsors__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Financial_Sponsors__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Project_Client_Contact__c('+Deal_Client_Contact_FldList;
			if (orderedBy=='Project_Client_Contact__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Project_Client_Contact__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Project_Resource__c('+Deal_Team_FldList;
			if (orderedBy=='Project_Resource__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Project_Resource__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Deal_Related_Parties__c('+Deal_Related_Party_FldList;
			if (orderedBy=='Deal_Related_Parties__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Deal_Related_Parties__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Potential_Buyer_Investor_Contact__c('+Target_Buyer_Contacts_FldList;
			if (orderedBy=='Target_Buyer_Contacts__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Target_Buyer_Contacts__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')&split; ';

			searchQuery += 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ';
			searchQuery += 'Employee_Relationships__c('+Moelis_Employee_Relationship_FldList;
			if (orderedBy=='Employee_Relationships__c') searchQuery += ' where ID in (' + sddSQL + ')';
			searchQuery += ' order by Name '+(orderedBy=='Employee_Relationships__c'?asc_desc:'')+' Limit '+(ElemPerPage+1)+')';

		return searchQuery;
	}

	public static String getWhereForSearchArray(List<String> searchArray, String field) {
		String result = '';
		for (Integer i = 0; i < searchArray.size(); i++) {
			if (searchArray.get(i).trim() != '') {
				if (result != '') result += ' or ';
				result += field + ' like \'' + searchArray.get(i).trim() + '%\'';
			}
		}
		return result; 
	}
	
	
	static testMethod void testThis() {
		SSearch_Additional.getSearchQuery('test', 10, 'Account', 'asc');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Account', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Contact', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Ibanking_Project__c', 'asc', 'testName', '001');
		//SSearch_Additional.getSearchQueryWhere('test', 10, 'DealIdea__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Employee_Profile__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Potential_Buyer_Investor__c', 'asc', 'testName', '001');
		
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Financial_Sponsors__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Project_Client_Contact__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Project_Resource__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Deal_Related_Parties__c', 'asc', 'testName', '001');
		//SSearch_Additional.getSearchQueryWhere('test', 10, 'Key_Constituents__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Target_Buyer_Contacts__c', 'asc', 'testName', '001');
		//SSearch_Additional.getSearchQueryWhere('test', 10, 'Research_Client_Contact__c', 'asc', 'testName', '001');
		SSearch_Additional.getSearchQueryWhere('test', 10, 'Employee_Relationships__c', 'asc', 'testName', '001');
		
		SSearch_Additional.getSearchQueryWhereIn('test', 10, 'Employee_Relationships__c', 'asc', '001');
			
		
		
		
		List<String> testList = new List<String>();
		testList.add('test');
		SSearch_Additional.getWhereForSearchArray(testList, 'field_test');
		
	}

}