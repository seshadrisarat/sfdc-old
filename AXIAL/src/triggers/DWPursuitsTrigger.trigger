trigger DWPursuitsTrigger on DW_Pursuit__c (before insert, before update) {

	if(trigger.isBefore){
		// Prep all Id lists
		List<Decimal> accountSlugs = new List<Decimal>();
		List<String> contactIds = new List<String>();
		List<String> oppIds = new List<String>();
		//List<String> tpIds = new List<String>();


		for(DW_Pursuit__c p :trigger.new){
			// Account
			if(p.Pursuing_Account_Unique_Slug_Id__c != null){
				accountSlugs.add(p.Pursuing_Account_Unique_Slug_Id__c);
			}
			if(p.Receiving_Account_Unique_Slug_Id__c != null){
				accountSlugs.add(p.Receiving_Account_Unique_Slug_Id__c);
			}

			// Contact
			if(p.Pursuing_Member_Axial_Id__c != null){
				contactIds.add(p.Pursuing_Member_Axial_Id__c);
			}
			if(p.Receiving_Member_Public_Id__c != null){
				contactIds.add(p.Receiving_Member_Public_Id__c);
			}

			// Opp
			if(p.Axial_Opportunity_Public_Id__c != null){
				oppIds.add(p.Axial_Opportunity_Public_Id__c);
			} 

			// TP
			//if(p.Transaction_Profile_Id__c != null){
			//	tpIds.add(p.Transaction_Profile_Id__c);
			//}
		}

		// Accounts
		List<Account> relatedAccounts = [SELECT Id, AXM_Unique_Slug_Id__c 
											 FROM Account 
											 WHERE AXM_Unique_Slug_Id__c in :accountSlugs];

		Map<Decimal, Account> acctsBySlug = new Map<Decimal, Account>();
		for(Account a :relatedAccounts){ acctsBySlug.put(a.AXM_Unique_Slug_ID__c, a); }


		// Contacts
		List<Contact> relatedContacts = [SELECT Id, Masquerade_Id__c 
											 FROM Contact
											 WHERE is_Active__c = true 
											 AND Masquerade_Id__c in :contactIds];

		Map<String, Contact> contactsById = new Map<String, Contact>();
		for(Contact c :relatedContacts){ contactsById.put(c.Masquerade_ID__c, c); }

		// Opps
		List<CATH_Deal__c> relatedDeals = [SELECT Id, AxialMarket_Opportunity_Id__c 
											 FROM CATH_Deal__c 
											 WHERE AxialMarket_Opportunity_Id__c in :oppIds];

		Map<String, CATH_Deal__c> oppsById = new Map<String, CATH_Deal__c>();
		for(CATH_Deal__c d :relatedDeals){ oppsById.put(d.AxialMarket_Opportunity_Id__c, d); }		

		// TO DO: map of all transaction profiles by public id


		// fields to update: 
			// pursuing member, pursuing account, tp, 
			// receiving member, receiving account, opp	
		for (DW_Pursuit__c pursuit :trigger.new) {
			//Account pursuingAccount = acctsBySlug.get(pursuit.Pursuing_Account_Unique_Slug_Id__c);
			//if(pursuingAccount != null){
			//	Id acctId = pursuingAccount.Id;
			//	if(acctid != null){
			//		pursuit.Pursuing_Account__c = acctId;
			//	}
			//}

			//Contact pursuingMember = contactsById.get(pursuit.Pursuing_Member_Axial_Id__c);
			//if(pursuingMember != null){
			//	Id conId = pursuingMember.Id;
			//	if(conId != null){
			//		pursuit.Pursuing_Member__c = conId;
			//	}
			//}

			// TO DO: Transaction Profile

			//Account receivingAccount = acctsBySlug.get(pursuit.Receiving_Account_Unique_Slug_Id__c);
			//if(receivingAccount != null){
			//	Id acctId = receivingAccount.Id;
			//	if(acctid != null){
			//		pursuit.Receiving_Account__c = acctId;
			//	}
			//}

			//Contact receivingMember = contactsById.get(pursuit.Receiving_Member_Public_Id__c);
			//if(receivingMember != null){
			//	Id conId = receivingMember.Id;
			//	if(conId != null){
			//		pursuit.Receiving_Member__c = conId;
			//	}
			//}


			CATH_Deal__c axialOpp = oppsById.get(pursuit.Axial_Opportunity_Public_Id__c);
			if(axialOpp != null){
				Id oppId = axialOpp.Id;
				if(oppId != null && pursuit.Axial_Opportunity__c == null){
					pursuit.Axial_Opportunity__c = oppId;
				}
			}
		}	
	}
}