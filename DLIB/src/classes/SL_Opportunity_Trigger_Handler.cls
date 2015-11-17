/**
 * \author Vladimir Dobrelya
 * \date 01/01/10
 * \see https://silverline.jira.com/browse/SILVERLINE-113
 * \brief Opportunity trigger handler. Runs on after insert, update
 * \test SL_Test_Opportunity_Trigger_Handler
 */
//with this class we don't have to worry about which trigger context variable to use. 
public without sharing class SL_Opportunity_Trigger_Handler
{
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public SL_Opportunity_Trigger_Handler( boolean isExecuting, integer size ) {
		this.m_isExecuting = isExecuting;
		this.BatchSize = size;
	}
 
	public void OnBeforeInsert( List<Opportunity> aRecords ) {
    	SL_sync_OpportunityToChangeOrder.insertNewChangeOrders( aRecords );
    }
    
	public void OnAfterInsert( Map<ID, Opportunity> aRecords ) {
		SL_sync_OpportunityToChangeOrder.relateAfter( aRecords );
		this.OpportunityProcessing( aRecords );
	}
    
	public void OnBeforeUpdate( Map<ID, Opportunity> aOldRecords, Map<ID, Opportunity> aNewRecords ) {
		SL_sync_OpportunityToChangeOrder.refreshOpportunityWithEmptyChangeOrder( aNewRecords.values() );
	}
    
	public void OnAfterUpdate( Map<ID, Opportunity> aOldRecords, Map<ID, Opportunity> aNewRecords ) {
		SL_sync_OpportunityToChangeOrder.refreshChangeOrders( aNewRecords );
		this.createChangeOrderMilestones( this.getClosedWonOppIds( aNewRecords, aOldRecords ) );
		this.OpportunityProcessing( aNewRecords );
		this.makeChatterPost( aNewRecords.values(), aOldRecords.values() );
		updateResourceRequestsForOppties(aOldRecords, aNewRecords);
	}

	public void OnBeforeDelete( Map<ID, Opportunity> aRecords ) {
		SL_sync_OpportunityToChangeOrder.deleteChangeOrders( aRecords.keySet() );
	}
    
	//public void OnAfterDelete(map<ID,Opportunity> oldOpportunityMap){ }
    
	public void OnUndelete( List<Opportunity> aRecords ) {
		SL_sync_OpportunityToChangeOrder.udeleteChangeOrders( aRecords );
	}


    private void updateResourceRequestsForOppties( Map<ID, Opportunity> aOldRecords, Map<ID, Opportunity> aNewRecords){

    	//filter out non services oppties
    	Map<Id,Opportunity> relevantOppties = new Map<Id,Opportunity>();
    	id servicesRT;

    	//get services record type

		for ( RecordType rt : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Services' limit 1 ] ) {
			servicesRT = rt.Id;
		}

    	for(id oid : aNewRecords.keySet()) {
    		if(aNewRecords.get(oid).RecordTypeId == servicesRT){

    			relevantOppties.put(oid, aNewRecords.get(oid));
    		}
    	}

    	if(relevantOppties.size() > 0) {

	    
	    	List<pse__resource_request__c> existingRequests = new List<pse__resource_request__c>();
	    	List<pse__resource_request__c> requestsToInsert = new List<pse__resource_request__c>();
	    	List<pse__resource_request__c> requestsToUpdate = new List<pse__resource_request__c>();
	    	List<pse__resource_request__c> requestsToDelete = new List<pse__resource_request__c>();


	    	//populate hour totals
	    	Map<String,String> apiNamesRolePicklistValues = new Map<string,string>();
			apiNamesRolePicklistValues.put('BA_Total_Hours__c','Business Analyst');
			apiNamesRolePicklistValues.put('DMS_Total_Hours__c','Data Architect');
			apiNamesRolePicklistValues.put('Dev_Total_Hours__c','Developer');
			apiNamesRolePicklistValues.put('EM_Hours_Total__c','Engagement Manager');
			apiNamesRolePicklistValues.put('DIS_Total_Hours__c','Integration Specialist');
			apiNamesRolePicklistValues.put('SA_Total_Hours__c','Solution Architect');
			apiNamesRolePicklistValues.put('SME_Total_Hours__c','Subject Matter Expert');
			apiNamesRolePicklistValues.put('SM_Total_Hours__c','Support Manager');
			apiNamesRolePicklistValues.put('TA_Total_Hours__c','Technical Architect');
			apiNamesRolePicklistValues.put('PC_Total_Hours__c','Principal Consultant');
		//These roles are not supported anywhere yet....do we need them in JFRSN?
	//apiNamesRolePicklistValues.put('','Design Review Committee');
	//apiNamesRolePicklistValues.put('','Principal Consultant');

	    	//popualte roles
	    	List<String> roleRateFields = New List<String>{
	    										'BA__c'
	    										,'DMS__c'
	    										,'Dev__c'
	    										,'EM__c'
	    										,'DIS__c'
	    										,'PC__c'
	    										,'SM__c'
	    										, 'PC__c'
	    										,'SA__c'
	    										,'SME__c'
	    										,'Support_Manager__c'
	    										,'TA__c'};
	    	existingRequests = [SELECT 
	    					id
	    					,pse__SOW_Hours__c 
	    					,pse__Resource_Role__c
	    					,pse__Opportunity__c
	    					,pse__Requested_Bill_Rate__c
	    					,OpptyRateForRole__c
	    					from 
	    					pse__resource_request__c
	    					WHERE
	    					 pse__Opportunity__c IN :aNewRecords.keySet()];


	    	Map<Id,list<pse__resource_request__c>> opptyIdsResourceRequests = new Map<Id,list<pse__resource_request__c>>();
	    	for(pse__resource_request__c r : existingRequests) {
	    		if (opptyIdsResourceRequests.get(r.pse__Opportunity__c) != null){
	    			opptyIdsResourceRequests.get(r.pse__Opportunity__c).add(r);
	    		} else {
	    			List<pse__resource_request__c> reqs = new List<pse__resource_request__c>();
	    			reqs.add(r);
	    			opptyIdsResourceRequests.put(r.pse__Opportunity__c, reqs);
	    		}
	    	}

	    	List<Id> opptiesWithRateChanges = new List<Id>();



	    	for(Opportunity o : relevantOppties.values()) {

	    		//get start date
				date startdate = o.Projected_Start_Date__c != null ? o.Projected_Start_Date__c : o.closedate;


	    		//did the dates change?
	    		Boolean dateChange = false;
	    		if((o.get('Projected_Start_Date__c') != aOldRecords.get(o.id).get('Projected_Start_Date__c')) || 
	    			(o.get('closedate') != aOldRecords.get(o.id).get('closedate'))){
	    				dateChange = true;
	    		}


	    		//did the rates change?
	    		Boolean rateUpdated = false;
	    		for(string roleRate : roleRateFields){
	    			if(((Decimal)o.get(roleRate) != (Decimal)aOldRecords.get(o.id).get(roleRate))){
	    				rateUpdated = true;
	    				opptiesWithRateChanges.add(o.Id);
	    				break;
	    			}
	    		}

	    		//if they did, write the new rate to the existing requests
	    		if(rateUpdated || dateChange && (opptyIdsResourceRequests != null && opptyIdsResourceRequests.containsKey(o.id))){
					boolean alreadyInUpdateList = false;
	    			//fuck it, update them all
	    			for(pse__resource_request__c r : opptyIdsResourceRequests.get(o.id)){
	    				r.pse__Requested_Bill_Rate__c = r.OpptyRateForRole__c;
	    				r.pse__start_date__c = startdate;
	    				r.pse__End_Date__c = startdate.addDays((Integer)o.Number_Of_Weeks__c * 7);
	    				requestsToUpdate.add(r);
	    			}
	    		}



	    		//did the em hours change?
	    		for(string role : apiNamesRolePicklistValues.keySet()){ //ROLE == ROLE TOTAL HOURS
	    			System.debug('Trigger Processing Role: ' + role);
	    			System.debug('Old Val: ' + (Decimal)o.get(role) + ' New val:  ' + (Decimal)aOldRecords.get(o.id).get(role));
	 	    		if((Decimal)o.get(role) > 0 && ((Decimal)o.get(role) != (Decimal)aOldRecords.get(o.id).get(role))){
		    			//were they previously zero?
		    			if((Decimal)aOldRecords.get(o.id).get(role) == 0) {
		    				//create a new resourceRequest
		    				pse__resource_request__c req = new pse__resource_request__c();
		    				req.pse__Opportunity__c = o.id;
		    				req.pse__Resource_Role__c = apiNamesRolePicklistValues.get(role);
		    				req.pse__SOW_Hours__c = (Decimal)o.get(role);
		    				req.pse__start_date__c = startdate;
		    				req.pse__End_Date__c = startdate.addDays((Integer)o.Number_Of_Weeks__c * 7);
		    				req.pse__Region__c = o.pse__Region__c;
		    				requestsToInsert.add(req);
		    			} else {
		    				//update existing resourcerequest
		    				pse__resource_request__c existingReq;

							if(opptyIdsResourceRequests.get(o.id) != null){
								if(opptyIdsResourceRequests.size() > 0) {

									for(pse__resource_request__c req : opptyIdsResourceRequests.get(o.id)){
										System.debug('rr role: ' + req.pse__Resource_Role__c + 'roleval' + apiNamesRolePicklistValues.get(role));
										if(req.pse__Resource_Role__c == apiNamesRolePicklistValues.get(role)){
											System.debug('match! using req: ' + req);
											existingreq = req;
										}
									}
								}
							}
							System.debug('Existing requ'+ existingreq);

							if(existingreq != null){
								boolean alreadyInUpdateList = false;
								if(requestsToUpdate.size() > 0){
									for(pse__resource_request__c requ : requestsToUpdate){
										if(existingreq.id == requ.id){
											requ.pse__SOW_Hours__c = (Decimal)o.get(role);
											System.debug('Already in request to update');
											alreadyInUpdateList = true;
										}
									}
								}
								if(!alreadyInUpdateList){
									existingreq.pse__SOW_Hours__c = (Decimal)o.get(role);
									requestsToUpdate.add(existingreq);
								}
							}else {
								//create a new resourceRequest

			    				pse__resource_request__c req = new pse__resource_request__c();
			    				req.pse__Opportunity__c = o.id;
			    				req.pse__Resource_Role__c = apiNamesRolePicklistValues.get(role);
			    				req.pse__SOW_Hours__c = (Decimal)o.get(role);
			    				req.pse__start_date__c = startdate;
			    				req.pse__End_Date__c = startdate.addDays((Integer)o.Number_Of_Weeks__c * 7);
			    				req.pse__Region__c = o.pse__Region__c;
			    				requestsToInsert.add(req);
							}
		    			}
			    	} else if((Decimal)o.get(role) == 0 && ((Decimal)o.get(role) != (Decimal)aOldRecords.get(o.id).get(role))){
			    		//if it is zero delete it
			    		if(opptyIdsResourceRequests.get(o.id).size() > 0) {
							for(pse__resource_request__c req : opptyIdsResourceRequests.get(o.id)){
								if(req.pse__Resource_Role__c == apiNamesRolePicklistValues.get(role)){
									requestsToDelete.add(req);
								}
							}
						}
			    	}
		   		}
	    	}

	    	System.debug('Requests to update' + requestsToUpdate);
	    	delete requestsToDelete;
	    	update requestsToUpdate;
	    	insert requestsToInsert;

	    	//if oppties have had rate changes, we need to refresh all of thier OLIs
	    	if(opptiesWithRateChanges.size() > 0) {
	    		List<Opportunity_Component_Feature__c> featuresOnRateChangedOppties = new List<Opportunity_Component_Feature__c>();
	    		featuresOnRateChangedOppties = [Select 
	    												ID,
	    												Product__c,
											    		Description__c,
											    		Opportunity_Component__r.Opportunity__c,
											    		EM__c,
											    		TA__c,
											    		PC__c,
											    		SA__c,
														SME__c,
														BA__c,
														DMS__c,
														DIS__c,
														Partner__c,
														Dev__c,
														DevMgmt__c,
														Offshore_Dev__c,
														Opportunity__c,
														SM__c,
														OLI__c 
														From 
														Opportunity_Component_Feature__c
														where
														Opportunity_Component__r.Opportunity__c in :opptiesWithRateChanges ];
				if(featuresOnRateChangedOppties.size() > 0){
					SL_OpptyComponentFeatureHandler featureHandler = new SL_OpptyComponentFeatureHandler();
					featureHandler.refreshOLIForFeatures(featuresOnRateChangedOppties);
				}
    		}
    	}

    }


	private void OpportunityProcessing( Map<ID, Opportunity> aOpportunityMap ) {
		// Id of the Product RecordType
		ID idRTProduct = null;
		for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Product' limit 1 ] ) {
			idRTProduct = oItem.Id;
		}
		
		List<Opportunity> aOpportunities = new List<Opportunity>();
		Set<Id> aLicensesIds = new Set<Id>();

		// If aOpportunityMap not contains Closed Won opportunities, therefore not necessary to selecting data for trigger
		for ( Opportunity oItem : aOpportunityMap.values() ) {
			if ( oItem.License__c != null && oItem.StageName == 'Closed Won' && oItem.RecordTypeId == idRTProduct ) {
				aOpportunities.add( oItem );
				// Ids of the Licenses, which linked with Opportunities in aOpportunityMap
				aLicensesIds.add( oItem.License__c );
			}   
		}
		if ( aOpportunities.isEmpty() ) {
			return;
		}
		
		if ( SL_Settings.RenewalOpportunityOwner == null ) {
			throw new TriggerException( 'OpportunityOwner does not exists' );
		}
        
		// Existing Renewal Opportunities
		Map<Id, Opportunity> aLicenseId_OpportunityRenewal = new Map<Id, Opportunity>();
		for ( Opportunity oItem : [
			SELECT Id, License__c
			FROM Opportunity
			WHERE License__c IN :aLicensesIds AND
				Type = 'Renewal' AND
				StageName = 'Qualified Suspect' AND
				Probability = 80 AND
				RecordTypeId = :idRTProduct
			]
		) {
			aLicenseId_OpportunityRenewal.put(oItem.License__c, oItem);
		}
        
        Set<ID> aPackageVersions = new Set<ID>();
        
		// Accounts, which linked with Active Licenses
		Set<Id> aAccountIds = new Set<Id>();
        
		// License objects, which linked with Opportunities in aOpportunityMap
		Map<Id, sfLma__License__c> aOpportunityLicenseId_License = new Map<Id, sfLma__License__c>();
		for ( sfLma__License__c oItem : [
			SELECT Id, sfLma__Status__c, sfLma__Account__c, sfLma__Seats__c, sfLma__Used_Licenses__c, sfLma__Licensed_Seats__c, sfLma__Package_Version__c,
					sfLma__Expiration__c, sfLma__License_Status__c, Package_Name__c, Discounted_License_Price__c, Discounted_License_Price_Expiration__c
			FROM sfLma__License__c
			WHERE Id IN :aLicensesIds
		] ) {
			aOpportunityLicenseId_License.put( oItem.Id, oItem );
			aAccountIds.add( oItem.sfLma__Account__c );
			aPackageVersions.add( oItem.sfLma__Package_Version__c );
		}
        
		Map<Id, Account> aAccounts = new Map<Id, Account>( [
			SELECT Id, Name
			FROM Account
			WHERE Id IN :aAccountIds
		] );        
        
		// All Names of the Packages
		Map<String, Id> aPackageNameVersion = new Map<String, Id>();
		for ( sfLma__Package_Version__c oItem : [ SELECT Id, sfLma__Package__r.Name FROM sfLma__Package_Version__c WHERE Id IN :aPackageVersions ] ) {
			aPackageNameVersion.put( oItem.sfLma__Package__r.Name, oItem.Id );
		}
        
		// Opportunities, which needs to upsert after create/update Renewal Opportunity
		List<Opportunity> aOpportunityToUpsert = new List<Opportunity>();
        
		String sPackageName = null;
		Opportunity oOpportunity = null;
        
		for ( Opportunity oTriggerOpportunity : aOpportunities ) {
			if ( aLicenseId_OpportunityRenewal.containsKey( oTriggerOpportunity.License__c ) ) {
				// Existing Renewal Opportunity
				oOpportunity = aLicenseId_OpportunityRenewal.get( oTriggerOpportunity.License__c );
			} else {
				// New Renewal Opportunity
				oOpportunity = new Opportunity();
				oOpportunity.OwnerId = SL_Settings.RenewalOpportunityOwner.Id;
				oOpportunity.License__c = oTriggerOpportunity.License__c;
				oOpportunity.Type = 'Renewal';
				oOpportunity.StageName = 'Qualified Suspect';
				oOpportunity.Probability = 80;
				oOpportunity.AccountId = oTriggerOpportunity.AccountId;
				oOpportunity.pse__Practice__c = SL_Settings.idPracticeLicenses;
				oOpportunity.pse__Region__c = SL_Settings.idRegionAllSilveline;
				oOpportunity.Billing_Type__c = 'Checkout';
				oOpportunity.RecordTypeId = idRTProduct;
			}
			
			Integer nNameMaxLength = Opportunity.Name.getDescribe().getLength();
            
            //added by Julia because Dina couldn't set Non-PSA Product? = True for Opportunity Product https://silverline.my.salesforce.com/00k3000000Gh5pRAAR
            //TODO!!! check if this is corect!!!
            if (aOpportunityLicenseId_License.containsKey( oTriggerOpportunity.License__c )) {
				// Update Opportunity fields
				sPackageName = aOpportunityLicenseId_License.get( oTriggerOpportunity.License__c ).Package_Name__c;
				oOpportunity.CloseDate = aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Expiration__c; //Date.today().addDays(330);
	
				if ( aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Seats__c != -1 ) {
					oOpportunity.Name = ' - ' + aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Seats__c + ' ' + sPackageName + ' Renewal';				
					oOpportunity.Number_of_Licenses__c = aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Seats__c;
					
					oOpportunity.Amount = (Integer)aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Seats__c *
						LicenseCostHelper.CalculateYearlyCost(
							aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c),
							(Integer)aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Seats__c,
							aPackageNameVersion.get(sPackageName)
						);
				} else { // Site License
					oOpportunity.Name = ' - ' + aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Used_Licenses__c + ' ' + sPackageName + ' Renewal';
					oOpportunity.Number_of_Licenses__c = aOpportunityLicenseId_License.get(oTriggerOpportunity.License__c).sfLma__Used_Licenses__c;
					oOpportunity.Amount = oTriggerOpportunity.Amount;
				}
            
				if ( ( aAccounts.get(oTriggerOpportunity.AccountId).Name + oOpportunity.Name ).length() > nNameMaxLength ) {
					oOpportunity.Name = aAccounts.get(oTriggerOpportunity.AccountId).Name.substring( 0, nNameMaxLength - oOpportunity.Name.length() ) + oOpportunity.Name;
				} else {
					oOpportunity.Name = aAccounts.get(oTriggerOpportunity.AccountId).Name + oOpportunity.Name;
				}
            
			aOpportunityToUpsert.add( oOpportunity );
            }
		}
       	
		if ( !aOpportunityToUpsert.IsEmpty() ) {
			upsert aOpportunityToUpsert;
		}
   }
   
   	/**
    Developer: Julia Kolesnik
    Description: Creates parent milestones for change order (SLFF-28)
    **/
   	private void createChangeOrderMilestones(set<Id> setOppIds)
	{
		if ( setOppIds.isEmpty() ) {
			return;
		}
		
		Map<ID, OpportunityLineItem> mapDiscounts = psaProjectSetup.getDiscountOLIByOppId(setOppIds);
		
		//get Opps with Budget records
		set<Id> setOppsWithBudget = psaProjectSetup.getOppsWithBudget(setOppIds);
		pse__Budget__c budget;
		list<pse__Budget__c> lstBudgets = new list<pse__Budget__c>();
		set<Id> mapChangeOrderOppIds = new set<Id>();
		
		list<Opportunity> lstCOOpps = new list<Opportunity>();
		// get Closed Won Change Orders Opps
		for (Opportunity item:psaProjectSetup.getClosedWonChangeOrderOpps(setOppIds)) {
			mapChangeOrderOppIds.add(item.Id);
			lstCOOpps.add(item);
			if (!setOppsWithBudget.contains(item.Id)) {
				budget = psaProjectSetup.generateBudget(item, item.Project_Change_Order__r.PSA_Project__c, 'Change Order', mapDiscounts.get(item.Id));
				lstBudgets.add(budget);
			}
		}
		//create budgets
		if (lstBudgets.size()>0) insert lstBudgets;
		
		if ( mapChangeOrderOppIds.isEmpty() ) {
			return;
		}
		psaProjectSetup.isService = false;
		List<pse__Milestone__c> lstMilestones = new List<pse__Milestone__c>();
        Map<ID, List<OpportunityLineItem>> mapProjectId_OppLineItems = psaProjectSetup.getOppLineItemsByProjectFROMOppIds(mapChangeOrderOppIds);
        List<pse__Proj__c> lstProjects = psaProjectSetup.getProjectByIds(mapProjectId_OppLineItems.keySet());
        Map<ID, Date> mapProjectId_DefaultTargetDates = psaProjectSetup.getDefaultTargetDatesForChangeOrders(lstCOOpps);
        Map<Id, Boolean> mapProjectId_IsFixedFee = psaProjectSetup.getIsFixedFee(lstProjects);
        
        //psaProjectSetup.dEventHorizon = null;
        //Map<String, JfrsnSettings__c> mapOCF = JfrsnSettings__c.getAll();
        //if (mapOCF.containsKey('standard')) {
        //	psaProjectSetup.dEventHorizon = mapOCF.get('standard').EventHorizon__c;
        //}
        //Map<Id, Boolean> mapProjectId_IsWithOCF = psaProjectSetup.getIsWithOCF( lstProjects );

        //don't use OCF for change orders
        Map<Id, Boolean> mapProjectId_IsWithOCF = new Map<Id, Boolean>();
        for (pse__Proj__c item:lstProjects) {
        	mapProjectId_IsWithOCF.put(item.Id,false);
        } 
        
        Map<Id, list<pse__Project_Phase__c>> mapProjectPhases = psaProjectSetup.getProjectPhases(mapProjectId_OppLineItems.keySet(), mapProjectId_IsWithOCF);
        psaProjectSetup.mapParentMilestones = psaProjectSetup.getParentMilestoneKeys(mapProjectId_OppLineItems.keySet());
        
        Map<ID, List<OpportunityLineItem>> mapProjectId_AllOLI = psaProjectSetup.getAllOppLineItemsByProject(mapProjectId_OppLineItems.keySet());
        
        Map<ID, Date> mapProjectId_DefaultEndDates = new Map<ID, Date>();
        for (pse__Proj__c item:lstProjects) {
        	mapProjectId_DefaultEndDates.put(item.Id, item.pse__End_Date__c);
        }
        
        psaProjectSetup.mapProjectRates = new map<Id,map<string, decimal>>();
        
        for ( ID idProject : mapProjectId_OppLineItems.keySet() ) {
        	if(idProject == null) continue;
            lstMilestones.addAll( psaProjectSetup.convertOppLineItemsToMilestones( idProject, mapProjectId_OppLineItems.get( idProject ), mapProjectId_AllOLI.get(idProject), mapProjectPhases.get(idProject), mapProjectId_DefaultTargetDates.get( idProject ), mapProjectId_DefaultEndDates.get( idProject ), mapProjectId_IsFixedFee.get(idProject), mapProjectId_IsWithOCF.get(idProject) ) );
        }
        
		if (lstMilestones.size()>0) upsert lstMilestones;
		
		psaProjectSetup.psaUpdateProjectRates(lstProjects);
		
		psaProjectSetup.createChildMilestones(mapProjectId_OppLineItems.keySet());
		
		//psaProjectSetup.createBillableMilestone(mapProjectId_OppLineItems.keySet());
		
		map<id,decimal> mapProject2Quantity = new map<id,decimal>();
		decimal COHours;
		for (OpportunityLineItem item:[Select Id, Quantity, Opportunity.Project_Change_Order__r.PSA_Project__c 
										FROM OpportunityLineItem WHERE Opportunity.Project_Change_Order__r.PSA_Project__c IN :mapProjectId_OppLineItems.keySet()
										AND Opportunity.Recordtype.DeveloperName = 'Change_Orders' AND Opportunity.StageName='Closed Won']) {
			if (mapProject2Quantity.containsKey(item.Opportunity.Project_Change_Order__r.PSA_Project__c)) {
				COHours = mapProject2Quantity.get(item.Opportunity.Project_Change_Order__r.PSA_Project__c);
			} else COHours = 0;
			COHours += item.Quantity;
			mapProject2Quantity.put(item.Opportunity.Project_Change_Order__r.PSA_Project__c, COHours);
		}
		
		map<Id,decimal> mapBudgets = new map<Id,decimal>();
		for (pse__Budget__c item:[Select pse__Project__c, pse__Amount__c FROM pse__Budget__c WHERE pse__Project__c IN :lstProjects limit 10000]) {
			if (item.pse__Amount__c!=null) {
				if (!mapBudgets.containsKey(item.pse__Project__c)) mapBudgets.put(item.pse__Project__c,item.pse__Amount__c);
				else mapBudgets.put(item.pse__Project__c,mapBudgets.get(item.pse__Project__c)+item.pse__Amount__c);
			}
		}
		
		//set CO hours for project
		for (pse__Proj__c item:lstProjects) {
			if (mapProject2Quantity.containsKey(item.Id)) 	item.CO_Hours__c = mapProject2Quantity.get(item.Id);
			else item.CO_Hours__c = 0;
			
			if (mapBudgets.containsKey(item.Id)) item.Budget_Amount__c = mapBudgets.get(item.Id);
			else item.Budget_Amount__c = 0;
		}
		
		
		if (lstProjects.size()>0) update lstProjects;
	}

	private Set<ID> getClosedWonOppIds( Map<ID, Opportunity> aNewRecords, Map<ID, Opportunity> aOldRecords ) {
		Set<ID> aResult = new Set<ID>();

		for ( Opportunity oItem : aNewRecords.values() ) {
            if ( oItem.StageName == 'Closed Won' && oItem.StageName != aOldRecords.get( oItem.Id ).StageName ) {
                aResult.add( oItem.Id );
            }
        }

        return aResult;
	}

    /**
    Developer: Brock Elgart
    Description: Makes a post to the Sales Wins chatter group instructing Janet(Head of Finance) to update OpenAir and 
    Quickbooks when an opportunity closes
    **/
	private void makeChatterPost(List<Opportunity> newList, List<Opportunity> oldList)
	{
		List<FeedItem> updatePosts = new List<FeedItem>();
		try
		{
			for(Integer i = 0; i < newList.size(); i++)
			{
				CollaborationGroup sWins = new CollaborationGroup();
				if( newList.size() > 0 )
				{
					//Because duplicate CollaborationGroups cannot be inserted in test code, a seperate group
					//named Test Sales Wins must be created in the test code (and handled here) to simulate
					//posts that would be made to the Sales Wins CollaborationGroup
					if(Test.isRunningTest())
						sWins = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Sales Wins' limit 1];
					else
						sWins = [SELECT Id FROM CollaborationGroup WHERE Name = 'Sales Wins' limit 1];
				
					System.debug('sWins: ' + sWins);
					
					
					String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
			
					if( (newList[i].StageName == 'Closed Won') 
					&&	(oldList[i].StageName != 'Closed Won') )
					{
						User owner = [SELECT Name FROM User WHERE ID = :newList[i].OwnerId limit 1];
						
						Account oppAcct = 	[SELECT Name, BillingStreet, BillingCity, BillingState, 
											BillingPostalCode, BillingCountry 
											FROM Account 
											WHERE ID = :newList[i].AccountId limit 1];
						
						FeedItem post = new FeedItem(); 
						post.ParentId = sWins.Id; //ID of Sales Wins chatter group
						
						
						post.LinkUrl = baseURL + '/' + newList[i].Id;//link to opportunity
						post.Title = newList[i].Name;//Title of link
						
						
						System.debug('baseURL + newList[i].Id: ' +  baseURL + newList[i].Id);
						
						
						String body = '';
						//Paragraph 1
						body += 'A new deal has closed!\n';
						
						String oppOwner = truncateLongString(owner.Name, 80);
						body += 'Owner: ' + oppOwner + '\n';
						
						String companyName = truncateLongString(oppAcct.Name, 80);
						body += 'Company Name: ' + companyName + '\n';
						
						if( newList[i].Amount != null )
						{
							String oppAmount = truncateLongString(String.valueOf(newList[i].Amount), 80);
							body += 'Total Project Amount: $' + oppAmount + '\n\n';
						}
						else
							body += '\n';
						
						
						//Paragraph 2
						String address;
						if(	(!String.isBlank(oppAcct.BillingStreet))
						&&	(!String.isBlank(oppAcct.BillingCity)) 
						&&	(!String.isBlank(oppAcct.BillingState))
						&&	(!String.isBlank(oppAcct.BillingPostalCode))	)
						{
							address = 'Billing Address: ' + oppAcct.BillingStreet + ',\n';
							address += oppAcct.BillingCity + ' ' + oppAcct.BillingState + ', ';
							address += oppAcct.BillingPostalCode;
							
							if( !String.isBlank(oppAcct.BillingCountry) )
								address += oppAcct.BillingCountry;
							
							address = truncateLongString(address, 200);
							body += address + '\n';
						}
						
						if( !String.isBlank(newList[i].SOW_or_CO__c) )
							body += 'SOW or CO: ' + newList[i].SOW_or_CO__c + '\n';
						
						if( !String.isBlank(newList[i].Billing_Notes__c) )
						{
							String oppBillNotes = truncateLongString(newList[i].Billing_Notes__c, 80);
							body += 'BILLING NOTES: ' + oppBillNotes;
						}
						
						
						body = truncateLongString (body, 1000);
						
						post.Body = body;
						
						System.debug('post: ' + post);
						
						updatePosts.add(post);
					}
				}
			}
			if(updatePosts.size() != 0)
			{
				insert updatePosts;
			}
		}		
		catch(QueryException qe)
		{
			System.debug('No sWins Group');
		}
		catch(Exception e)
		{
			String errorMsg = populateErrorMsg(e);
			System.debug(errorMsg);
			String causeMsg = getExcCause(e);
			System.debug(causeMsg);
		}
	}
	
	/**
	Truncates Strings with a length greater than 100 characters.
	**/
	private String truncateLongString(String longString, Integer length)
	{
		String shortString;
		if(longString.length() > length)
			shortstring = longString.subString(0,(length-1));
		else
			shortString = longString;
		
		return shortString;
	}
		
	private static String populateErrorMsg(Exception e)
    {
		String outputMsg = e.getTypeName() + ' at line ' + e.getLineNumber() + '\n';
		outputMsg += 'Error Message: ' + e.getMessage();
		return outputMsg;
    }
	
	private static String getExcCause(Exception e)
	{
		String causeMsg;
		Exception cause = e.getCause();
		if(cause != null)
		{
			causeMsg = 'The exception was caused by the following exception:\n';
			causeMsg += populateErrorMsg(cause);
		}
		else
		{
			causeMsg = 'The exception was not caused by another exception';
		}
		return causeMsg;
	}
   
   	private class TriggerException extends Exception { }
}