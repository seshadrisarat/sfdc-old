public without sharing class SL_OpptyComponentFeatureHandler {
	
	public SL_OpptyComponentFeatureHandler() { }

	public void afterInsert( List<Opportunity_Component_Feature__c> aRecords ) {
		this.refreshOLIForFeatures( aRecords );
	}

	public void afterUpdate( List<Opportunity_Component_Feature__c> aOldRecords, List<Opportunity_Component_Feature__c> aNewRecords ) {
		this.refreshOLIForFeatures( aNewRecords ); 
	}

	public void afterDelete( List<Opportunity_Component_Feature__c> aRecords ) {
		system.debug('old records  to delete: ' + aRecords);

		this.refreshOLIForFeatures( aRecords );
	}

	public void refreshOLIForFeatures( List<Opportunity_Component_Feature__c> aRecords ) {
		Set<ID> aProductIds = this.getProductIds( aRecords );
		Set<ID> aOpportunityIds = this.getOpportunityIds( aRecords );
		Map<ID, PricebookEntry> aPricebookEntries = this.getPricebookEntries( aProductIds );
		
		Map<ID, List<OpportunityLineItem>> aOpportunityLineItems = this.getOpportunityLineItems( aOpportunityIds, this.getPricebookEntryIds( aPricebookEntries ) );
		Map<ID, Map<ID, List<Opportunity_Component_Feature__c>>> aOpportunityComponentFeatures = this.getOpportunityComponentFeatures( aOpportunityIds, aProductIds );
		Map<ID, Opportunity> aOpportunities = this.getOpportunities( aOpportunityIds );

		List<OpportunityLineItem> aOLIToInsert = new List<OpportunityLineItem>();
		Map<String, Decimal> aRolesFeatures;

		for ( ID idOpportunity : aOpportunities.keySet() ) {			
			if(aOpportunityComponentFeatures.get( idOpportunity ) != null){
				for ( ID idProduct : aOpportunityComponentFeatures.get( idOpportunity ).keySet() ) { 	//for each product, create an oli for each rate on each feature
					aRolesFeatures = this.getRoleSums( aOpportunityComponentFeatures.get( idOpportunity ).get( idProduct ) );
					if ( !aRolesFeatures.isEmpty() && aPricebookEntries.containsKey(idProduct)) {
						for ( String sRole : aRolesFeatures.keySet() ) {
							aOLIToInsert.add(
								new OpportunityLineItem(
									OpportunityId = idOpportunity,
									PricebookEntryId = aPricebookEntries.get( idProduct ).Id,
									UnitPrice = aOpportunities.get( idOpportunity ).get( sRole ) != null ? ( Decimal )aOpportunities.get( idOpportunity ).get( sRole ) : ( Decimal )aPricebookEntries.get( idProduct ).UnitPrice,
									Role__c = this.aRoles.get( sRole ),
									Description = this.getOpportunityLineItemDescription( aOpportunityLineItems.get( idOpportunity ), aPricebookEntries.get( idProduct ) ),
									Quantity = aRolesFeatures.get( sRole )
								)
							);
						}
					}
				}
			}
		}

		List<OpportunityLineItem> aOLIToDelete = this.getOpportunityLineItemList( aOpportunityLineItems );
		if ( !aOLIToDelete.isEmpty() ) {
			system.debug('OLIs to delete : ' + aOLIToDelete);
			delete aOLIToDelete;
		}

		if ( !aOLIToInsert.isEmpty() ){
			system.debug('OLIs to delete : ' + aOLIToInsert);
			insert aOLIToInsert;
		}
	}

	private List<OpportunityLineItem> getOpportunityLineItemList( Map<ID, List<OpportunityLineItem>> aOpportunityLineItems ) {
		List<OpportunityLineItem> aResult = new List<OpportunityLineItem>();

		for ( List<OpportunityLineItem> aItems : aOpportunityLineItems.values() ) {
			aResult.addAll( aItems );
		}

		return aResult;
	}

	private String getOpportunityLineItemDescription( List<OpportunityLineItem> aExistingOpportunityLineItems, PricebookEntry oPricebookEntry ) {
		if (aExistingOpportunityLineItems!=null) {
			for ( OpportunityLineItem oItem : aExistingOpportunityLineItems ) {
				if ( oItem.PricebookEntryId == oPricebookEntry.Id ) {
					return oItem.Description;
				}
			}
		}

		return oPricebookEntry.Product2.Description;
	}

	private Map<String, Decimal> getRoleSums( List<Opportunity_Component_Feature__c> aRecords ) {
		Map<String, Decimal> aResult = new Map<String, Decimal>();

		for ( Opportunity_Component_Feature__c oItem : aRecords ) {
			for ( String sRole : this.aRoles.keySet() ) {
				if ( oItem.get( sRole ) != null ) {
					if( oItem.get( sRole ) != 0 ) {
						if ( aResult.containsKey( sRole ) ) {
							aResult.put( sRole, ( Decimal )aResult.get( sRole ) + (Decimal)oItem.get( sRole ) );
						} else {
							aResult.put( sRole, ( Decimal )oItem.get( sRole ) );
						}
					}
				}
			}
		}
		return aResult;
	}

	private Map<ID, List<OpportunityLineItem>> getOpportunityLineItems( Set<ID> aOpportunityIds, Set<ID> aPricebookEntryIds ) {
		Map<ID, List<OpportunityLineItem>> aResult = new Map<ID, List<OpportunityLineItem>>();
		
		//put each Opp as key for OLI map
		for (Id oppId:aOpportunityIds) {
			aResult.put( oppId, new List<OpportunityLineItem>() );
		}
		
		for ( OpportunityLineItem oItem : [
			SELECT Id, OpportunityId, Description, UnitPrice, PricebookEntryId
			FROM OpportunityLineItem
			WHERE OpportunityId IN :aOpportunityIds AND
				PricebookEntryId in :aPricebookEntryIds ]
		) {
			aResult.get( oItem.OpportunityId ).add( oItem );
		}

		return aResult;
	}

	private Map<ID, PricebookEntry> getPricebookEntries( Set<ID> aProductIds ) {
		Map<ID, PricebookEntry> aResult = new Map<ID, PricebookEntry>();

		for ( PricebookEntry oItem : [
			SELECT Id, UnitPrice, Product2Id, Product2.Description, Pricebook2Id
       		FROM PricebookEntry 
       		WHERE Pricebook2Id = :SL_Settings.idStandardPricebook AND 
       			Product2Id IN :aProductIds ]
       	) {
			aResult.put( oItem.Product2Id, oItem );
       	}

       	return aResult;
	}

	private Map<ID, Opportunity> getOpportunities( Set<ID> aOpportunityIds ) {
		return new Map<ID, Opportunity>( [
			SELECT EM__c, TA__c, SA__c, SME__c, BA__c, DMS__c, PC__c, DIS__c, Dev__c, DevMgmt__c, SM__c 
			FROM Opportunity 
			WHERE Id IN :aOpportunityIds ]
		);
	}

	private Map<ID, Map<ID, List<Opportunity_Component_Feature__c>>> getOpportunityComponentFeatures( Set<ID> aOpportunityIds, Set<ID> aProductIds ) {
		Map<ID, Map<ID, List<Opportunity_Component_Feature__c>>> aResult = new Map<ID, Map<ID, List<Opportunity_Component_Feature__c>>>();

		for ( Opportunity_Component_Feature__c oItem : [
			SELECT Product__c, Description__c, Opportunity_Component__r.Opportunity__c, EM__c, TA__c, PC__c, SA__c,
				SME__c, BA__c, DMS__c, DIS__c, Partner__c, Dev__c, DevMgmt__c, Offshore_Dev__c, SM__c, OLI__c
			FROM Opportunity_Component_Feature__c 
			WHERE Product__c IN :aProductIds AND
				Opportunity_Component__r.Opportunity__c IN :aOpportunityIds AND Include_In_Tally__c = true]
		) {
			if ( !aResult.containsKey( oItem.Opportunity_Component__r.Opportunity__c ) ) {
				aResult.put( oItem.Opportunity_Component__r.Opportunity__c, new Map<ID, List<Opportunity_Component_Feature__c>>() );
			}
			if ( !aResult.get( oItem.Opportunity_Component__r.Opportunity__c ).containsKey( oItem.Product__c ) ) {
				aResult.get( oItem.Opportunity_Component__r.Opportunity__c ).put( oItem.Product__c, new List<Opportunity_Component_Feature__c>() );
			}
			aResult.get( oItem.Opportunity_Component__r.Opportunity__c ).get( oItem.Product__c ).add( oItem );
		}

		return aResult;
	}

	private Set<ID> getPricebookEntryIds( Map<ID, PricebookEntry> aPricebookEntries ) {
		Set<ID> aResult = new Set<ID>();

		for ( PricebookEntry oItem : aPricebookEntries.values() ) {
			aResult.add( oItem.Id );
		}

		return aResult;	
	}

	private Set<ID> getProductIds( List<Opportunity_Component_Feature__c> aRecords ) {
		Set<ID> aResult = new Set<ID>();

		for ( Opportunity_Component_Feature__c oItem : aRecords ) {
			aResult.add( oItem.Product__c );
		}

		return aResult;
	}

	private Set<ID> getOpportunityIds( List<Opportunity_Component_Feature__c> aRecords ) {
		Set<ID> aResult = new Set<ID>();

		for ( Opportunity_Component_Feature__c oItem : aRecords ) {
			aResult.add( oItem.Opportunity__c );
		}

		return aResult;
	}

	private Map<String, String> aRoles {
		get {
			if ( aRoles == null ) {
				aRoles = new Map<String, String>{
					'EM__c' => 'Engagement Manager',
					'TA__c' => 'Technical Architect',
					'SA__c' => 'Solution Architect',
					'SME__c' => 'Subject Matter Expert',
					'BA__c' =>'Business Analyst',
					'DMS__c' => 'Data Architect',
					'DIS__c' => 'Integration Specialist',
					'Dev__c' => 'Developer',
					'DevMgmt__c' => 'Dev Mgmt',
					'SM__c' => 'Support Manager',
					'PC__c' => 'Principal Consultant'
				};
			}
			return aRoles;
		} private set;
	}


	/*public SL_OpptyComponentFeatureHandler() {	
	}

	public void afterInsert(list <opportunity_component_feature__c> newList) {
		refreshOlisForFeatures(newList);
	}

	public void afterUpdate(list <opportunity_component_feature__c> oldList, list <opportunity_component_feature__c> newList) {
		List<opportunity_component_feature__c> allTouched = new List<opportunity_component_feature__c>();
		allTouched.addAll(oldList);
		allTouched.addAll(newList);
		refreshOlisForFeatures(allTouched); 
	}
	public void beforeDelete(list <opportunity_component_feature__c> oldList) {
		refreshOlisForFeatures(oldList);
	}

	private void refreshOlisForFeatures(List<opportunity_component_feature__c> features) {
		Map<id,List<id>> opptyIdsproductIds = new Map<id,List<id>>();

		for(opportunity_component_feature__c ocf : features) {
			if(opptyIdsproductIds.get(ocf.Opportunity__c) == null){
				List<id> prodIds = new List<id>();
				prodIds.add(ocf.product__c);
				opptyIdsproductIds.put(ocf.Opportunity__c, prodIds);
			} else {
				opptyIdsproductIds.get(ocf.Opportunity__c).add(ocf.product__c);
			}	
		}

		for(id oppty : opptyIdsproductIds.keySet()) {
			List<OpportunityLineItem> existingOlis = existingOlisForProdsOnOppty(opptyIdsproductIds.get(oppty), oppty);
			List<OpportunityLineItem> olisToDelete = existingOlis;

			

			List<OpportunityLineItem> olisToInsert = lineItemsForProductsOnOppty(opptyIdsproductIds.get(oppty), oppty, existingOlis);

			if(olisToDelete.size() > 0){
				delete olisToDelete;
			}

			if(olisToInsert.size() > 0){
				insert olisToInsert;
			}
			//get ids for olis that have been created write them back to OCFs that spawned them

		}
	}

	private List<OpportunityLineItem> existingOlisForProdsOnOppty( List<id> productIds, id opptyId ) {
		Map<ID, PricebookEntry> aPricebookEntries = new Map<ID, PricebookEntry>( [
			SELECT Id
       		FROM PricebookEntry 
       		WHERE Pricebook2Id = :[ SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1 ].Id AND 
       			Product2Id IN :productIds ]
       	);

		if( !aPricebookEntries.isEmpty() ){
			return new List<OpportunityLineItem>( [
				SELECT Id, Description__c, UnitPrice, PricebookEntryId
				FROM OpportunityLineItem
				WHERE OpportunityId = :opptyId AND
					PricebookEntryId in :aPricebookEntries.keySet() ]
			);
		}
		return new List<OpportunityLineItem>();
	}

	private List<OpportunityLineItem> lineItemsForProductsOnOppty(List<Id> productIds, id opptyId, List<OpportunityLineItem> existingOlis) {

		Map <id, List<opportunity_component_feature__c>> productIdsFeatures = new map<id, List<opportunity_component_feature__c>>();
		List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
		Map<String, PricebookEntry> prodIdsPriceBookEntries = new Map<String,PricebookEntry>();
		List<opportunity_component_feature__c> features = new list<opportunity_component_feature__c>();
		features = [Select 
						id
						, product__c
						, Description__c
						, Opportunity_Component__r.Opportunity__c
						, EM__c
						, TA__c
						, PC__c
						, SA__c
						, SME__c
						, BA__c
						, DMS__c
						, DIS__c
						, Partner__c
						, Dev__c
						, DevMgmt__c
						, Offshore_Dev__c 
						, SM__c
						, OLI__c
					from 
						opportunity_component_feature__c 
					where  
						Product__c in :productIds
					AND
						Opportunity_Component__r.Opportunity__c = :opptyId];

		for(opportunity_component_feature__c f : features) {
			if(productIdsFeatures.get(f.Product__c) == null) {
				List<Opportunity_Component_Feature__c> feats = new List<Opportunity_Component_Feature__c>();
				feats.add(f);
				productIdsFeatures.put(f.Product__c, feats);
			} else {
				productIdsFeatures.get(f.Product__c).add(f);
			}
		}

		If(productIdsFeatures.keySet().size() > 0){
			List<PricebookEntry> pbes = new list<PricebookEntry>();
			pbes = [SELECT Id, UnitPrice, Product2Id, Product2.Description, Pricebook2Id 
	       								 FROM PricebookEntry 
	       								 WHERE Pricebook2Id =: [SELECT Name, Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id AND Product2Id IN:productIdsFeatures.keySet()];
			if(pbes.size() > 0){
				for(PricebookEntry pbe : pbes){
					prodIdsPriceBookEntries.put(pbe.Product2Id, pbe);
				}
			}
		}

		List<String> roles = new List<String>{'EM__c', 'TA__c', 'PC__c', 'SA__c','SME__c', 'BA__c', 'DMS__c', 'DIS__c', 'Dev__c', 'DevMgmt__c', 'SM__c'};
		Opportunity masterOppty = new Opportunity();
		masterOppty = [Select id 
						,EM__c
						,TA__c
						,SA__c
						,SME__c
						,BA__c
						,DMS__c
						, PC__c
						,DIS__c
						,Dev__c
						,DevMgmt__c
						,SM__c 
						from 
						Opportunity 
						where id = :opptyId];

		Map<String,decimal> rolesFeatures = new Map<String,decimal>();
		//Map<decimal,set<string>> ratesRoles = new Map<Decimal,role>();



		map<string,string> rolesApiNamesRolesFriendlyNames = new map<string,string>();
		rolesApiNamesRolesFriendlyNames.put('EM__c','Engagement Manager');
		rolesApiNamesRolesFriendlyNames.put('TA__c','Technical Architect');
		rolesApiNamesRolesFriendlyNames.put('SA__c','Solution Architect');
		rolesApiNamesRolesFriendlyNames.put('SME__c','Subject Matter Expert');
		rolesApiNamesRolesFriendlyNames.put('BA__c','Business Analyst');
		rolesApiNamesRolesFriendlyNames.put('DMS__c','Data Architect');
		rolesApiNamesRolesFriendlyNames.put('DIS__c','Integration Specialist');
		rolesApiNamesRolesFriendlyNames.put('Dev__c','Developer');
		rolesApiNamesRolesFriendlyNames.put('DevMgmt__c','Dev Mgmt');
		rolesApiNamesRolesFriendlyNames.put('SM__c','Support Manager');
		rolesApiNamesRolesFriendlyNames.put('PC__c', 'Principal Consultant');
		
		
		//for each product, create an oli for each rate on each feature
		for(Id prodId : productIdsFeatures.keySet()){
			List<Opportunity_Component_Feature__c> featList = productIdsFeatures.get(prodId);
			Decimal hourSum = 0;
			String descriptionString = '';
			if(featList.size() > 0){
				for(Opportunity_Component_Feature__c  f : featList) {
					for(String role : roles) {
						if(f.get(role) != null) {
							if(f.get(role)!= 0){
								Decimal rate = 0;
								rate = masterOppty.get(role) != null ? (Decimal)masterOppty.get(role) : (Decimal)prodIdsPriceBookEntries.get(prodId).unitPrice;
								if(rolesFeatures.containsKey(role)){
									decimal rolesum = (Decimal)rolesFeatures.get(role) + (Decimal)f.get(role);
									rolesFeatures.put(role, rolesum);
								} else {
									rolesFeatures.put(role, (Decimal)f.get(role));
								}
							}
						}
					}
				}



				for(string role : rolesFeatures.keySet()){
					String descr = '';
					for(OpportunityLineItem existingOli : existingOlis) {
						if(existingOli.PricebookEntryId ==  prodIdsPriceBookEntries.get(prodId).id){
							descr = existingOli.Description__c;
						}
					}

					if(descr == '') {
						descr = prodIdsPriceBookEntries.get(prodId).Product2.Description;
					}
					Decimal rate = 0;
					rate = masterOppty.get(role) != null ? (Decimal)masterOppty.get(role) : (Decimal)prodIdsPriceBookEntries.get(prodId).unitPrice;
					OpportunityLineItem oli = new OpportunityLineItem();
					oli.OpportunityId = opptyId;
					oli.PricebookEntryId = prodIdsPriceBookEntries.get(prodId).id;
					oli.unitPrice = rate;
					oli.role__c = rolesApiNamesRolesFriendlyNames.get(role);
					oli.Description__c = descr;
					oli.Quantity = rolesFeatures.get(role);
					olis.add(oli);
				}
			}
		}
		return olis;
	}*/
}