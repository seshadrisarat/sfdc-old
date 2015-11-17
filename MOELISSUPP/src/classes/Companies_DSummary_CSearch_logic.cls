/**
* Test methods are in Test_Companies_DSummary.cls
**/
public without sharing class Companies_DSummary_CSearch_logic {
	
	/*************************************
	 * Class of business-logic           *
	 * Processing access to the database *
	 *************************************/
	
	public static String getCompanyName(String id) {
		String res = '';
		String queryStr = '';
		List<Account> tmpRes = new List<Account>(); 
		if (id != '') {
			queryStr = 'SELECT Id,Name FROM Account WHERE Id = \''+id+'\'';
			tmpRes = database.query(queryStr);
			if (tmpRes.size() > 0) {
				res = tmpRes[0].Name;
			}
		}
		return res;
	}
	
	public static List<List<sObject>> getSearchResult(String dealFilter,
													  String drpFilter, // Deal Related Party filter
													  String pbiFilter, // Potential Buyer/Investor filter
													  // Additional filters
													  List<String> productType, 
													  List<String> expectedTiming, 
													  List<String> dealRegion, 
													  List<String> dealIndustry, 
													  List<String> dealSubSector, 
													  List<String> dealStatus) {
		List<List<sObject>> res = new List<List<sObject>>(); // Search result
		
		//system.debug('+++++++++++dealFilter++++++++++>>>> '+dealFilter);
		//system.debug('+++++++++++drpFilter++++++++++>>>> '+drpFilter);
		//system.debug('+++++++++++pbiFilter++++++++++>>>> '+pbiFilter);
		
		String dealFindStr = '';
		String drpFindStr = '';
		String pbiFindStr = '';
		
		String dealWhereStr = '';
		String drpWhereStr = ''; //Deal Related Party where string
		String pbiWhereStr = ''; //Potential Buyer/Investor string
		
		String dealFldList = 'Id,Name,Expense_Code__c,Client__r.Name,Client__r.Id,Status__c,Industry__c,Sector__c,Regions__c,Product_Type__c,Stage__c,Expected_Close_Date__c,Financial_Sponsor__r.Name,Financial_Sponsor__r.Id';
		String drpFldList = 'Company__r.Name,Company__r.Id,Id,Name,Deal__r.Id,Deal__r.Name,Deal__r.Expense_Code__c,Deal__r.Status__c,Deal__r.Client__r.Name,Deal__R.Client__r.Id,Industry__c,Subsector__c,Deal__r.Regions__c,Deal__r.Product_Type__c,Deal__r.Stage__c,Deal__r.Expected_Close_Date__c,Deal__r.Financial_Sponsor__r.Name,Deal__r.Financial_Sponsor__r.Id';
		String pbiFldList = 'Id,Name,Project__r.Id,Project__r.Name,Project__r.Status__c,Project__r.Expense_Code__c,Project__r.Client__r.Name,Project__r.Client__r.Id,Industry__c,Sub_Sector__c,Project__r.Regions__c,Product_Type__c,Status__c,Project__r.Expected_Close_Date__c,Project__r.Financial_Sponsor__r.Name,Project__r.Financial_Sponsor__r.Id';
		
		String tmpStr = '';
		
		String sponsorQueryStr = '';
		
		/* Created search criteria strings from lists */
		dealWhereStr += Companies_DSummary_CSearch_logic.getParamString(productType, 'Product_Type__c');
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(expectedTiming, 'Expected_Close_Date__c');
		if (dealWhereStr != '' && tmpStr != '') {dealWhereStr += 'AND';}
		dealWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamStringIncludes(dealRegion, 'Regions__c');
		if (dealWhereStr != '' && tmpStr != '') {dealWhereStr += 'AND';}
			dealWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealIndustry, 'Industry__c');
		if (dealWhereStr != '' && tmpStr != '') {dealWhereStr += 'AND';}
		dealWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealSubSector, 'Sector__c');
		if (dealWhereStr != '' && tmpStr != '') {dealWhereStr += 'AND';}
		dealWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealStatus, 'Status__c');
		if (dealWhereStr != '' && tmpStr != '') {dealWhereStr += 'AND';}
		dealWhereStr += tmpStr;
		if (dealWhereStr != '') {
			dealWhereStr = ' '+dealWhereStr;
		}
		
		//system.debug('=============== dealWhereStr ====================>>> '+dealWhereStr);

		drpWhereStr += Companies_DSummary_CSearch_logic.getParamString(productType, 'Deal__r.Product_Type__c');
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(expectedTiming, 'Deal__r.Expected_Close_Date__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamStringIncludes(dealRegion, 'Deal__r.Regions__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealIndustry, 'Industry__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealSubSector, 'Subsector__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealStatus, 'Deal__r.Status__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		if (drpWhereStr != '') {
			drpWhereStr = ' '+drpWhereStr;
		}
		
		//system.debug('=============== dealRelatedPartyWhereStr ====================>>> '+drpWhereStr);

		pbiWhereStr += Companies_DSummary_CSearch_logic.getParamString(productType, 'Product_Type__c');
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(expectedTiming, 'Project__r.Expected_Close_Date__c');
		if (pbiWhereStr != '' && tmpStr != '') {pbiWhereStr += 'AND';}
		pbiWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamStringIncludes(dealRegion, 'Project__r.Regions__c');
		if (pbiWhereStr != '' && tmpStr != '') {pbiWhereStr += 'AND';}
		pbiWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealIndustry, 'Industry__c');
		if (pbiWhereStr != '' && tmpStr != '') {pbiWhereStr += 'AND';}
		pbiWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealSubSector, 'Sub_Sector__c');
		if (pbiWhereStr != '' && tmpStr != '') {pbiWhereStr += 'AND';}
		pbiWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealStatus, 'Project__r.Status__c');
		if (pbiWhereStr != '' && tmpStr != '') {pbiWhereStr += 'AND';}
		pbiWhereStr += tmpStr;
		if (pbiWhereStr != '') {
			pbiWhereStr = ' '+pbiWhereStr;
		}
		
		//system.debug('=============== PotentialBuyerInvestorWhereStr ====================>>> '+pbiWhereStr);
		
		/* Select Deals records */
		if (dealFilter != '') {
			dealFindStr = 'SELECT (SELECT Role__c,Banker__r.Id,Banker__r.Name FROM Ibanking_Project__c.Project_Resources__r WHERE Role__c=\'Project Administrator\' OR Role__c=\'Project Sponsor\'),';
			dealFindStr += '(SELECT Id,Name,Company__r.Id,Company__r.Name FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Role__c=\'Financial Sponsor\'),';
			dealFindStr += dealFldList+' FROM Ibanking_Project__c WHERE ('+dealFilter+')';
			if (dealWhereStr != '') {dealFindStr += ' AND '+dealWhereStr;}
		} else
		if (dealWhereStr != '') {
			dealFindStr = 'SELECT (SELECT Role__c,Banker__r.Id,Banker__r.Name FROM Ibanking_Project__c.Project_Resources__r WHERE Role__c=\'Project Administrator\' OR Role__c=\'Project Sponsor\'),';
			dealFindStr += '(SELECT Id,Name,Company__r.Id,Company__r.Name FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Role__c=\'Financial Sponsor\'),';
			dealFindStr += dealFldList+' FROM Ibanking_Project__c WHERE '+dealWhereStr;
		}
		dealFindStr += ' ORDER BY Name ASC ';
		
		/* Select Deal Related Parties records */
		String dealIds = '';
		String drpIds = '';
		if (drpFilter != '') {
			drpFindStr = 'SELECT ';
			drpFindStr += drpFldList+' FROM Deal_Related_Parties__c WHERE ('+drpFilter+')';
			if (drpWhereStr != '') {drpFindStr += ' AND '+drpWhereStr;}
		} else 
		if (drpWhereStr != '') {
			drpFindStr = 'SELECT ';
			drpFindStr += drpFldList+' FROM Deal_Related_Parties__c WHERE '+drpWhereStr;
		}
		List<Deal_Related_Parties__c> tmp = new List<Deal_Related_Parties__c>(); 
		if (drpFindStr != '') {
			//drpFindStr += ' ORDER BY Deal__r.Name';
			//system.debug('++==++==>> '+drpFindStr);
			tmp = database.query(drpFindStr);
		}
		for (Deal_Related_Parties__c item: tmp) {
			if (item.Deal__r.Id != null) {
				if (dealIds == '') {
					dealIds += '\''+item.Deal__r.Id+'\'';
				}else{
					dealIds += ',\''+item.Deal__r.Id+'\'';
				}
			}
			if (item.Id != null) {
				if (drpIds == '') {
					drpIds += '\''+item.Id+'\'';
				}else{
					drpIds += ',\''+item.Id+'\'';
				}
			}
		}
		String drpQueryStr = '';
		if (dealIds != '' && drpIds != '') {
			drpQueryStr += 'SELECT (SELECT Role__c,Banker__r.Id,Banker__r.Name FROM Ibanking_Project__c.Project_Resources__r WHERE Role__c=\'Project Administrator\' OR Role__c=\'Project Sponsor\'),';
			drpQueryStr += '(SELECT '+drpFldList+' FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Id IN ('+drpIds+') ) ';
			drpQueryStr += 'FROM Ibanking_Project__c WHERE Id IN ('+dealIds+') ORDER BY Name';

			//sponsorQueryStr += 'SELECT (SELECT Id,Name FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Role__c = \'Financial Sponsor\' ';
			//sponsorQueryStr += 'FROM Ibanking_Project__c WHERE Id IN ('+dealIds+')';
		}
		
		/* Select Potential Buyer/Investor records */
		dealIds = '';
		String pbiIds = '';
		if (pbiFilter != '') {
			pbiFindStr = 'SELECT '+pbiFldList+' FROM Potential_Buyer_Investor__c WHERE ('+pbiFilter+')';
			if (pbiWhereStr != '') {pbiFindStr += ' AND '+pbiWhereStr;}
		} else 
		if (pbiWhereStr != '') {
			pbiFindStr = 'SELECT '+pbiFldList+' FROM Potential_Buyer_Investor__c WHERE '+pbiWhereStr;
		}
		List<Potential_Buyer_Investor__c> pbiTmp = new List<Potential_Buyer_Investor__c>();
		if (pbiFindStr != '') {
			pbiTmp = database.query(pbiFindStr);
		}
		for (Potential_Buyer_Investor__c item: pbiTmp) {
			if (item.Project__r.Id != null) {
				if (dealIds == '') {
					dealIds += '\''+item.Project__r.Id+'\'';
				}else{
					dealIds += ',\''+item.Project__r.Id+'\'';
				}
			}
			if (item.Id != null) {
				if (pbiIds == '') {
					pbiIds += '\''+item.Id+'\'';
				}else{
					pbiIds += ',\''+item.Id+'\'';
				}
			}
		}
		String pbiQueryStr = '';
		if (dealIds != '' && pbiIds != '') {
			pbiQueryStr += 'SELECT (SELECT Role__c,Banker__r.Id,Banker__r.Name FROM Ibanking_Project__c.Project_Resources__r WHERE Role__c=\'Project Administrator\' OR Role__c=\'Project Sponsor\'),';
			pbiQueryStr += '(SELECT Id,Name,Company__r.Id,Company__r.Name FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Role__c=\'Financial Sponsor\'),';
			pbiQueryStr += '(SELECT '+pbiFldList+' FROM Ibanking_Project__c.Target_Buyers__r WHERE Id IN ('+pbiIds+'))';
			pbiQueryStr += 'FROM Ibanking_Project__c WHERE Id IN ('+dealIds+') ORDER BY Name';
		}
		
		system.debug('======= deal query ======= '+dealFindStr);
		system.debug('======= deal filter ======= '+dealFilter);
		system.debug('======= drp query ======= '+drpQueryStr);
		system.debug('======= drp filter ======= '+drpFilter);
		system.debug('======= drp whereStr ======= '+drpWhereStr);
		system.debug('======= pbi query ======= '+pbiQueryStr);
		system.debug('======= pbi filter ======= '+pbiFilter);
		
		// Create the resulting array
		List<sObject> tmpRes = new List<sObject>();
		
		if (dealFindStr != '') {
			try {
				tmpRes = database.query(dealFindStr);
				//system.debug('****** tmpRes >>> '+tmpRes);
				res.add(tmpRes);
			} catch (Exception ex) {
				system.debug('SOQL Error: '+ex);
				res.add(new List<Ibanking_Project__c>());
			}
		} else {
			res.add(new List<Ibanking_Project__c>());
		}

		if (drpQueryStr != '') {
			system.debug('===>>> '+drpFindStr);
			try {
				tmpRes = database.query(drpQueryStr);
				//system.debug('****** tmpRes >>> '+tmpRes);
				res.add(tmpRes);
			} catch(Exception ex) {
				system.debug('SOQL Error: '+ex);
				res.add(new List<Ibanking_Project__c>());
			}
		} else {
			res.add(new List<Ibanking_Project__c>());
		}
		
		if (pbiQueryStr != '') {
			system.debug('===>>> '+pbiFindStr);
			try {
				tmpRes = database.query(pbiQueryStr);
				//system.debug('****** tmpRes >>> '+tmpRes);
				res.add(tmpRes);
			} catch(Exception ex) {
				system.debug('SOQL Error: '+ex);
				res.add(new List<Ibanking_Project__c>());
			}
		} else { 
			res.add(new List<Ibanking_Project__c>());
		}
		
		return res;
	}
	
	//Transforming search criteria list to string of query part
	public static String getParamString(List<String> lst, String field) {
		String res = '';
		
		if (lst.size() > 0) {
			for (String item: lst) {
				if (res == '') {
					res += ' ('+field+' = \''+item+'\'';
				} else {
					res += ' or '+field+' = \''+item+'\'';
				}
			}
			res += ') ';
		}
		
		return res;
	}

	//Transforming search criteria list to string of query part with 'Includes' word
	public static String getParamStringIncludes(List<String> lst, String field) {
		String res = '';
		
		if (lst.size() > 0) {
			for (String item: lst) {
				if (res == '') {
					res += ' (' + field+' includes (\''+item+'\'';
				} else {
					res += ',\''+item+'\'';
				}
			}
			res += ')) ';
		}
		
		return res;
	}
	
	public static List<Companies_DSummary_CSearch_logic.DealRelatedParties_cls> getDRPlist(
																String drpFilter,
																List<String> productType, 
																List<String> expectedTiming, 
																List<String> dealRegion, 
																List<String> dealIndustry, 
																List<String> dealSubSector, 
																List<String> dealStatus) {
		List<Companies_DSummary_CSearch_logic.DealRelatedParties_cls> res =
					new List<Companies_DSummary_CSearch_logic.DealRelatedParties_cls>();
		
		String drpFindStr = '';
		String drpWhereStr = ''; //Deal Related Party where string
		String drpFldList = 'Company__r.Name,Company__r.Id,Id,Name,Deal__r.Id,Deal__r.Name,Deal__r.Expense_Code__c,Deal__r.Status__c,Deal__r.Client__r.Name,Deal__R.Client__r.Id,Industry__c,Subsector__c,Deal__r.Regions__c,Deal__r.Product_Type__c,Deal__r.Stage__c,Deal__r.Expected_Close_Date__c,Deal__r.Financial_Sponsor__r.Name,Deal__r.Financial_Sponsor__r.Id';
		
		String tmpStr = '';
		String sponsorQueryStr = '';
		
		drpWhereStr += Companies_DSummary_CSearch_logic.getParamString(productType, 'Deal__r.Product_Type__c');
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(expectedTiming, 'Deal__r.Expected_Close_Date__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamStringIncludes(dealRegion, 'Deal__r.Regions__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealIndustry, 'Industry__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealSubSector, 'Subsector__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		tmpStr = Companies_DSummary_CSearch_logic.getParamString(dealStatus, 'Deal__r.Status__c');
		if (drpWhereStr != '' && tmpStr != '') {drpWhereStr += 'AND';}
		drpWhereStr += tmpStr;
		if (drpWhereStr != '') {
			drpWhereStr = ' '+drpWhereStr;
		}
		
		/* Select Deal Related Parties records */
		String dealIds = '';
		String drpIds = '';
		if (drpFilter != '') {
			drpFindStr = 'SELECT ';
			drpFindStr += drpFldList+' FROM Deal_Related_Parties__c WHERE ('+drpFilter+')';
			if (drpWhereStr != '') {drpFindStr += ' AND '+drpWhereStr;}
		} else 
		if (drpWhereStr != '') {
			drpFindStr = 'SELECT ';
			drpFindStr += drpFldList+' FROM Deal_Related_Parties__c WHERE '+drpWhereStr;
		}
		List<Deal_Related_Parties__c> tmp = new List<Deal_Related_Parties__c>(); 
		if (drpFindStr != '') {
			system.debug('++==++==>> '+drpFindStr);
			tmp = database.query(drpFindStr);
		}
		for (Deal_Related_Parties__c item: tmp) {
			if (item.Deal__r.Id != null) {
				if (dealIds == '') {
					dealIds += '\''+item.Deal__r.Id+'\'';
				}else{
					dealIds += ',\''+item.Deal__r.Id+'\'';
				}
			}
			if (item.Id != null) {
				if (drpIds == '') {
					drpIds += '\''+item.Id+'\'';
				}else{
					drpIds += ',\''+item.Id+'\'';
				}
			}
		}
		String drpQueryStr = '';
		if (dealIds != '' && drpIds != '') {
			drpQueryStr += 'SELECT (SELECT Banker__r.Id,Banker__r.Name FROM Ibanking_Project__c.Project_Resources__r WHERE Role__c=\'Project Administrator\'),';
			//drpQueryStr += '(SELECT Id,Name FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Role__c=\'Financial Sponsor\'),';
			drpQueryStr += '(SELECT '+drpFldList+' FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Id IN ('+drpIds+') ) ';
			drpQueryStr += 'FROM Ibanking_Project__c WHERE Id IN ('+dealIds+')';

			sponsorQueryStr += 'SELECT (SELECT Deal__r.Id,Role__c,Company__r.Id,Company__r.Name,Id,Name FROM Ibanking_Project__c.Deal_Related_Parties__r WHERE Role__c = \'Financial Sponsor\') ';
			sponsorQueryStr += 'FROM Ibanking_Project__c WHERE Id IN ('+dealIds+')';
		}
		
		Companies_DSummary_CSearch_logic.DealRelatedParties_cls toAdd =
						new Companies_DSummary_CSearch_logic.DealRelatedParties_cls();
		List<Ibanking_Project__c> tmpRes;
		
		if (drpQueryStr != '') {
			//system.debug('drpFindStr===>>> '+drpFindStr);
			//system.debug('sponsorQueryStr===>>> '+sponsorQueryStr);
			//try {
				tmpRes = database.query(drpQueryStr);
				List<Ibanking_Project__c> sponsorRes;
				sponsorRes = database.query(sponsorQueryStr);
				system.debug('****** tmpRes >>> '+tmpRes);
				for (Ibanking_Project__c item:tmpRes) {
					for (Deal_Related_Parties__c subitem:item.Deal_Related_Parties__r) {
						toAdd = new Companies_DSummary_CSearch_logic.DealRelatedParties_cls();
						toAdd.drp = subItem;
						
						for (Project_Resource__c adm:item.Project_Resources__r) {
							toAdd.admins.add(adm);
						}
						
						for (Ibanking_Project__c res2:sponsorRes) {
							for (Deal_Related_Parties__c sponsor:res2.Deal_Related_Parties__r) {
								if (subitem.Deal__r.Id == sponsor.Deal__r.Id) {
									toAdd.sponsors.add(sponsor);
								}
							}
						}
						
						res.add(toAdd);
					}
				}
			//} catch(Exception ex) {
			//	system.debug('SOQL Error: '+ex);
				res.add(new Companies_DSummary_CSearch_logic.DealRelatedParties_cls());
			//}
		} else {
			res.add(new Companies_DSummary_CSearch_logic.DealRelatedParties_cls());
		}
		
		return res;
	}
	
	public class DealRelatedParties_cls {
		public Deal_Related_Parties__c drp {get;set;}
		public List<Deal_Related_Parties__c> sponsors {get;set;}
		public List<Project_Resource__c> admins {get;set;}
		public DealRelatedParties_cls() {
			drp = new Deal_Related_Parties__c();
			sponsors = new List<Deal_Related_Parties__c>();
			admins = new List<Project_Resource__c>();
		}
	}
	
}