/**
 * \author Liza Romanenko
 * \date 07 Dec 2011
 * \see http://silverline.jira.com/browse/SILVERLINE-26
 * \brief Handler Class for sfLma__License__c trigger
 * \details convert Leads in Active sfLma__License__c 
 * \details create opportunities from approved payments
 * \test SL_Test_sfLma_License_TriggerHandler
 */

public without sharing class SL_sfLma_License_TriggerHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	
	private Map<ID, sfLma__License__c> leadIdForConversion_LicenseMap;
    private Set<ID> activeLicenseIds;
    private Set<ID> accountIds;
    private Set<String> activeLicensePackageNames;
	
	public SL_sfLma_License_TriggerHandler( boolean isExecuting, integer size ) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	public void OnBeforeInsert( List<sfLma__License__c> aNewLicenses ) {
		leadIdForConversion_LicenseMap = new Map<Id, sfLma__License__c>();
		
		for ( sfLma__License__c oItem : aNewLicenses ) {
			if ( oItem.sfLma__Lead__c != null && oItem.sfLma__Account__c == null && oItem.sfLma__Contact__c == null ) {
				leadIdForConversion_LicenseMap.put( oItem.sfLma__Lead__c, oItem );
			}
		}
		
		for ( Lead oItem : [ SELECT Id, Email FROM Lead WHERE Id IN :leadIdForConversion_LicenseMap.keySet() AND IsConverted = false ] ) {
			if ( SL_Settings.IsDemoEmailDomain( oItem.Email ) ) {
				leadIdForConversion_LicenseMap.get( oItem.Id ).Salesforce_Demo_License__c = true;
			}
		}
	}
	
	public void OnAfterInsert( Map<ID, sfLma__License__c> newLicenseMap ) {
		newLicenseMap = this.ExcludeDemoLicenses( newLicenseMap );
		this.MergeDuplicatesLeadsForLicense( newLicenseMap.values() );
    }
    
	public void OnAfterUpdate( Map<ID, sfLma__License__c> oldLicenseMap, Map<ID, sfLma__License__c> newLicenseMap ) {
    	newLicenseMap = this.ExcludeDemoLicenses( newLicenseMap );
        //this.ConvertLeadsWhenLicenseIsActive( newLicenseMap.values() );
        this.ConvertPaymentsIntoOpportunities( oldLicenseMap, newLicenseMap );
    }

	private Map<ID, sfLma__License__c> ExcludeDemoLicenses( Map<ID, sfLma__License__c> aLicenses ) {
		Map<ID, sfLma__License__c> aResult = new Map<ID, sfLma__License__c>();

		for ( sfLma__License__c oItem : aLicenses.values() ) {
			if ( !oItem.Salesforce_Demo_License__c ) {
				aResult.put( oItem.Id, oItem );
			}
		}
		
		return aResult;
	}

	private void MergeDuplicatesLeadsForLicense(List<sfLma__License__c> sfLma_Licenses) {
		Set<ID> aLeadIds = new Set<ID>();

		for( sfLma__License__c oItem : sfLma_Licenses ) {
            if ( oItem.sfLma__Lead__c != null ) {
               aLeadIds.add( oItem.sfLma__Lead__c );
            }
		}
		
		if ( aLeadIds.isEmpty() ) {
			return;
		}
      
		Map<Id, Lead> aLeadId_Lead = new map<Id, Lead>( [
			SELECT Id, LastName, FirstName, Email
			FROM Lead
			WHERE Id IN :aLeadIds
		] );
		
		Map<String, ID> aUniqueKeysMap = new Map<String, ID>();
		for ( Lead oItem: aLeadId_Lead.values() ) {
      		aUniqueKeysMap.put( oItem.Email, oItem.Id );
		}
        
		Map<ID, List<Lead>> aLeadId_SlaveLead = new Map<ID, List<Lead>>();
		
		for( Lead oItem : [
			SELECT Id, LastName, FirstName, Email
			FROM Lead
			WHERE Id NOT IN :aLeadId_Lead.keySet() AND
				Email IN :aUniqueKeysMap.keySet() AND
				IsConverted = false
		] ) {
			String sUniqueFullName = ( oItem.FirstName != null ? String.valueOf( oItem.FirstName ) + ' ' : '' ) + String.valueOf( oItem.LastName );
			Id idLead = null;
			if ( oItem.Email != null && aUniqueKeysMap.containsKey( oItem.Email ) ) {
				idLead = aUniqueKeysMap.get( oItem.Email );
			}

			if( idLead != null &&
				sUniqueFullName == ( aLeadId_Lead.get( idLead ).FirstName != null ? String.valueOf( aLeadId_Lead.get( idLead ).FirstName ) + ' ' : '' ) + String.valueOf( aLeadId_Lead.get( idLead ).LastName ) &&
				oItem.id != idLead &&
				oItem.Email == aLeadId_Lead.get( idLead ).Email
			) {
				List<Lead> aLeads = new List<Lead>();
	      		if ( aLeadId_SlaveLead.containsKey( idLead ) ) {
	      			aLeads = aLeadId_SlaveLead.get( idLead );
	      		}
				aLeads.add( oItem );
	      		
				aLeadId_SlaveLead.put( idLead, aLeads );
			}
		}
      
		// merge duplicate leads
		for ( Id oItem : aLeadId_SlaveLead.keySet() ) {
			try {
				merge aLeadId_Lead.get( oItem ) aLeadId_SlaveLead.get( oItem ); 
			} catch( DmlException e ) {
				system.debug( '>>>>>>>>>>> merge catch ' + e );
			}
		}
	}
	
	/*private void ConvertLeadsWhenLicenseIsActive(List<sfLma__License__c> sfLma_Licenses) {
    	//Select Leads needed to be converted and Active Licenses
		leadIdForConversion_LicenseMap = new Map<Id, sfLma__License__c>();
    	activeLicenseIds = new Set<Id>();
    	accountIds = new Set<Id>();
    	activeLicensePackageNames = new Set<String>();
    	
    	for ( sfLma__License__c oItem : sfLma_Licenses ) {
			if ( !oItem.Salesforce_Demo_License__c && oItem.sfLma__Lead__c != null && oItem.sfLma__Account__c == null && oItem.sfLma__Contact__c == null ) {
				leadIdForConversion_LicenseMap.put( oItem.sfLma__Lead__c, oItem );
			}
    		if ( oItem.sfLma__Account__c != null && oItem.sfLma__Status__c == 'Active' ) { 
    			accountIds.add( oItem.sfLma__Account__c );
    			if ( oItem.Id != null ) {
	    			activeLicenseIds.add( oItem.Id );
	    			activeLicensePackageNames.add( oItem.Package_Name__c );
    			}
    		}
    	}
    	
    	String sUserKeyPrefix = Schema.sObjectType.User.getKeyPrefix();
    	
		//Convert Leads - lead conversion will also automatically fill in the appropriate license lookups.
		LeadStatus oConvertStatus = [ SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true limit 1 ];
		List<Database.LeadConvert> aLeadsToConvert = new List<Database.LeadConvert>();
		for ( Lead oItem : [ SELECT OwnerId, Email FROM Lead WHERE Id IN : leadIdForConversion_LicenseMap.keySet() AND IsConverted = false ] ) {
    		Database.LeadConvert oLeadConvert = new Database.LeadConvert();
			oLeadConvert.setLeadId( oItem.id );
			oLeadConvert.setDoNotCreateOpportunity( true );
			oLeadConvert.setConvertedStatus( oConvertStatus.MasterLabel );
			
			//if a lead is owned by a queue the account owner will be the sales user
			if ( String.valueof( oItem.OwnerId ).startsWith( sUserKeyPrefix ) == false && SL_Settings.GoogleCheckoutOwner != null ) {
				oLeadConvert.setOwnerId( SL_Settings.GoogleCheckoutOwner.Id );
			}
			aLeadsToConvert.add( oLeadConvert );
    	}
    	if ( !aLeadsToConvert.IsEmpty() ) {
    		Database.convertLead( aLeadsToConvert );
    	}
    }*/

	private void ConvertPaymentsIntoOpportunities( map<ID, sfLma__License__c> oldSfLma_LicensesMap, map<Id, sfLma__License__c> newSfLma_LicensesMap ) {
    	// moved from lead conversion logic
    	activeLicenseIds = new Set<Id>();
    	accountIds = new Set<Id>();
    	activeLicensePackageNames = new Set<String>();
    	
    	for ( sfLma__License__c oItem : newSfLma_LicensesMap.values() ) {
    		if ( oItem.sfLma__Account__c != null && oItem.sfLma__Status__c == 'Active' ) { 
    			accountIds.add( oItem.sfLma__Account__c );
    			if ( oItem.Id != null ) {
	    			activeLicenseIds.add( oItem.Id );
	    			activeLicensePackageNames.add( oItem.Package_Name__c );
    			}
    		}
    	}

    	//Select Account data
    	Map<ID, Account> accountMap = new Map<ID, Account>( [ SELECT Name FROM Account WHERE Id IN : accountIds ] );
    	
    	//Prepare PriceBookEntry for Opportunity Product    	
    	Map<String, PricebookEntry> packageName_PricebookEntryMap = new Map<String, PricebookEntry>();
    	Set<ID> aPricebookEntryIds = new Set<ID>();
    	for ( PricebookEntry oItem : [ SELECT Product2.Name FROM PricebookEntry WHERE Product2.Name IN : activeLicensePackageNames AND Pricebook2.IsStandard = true ] ) {
    		packageName_PricebookEntryMap.put( oItem.Product2.Name, oItem );
    		aPricebookEntryIds.add( oItem.Id );
    	}
    		
    	RecordType productRecordType = [ SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Product' LIMIT 1 ];
    	List<Opportunity> aOpportunities = new List<Opportunity>();
    	Map<ID, OpportunityLineItem> paymentIdToOpportunityProductMap = new Map<ID, OpportunityLineItem>();
    	
    	Map<ID, Payment__c> paymentMap = new Map<ID, Payment__c>( [
    		SELECT New_Licenses__c, License__c, Total__c, Renewal__c, Opportunity__c FROM Payment__c 
    		WHERE ( License__c IN : activeLicenseIds ) AND
    			( Status__c = 'approved' ) AND 
    			( Opportunity__c = null ) AND
    			lastmodifieddate >= :Datetime.now().addDays( -1 ) //this is to avoid creating opportunities when old licenses are updated.
    	] );
    	
    	List<Opportunity> aOpenOpps = [
			SELECT Id, Name, OwnerId, StageName, AccountId, RecordTypeId, Type,
				License__c, Projected_Start_Date__c, CloseDate, Billing_Notes__c
			FROM Opportunity
			WHERE StageName <> 'Closed Won' AND
				RecordTypeId = :productRecordType.Id
			limit 2000
		];

		Map<ID, Map<ID, OpportunityLineItem>> aOppId_PricebookEntryId_OLI = new Map<ID, Map<ID, OpportunityLineItem>>();
    	for ( OpportunityLineItem oItem : [ SELECT Id, TotalPrice, PricebookEntryId, OpportunityId, Quantity FROM OpportunityLineItem WHERE PricebookEntryId IN :aPricebookEntryIds AND OpportunityId IN :aOpenOpps ] ) {
    		if ( !aOppId_PricebookEntryId_OLI.containsKey( oItem.OpportunityId ) ) {
    			aOppId_PricebookEntryId_OLI.put( oItem.OpportunityId, new Map<ID, OpportunityLineItem>() );
    		}
    		if ( !aOppId_PricebookEntryId_OLI.get( oItem.OpportunityId ).containsKey( oItem.PricebookEntryId ) ) {
    			aOppId_PricebookEntryId_OLI.get( oItem.OpportunityId ).put( oItem.PricebookEntryId, oItem );
    		}
		}

    	for ( Payment__c p : paymentMap.values() ) {
    		string packagename;
    		ID pbeid;
    		
    		if ( newSfLma_LicensesMap.get( p.License__c ) == null ) { //can't create opportunity if we can't find license
    			system.debug('could not find license in newSfLma_LicensesMap');
    			continue;
    		}
    		packagename = newSfLma_LicensesMap.get( p.License__c ).Package_Name__c;
			
			Opportunity opp = null;
			
			for ( Opportunity oItem : aOpenOpps ) {
				if ( oItem.License__c == p.License__c && (
						( ( oItem.Type == 'New License' || oItem.Type == 'Additional Licenses' ) && p.New_Licenses__c != null && p.New_Licenses__c > 0 ) ||
						oItem.Type == 'Renewal' && p.Renewal__c
					)
				) {
					opp = oItem;
					break;
				} 
			}
			
			Integer nNameMaxLength = Opportunity.Name.getDescribe().getLength();
			
			//-- https://silverline.jira.com/browse/SILVERLINE-124
			if ( p.Renewal__c && oldSfLma_LicensesMap.get( p.License__c ).sfLma__Status__c != 'Trial' ) {
				if ( opp == null ) {
					opp = new Opportunity();
				}
				
				if ( opp.Id == null ) {
					if ( SL_Settings.ProductSalesUser != null ) {
		    			opp.OwnerId = SL_Settings.ProductSalesUser.Id;
		    		}
					opp.License__c = p.License__c;
					opp.AccountId = newSfLma_LicensesMap.get( p.License__c ).sfLma__Account__c;
					opp.Type = 'Renewal';
					opp.pse__Practice__c = SL_Settings.idPracticeLicenses;
					opp.pse__Region__c = SL_Settings.idRegionAllSilveline;
					opp.Billing_Type__c = 'Checkout';
					opp.RecordTypeId = productRecordType.Id;
					

					if ( newSfLma_LicensesMap.get( p.License__c ).sfLma__Seats__c != -1 || ( 
						newSfLma_LicensesMap.get( p.License__c ).sfLma__Seats__c == -1 &&
						newSfLma_LicensesMap.get( p.License__c ).sfLma__Used_Licenses__c != null ) 
					) {
						Integer nTotalLicenses = (Integer)( newSfLma_LicensesMap.get( p.License__c ).sfLma__Used_Licenses__c + ( p.New_Licenses__c == null ? 0 : p.New_Licenses__c ) );
						opp.Name = ' - ' + nTotalLicenses + ' ' + packagename + ' Renewal';
					} else {
						opp.Name = ' - ' + newSfLma_LicensesMap.get( p.License__c ).sfLma__Licensed_Seats__c + ' ' + packagename + ' Renewal';
					}
					
					if ( ( accountMap.get( opp.AccountId ).Name + opp.Name ).length() > nNameMaxLength ) {
						opp.Name = accountMap.get( opp.AccountId ).Name.substring( 0, nNameMaxLength - opp.Name.length() ) + opp.Name;
					} else {
						opp.Name = accountMap.get( opp.AccountId ).Name + opp.Name;
					}
					
					if ( newSfLma_LicensesMap.get( p.License__c ).sfLma__Seats__c != -1 ) {
						opp.Number_of_Licenses__c = newSfLma_LicensesMap.get( p.License__c ).sfLma__Seats__c;

						opp.Amount = (Integer)newSfLma_LicensesMap.get( p.License__c ).sfLma__Seats__c *
							LicenseCostHelper.CalculateYearlyCost(
								newSfLma_LicensesMap.get( p.License__c ),
								(Integer)newSfLma_LicensesMap.get( p.License__c ).sfLma__Seats__c,
								newSfLma_LicensesMap.get( p.License__c ).sfLma__Package_Version__c
							);
					} else { // Site License
						opp.Number_of_Licenses__c = newSfLma_LicensesMap.get( p.License__c ).sfLma__Used_Licenses__c;
						opp.Amount = p.Total__c;
					}
					
					opp.StageName = 'Qualified Suspect';
					opp.CloseDate = newSfLma_LicensesMap.get( p.License__c ).sfLma__Expiration__c;

					opp.Projected_Start_Date__c = Date.today();
					opp.Billing_Notes__c = 'Invoice not required - Google Checkout Payment';
				} else {
					opp.StageName = 'Closed Won';
					opp.CloseDate = Date.today();
				}
				
				aOpportunities.add( opp );
			}
			if ( !p.Renewal__c || ( p.New_Licenses__c != null && p.New_Licenses__c > 0 ) ) {
				if ( ( p.Renewal__c && oldSfLma_LicensesMap.get( p.License__c ).sfLma__Status__c != 'Trial' ) || opp == null ) {
					opp = new Opportunity();
				}
				
				if ( SL_Settings.GoogleCheckoutOwner != null && oldSfLma_LicensesMap.get( p.License__c ).sfLma__Status__c == 'Trial' && newSfLma_LicensesMap.get( p.License__c ).sfLma__Status__c != 'Trial' ) {
					opp.OwnerId = SL_Settings.GoogleCheckoutOwner.Id;
				} else if ( SL_Settings.ProductSalesUser != null ) {
	    			opp.OwnerId = SL_Settings.ProductSalesUser.Id;
	    		}
				opp.License__c = p.License__c;
				
				opp.AccountId = newSfLma_LicensesMap.get( p.License__c ).sfLma__Account__c;
				opp.pse__Practice__c = SL_Settings.idPracticeLicenses;
				opp.pse__Region__c = SL_Settings.idRegionAllSilveline;
				opp.Billing_Type__c = 'Checkout';
				opp.RecordTypeId = productRecordType.Id;

				opp.Name = ' - ' + 
					( p.New_Licenses__c == null ? 0 : p.New_Licenses__c ) + ' ' +
					packagename + ' ' +
					( oldSfLma_LicensesMap.get( p.License__c ).sfLma__Status__c == 'Trial' ? 'New License' : 'Additional Licenses' );

				if ( ( accountMap.get( opp.AccountId ).Name + opp.Name ).length() > nNameMaxLength ) {
					opp.Name = accountMap.get( opp.AccountId ).Name.substring( 0, nNameMaxLength - opp.Name.length() ) + opp.Name;
				} else {
					opp.Name = accountMap.get( opp.AccountId ).Name + opp.Name;
				}

				if ( oldSfLma_LicensesMap.get( p.License__c ).sfLma__Status__c == 'Trial' ) {
					opp.Type = 'New License';
				} else if ( p.New_Licenses__c > 0 ) {
					opp.Type = 'Additional Licenses';
				}
				if ( opp.Type == null ) {
					opp.Type = 'Type not determined';
				}
				opp.CloseDate = Date.today();
				opp.StageName = 'Closed Won';
				opp.Number_of_Licenses__c = ( p.New_Licenses__c == null ? 0 : p.New_Licenses__c );
				
				opp.Projected_Start_Date__c = Date.today();
				opp.Billing_Notes__c = 'Invoice not required - Google Checkout Payment';
				aOpportunities.add( opp );
			}
			
			if ( packageName_PricebookEntryMap.get( packagename ) == null ) { //can't create oli if we can't find pricebookentry
    			system.debug( 'could not find pricebookentry to create oli in packageName_PricebookEntryMap' );
    			continue;	
    		}
			pbeid = packageName_PricebookEntryMap.get( packagename ).Id;

			OpportunityLineItem oli;
			
			if ( aOppId_PricebookEntryId_OLI.containsKey( p.Opportunity__c ) && aOppId_PricebookEntryId_OLI.get( p.Opportunity__c ).containsKey( pbeid ) ) {
				oli = aOppId_PricebookEntryId_OLI.get( p.Opportunity__c ).get( pbeid );
			}

			if ( oli == null ) {
				oli = new OpportunityLineItem(
					PricebookEntryId = pbeid
				);
			}
			oli.TotalPrice = p.Total__c;
			oli.Quantity = p.New_Licenses__c;
			if ( oli.Quantity == 0 || oli.Quantity == null ) {
				oli.Quantity = 1;
			}
			paymentIdToOpportunityProductMap.put( p.Id, oli );
    	}

    	if ( !aOpportunities.isEmpty() ) {
    		upsert aOpportunities;
    		
    		Set<ID> aAddedLineItemIds = new Set<ID>();
    		List<OpportunityLineItem> aOppLineItemsToUpsert = new List<OpportunityLineItem>();

    		for ( Id key : paymentMap.keySet() ) {
				for ( Opportunity oItem : aOpportunities ) {
					if ( paymentMap.get( key ).License__c == oItem.License__c ) {
						if ( paymentIdToOpportunityProductMap.containsKey( key ) ) {
							if ( paymentIdToOpportunityProductMap.get( key ).Id == null || !aAddedLineItemIds.contains( paymentIdToOpportunityProductMap.get( key ).Id ) ) {
								paymentIdToOpportunityProductMap.get( key ).OpportunityId = oItem.Id;
								aOppLineItemsToUpsert.add( paymentIdToOpportunityProductMap.get( key ) );
							}
							aAddedLineItemIds.add( paymentIdToOpportunityProductMap.get( key ).Id );
						}
						paymentMap.get( key ).Opportunity__c = oItem.Id;
					}
				}
    		}

    		system.debug( LoggingLevel.ERROR,
    			'\npaymentIdToOpportunityProductMap : ' + paymentIdToOpportunityProductMap +
    			'\naOppLineItemsToUpsert : ' + aOppLineItemsToUpsert
    		);

    		if ( !aOppLineItemsToUpsert.isEmpty() ) {
    			upsert aOppLineItemsToUpsert;
    		}
    		if ( !paymentMap.isEmpty() ) {
    			update paymentMap.values();
    		}
    	}
    }
    
/*	public void OnBeforeInsert( list<sfLma__License__c> newLicenses ) { }

    @future public static void OnAfterInsertAsync( Set<ID> newLicenseIDs ) { }

    public void OnBeforeUpdate( map<ID, sfLma__License__c> oldLicenseMap, map<ID, sfLma__License__c> newLicenseMap ) { }

    @future public static void OnAfterUpdateAsync( Set<ID> updatedLicenseIDs ) { }

    public void OnBeforeDelete( map<ID,sfLma__License__c> oldLicenseMap ) { }

    public void OnAfterDelete( map<ID,sfLma__License__c> oldLicenseMap ) { }

    @future public static void OnAfterDeleteAsync( Set<ID> deletedLicenseIDs ) { }

    public void OnUndelete( list<sfLma__License__c> restoredLicenses ) { }
*/
}