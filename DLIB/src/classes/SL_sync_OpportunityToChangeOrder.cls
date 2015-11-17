/**
 * \author Vladimir Dobrelya
 * \date Feb 18, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
public class SL_sync_OpportunityToChangeOrder {

	public static Boolean isSynced = false;

	private static Boolean getSynced() {
		if ( !isSynced ) {
			SL_sync_ChangeOrderToOpportunity.isSynced = true;
		}
		return isSynced;
	}

    //**************************//
	//*      INSERT LOGIC      *//
	//**************************//

	/* --- BEFORE --- */
    public static void insertNewChangeOrders( List<Opportunity> aRecords ) {
		List<Opportunity> aNeededRecords = getChangeOrdersOpps( aRecords );
		if ( aNeededRecords.isEmpty() ) {
			return;
		}

		if ( getSynced() ) {
			return;
		}

		List<Change_Order__c> aChangeOrders;

		try {
			aChangeOrders = createChangeOrders( aNeededRecords );
		} catch ( SyncException se ) {
			if ( Test.isRunningTest() ) {
				throw new SyncException();
			}
			return;
		}

		if ( !aChangeOrders.isEmpty() ) {
			insert aChangeOrders;
			relateBefore( aNeededRecords, aChangeOrders );
		}
	}

	// Relates current Opportunity records with new Change Orders
	private static void relateBefore( List<Opportunity> aRecords, List<Change_Order__c> aChangeOrders ) {
		for ( Integer nI = 0; nI < aRecords.size(); nI++ ) {
			aRecords.get( nI ).Project_Change_Order__c = aChangeOrders.get( nI ).Id;
		}
	}

	private static Map<ID, ID> getOppsByChangeOrderId( List<Opportunity> aRecords ) {
		Map<ID, ID> aResult = new Map<ID, ID>();

		for ( Opportunity oItem : aRecords ) {
			aResult.put( oItem.Project_Change_Order__c, oItem.Id );
		}

		return aResult;
	}

	private static List<Change_Order__c> createChangeOrders( List<Opportunity> aRecords ) {
		List<Change_Order__c> aResult = new List<Change_Order__c>();

		Map<ID, ID> aOppId_ProjectId = getProjectIdsByOppId( aRecords );
		// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
		Map<ID, ID> aOppId_OldProjectId = getOldProjectIdsByOppId( aRecords );
		// }

		Boolean bHasError = false;

		for ( Opportunity oItem : aRecords ) {
			// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
			//if ( !aOppId_ProjectId.containsKey( oItem.Original_Opportunity__c ) && !aOppId_OldProjectId.containsKey( oItem.Original_Opportunity__c ) ) { // }
			//	oItem.Original_Opportunity__c.addError( 'Original Opportunity must have a related Project to create new Change Order' );
			//	bHasError = true;
			//}

			aResult.add(
				new Change_Order__c(
					Name = oItem.Name,
					Account__c = oItem.AccountId,
					Billing_Notes__c = oItem.Billing_Notes__c,
					Billing_Type__c = oItem.Billing_Type__c,
					Stage__c = oItem.StageName,
					PSA_Project__c = aOppId_ProjectId.get( oItem.Original_Opportunity__c ),
					// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
					Project__c = aOppId_OldProjectId.get( oItem.Original_Opportunity__c ), // }
					Close_Date__c = oItem.CloseDate,
					Changes_to_Scope_Deliverables__c = oItem.Changes_to_Scope_Deliverables__c
				)
			);
		}

		if ( bHasError ) {
			throw new SyncException();
		}

		return aResult;
	}

	private static Map<ID, ID> getProjectIdsByOppId( List<Opportunity> aRecords ) {
		Map<ID, ID> aResult = new Map<ID, ID>();

		for ( pse__Proj__c oItem : [ SELECT Id, pse__Opportunity__c FROM pse__Proj__c WHERE pse__Opportunity__c IN :getOriginalOpportunityIds( aRecords ) ] ) {
			aResult.put( oItem.pse__Opportunity__c, oItem.Id );
		}

		return aResult;
	}

	// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
	private static Map<ID, ID> getOldProjectIdsByOppId( List<Opportunity> aRecords ) {
		Map<ID, ID> aResult = new Map<ID, ID>();

		for ( Project__c oItem : [ SELECT Id, Opportunity__c FROM Project__c WHERE Opportunity__c IN :getOriginalOpportunityIds( aRecords ) ] ) {
			aResult.put( oItem.Opportunity__c, oItem.Id );
		}

		return aResult;
	}
	// }
	
	private static Set<ID> getOriginalOpportunityIds( List<Opportunity> aRecords ) {
		Set<ID> aResult = new Set<ID>();

		for ( Opportunity oItem : aRecords ) {
			aResult.add( oItem.Original_Opportunity__c );
		}

		return aResult;
	}

	private static List<Opportunity> getChangeOrdersOpps( List<Opportunity> aRecords ) {
    	List<Opportunity> aResult = new List<Opportunity>();

    	for ( Opportunity oItem : aRecords ) {
    		if ( oItem.RecordTypeId == psaUtils.idRTOpportunityChangeOrders ) {
    			aResult.add( oItem );
    		}
    	}

    	return aResult;
    }

    /* --- AFTER --- */
    // Relates new Change Order records with current Opportunity records
	public static void relateAfter( Map<ID, Opportunity> aRecords ) {
		List<Opportunity> aNeededRecords = getChangeOrdersOpps( aRecords.values() );
		if ( aNeededRecords.isEmpty() ) {
			return;
		}

		if ( getSynced() ) {
			return;
		}

		Map<ID, ID> aChangeOrderId_OppId = getOppsByChangeOrderId( aNeededRecords );

		List<Change_Order__c> aChangeOrdersToUpdate = new List<Change_Order__c>();

		for ( Change_Order__c oItem : [ SELECT Id, Change_Order_Opportunity__c FROM Change_Order__c WHERE Id IN :aChangeOrderId_OppId.keySet() ] ) {
			if ( psaUtils.refreshRecord( oItem, new Map<String, object>{ 'Change_Order_Opportunity__c' => aChangeOrderId_OppId.get( oItem.Id ) } ) ) {
				aChangeOrdersToUpdate.add( oItem );
			}
		}

		if ( !aChangeOrdersToUpdate.isEmpty() ) {
			update aChangeOrdersToUpdate;
		}
	}


	//**************************//
	//*      UPDATE LOGIC      *//
	//**************************//

	/* --- BEFORE --- */
	public static void refreshOpportunityWithEmptyChangeOrder( List<Opportunity> aRecords ) {
    	if ( getSynced() ) {
			return;
		}

		insertNewChangeOrders( getOppsWithEmptyChangeOrder( aRecords ) );
    }

    /* --- AFTER --- */
    public static void refreshChangeOrders( Map<ID, Opportunity> aRecords ) {
    	Map<ID, Opportunity> aChangeOrderOpps = getChangeOrdersOpps( aRecords );
    	if ( aChangeOrderOpps.isEmpty() ) {
			return;
		}

		if ( getSynced() ) {
			return;
		}

    	List<Change_Order__c> aChangeOrdersToUpdate = new List<Change_Order__c>();

    	for ( Change_Order__c oItem : [
    		SELECT Name, Account__c, Billing_Notes__c, Billing_Type__c, Stage__c,
				Changes_to_Scope_Deliverables__c, Close_Date__c, Change_Order_Opportunity__c
			FROM Change_Order__c
			WHERE Change_Order_Opportunity__c IN :aChangeOrderOpps.keySet() ]
		) { 
			if ( psaUtils.refreshRecord( oItem, generateFieldMapping( aChangeOrderOpps.get( oItem.Change_Order_Opportunity__c ) ) ) ) {
				aChangeOrdersToUpdate.add( oItem );
			}
		}

		if ( !aChangeOrdersToUpdate.isEmpty() ) {
			update aChangeOrdersToUpdate;
		}
    }

    private static Map<ID, Opportunity> getChangeOrdersOpps( Map<ID, Opportunity> aRecords ) {
    	return new Map<ID, Opportunity>( getChangeOrdersOpps( aRecords.values() ) );
    }

    private static List<Opportunity> getOppsWithEmptyChangeOrder( List<Opportunity> aRecords ) {
    	List<Opportunity> aResult = new List<Opportunity>();

    	for ( Opportunity oItem : aRecords ) {
    		if ( oItem.Project_Change_Order__c == null ) {
    			aResult.add( oItem );
    		}
    	}

    	return aResult;
    }

	private static Map<String, object> generateFieldMapping( Opportunity oOpportunity ) {
		return new Map<String, object> {
			'Account__c' => oOpportunity.AccountId,
			'Name' => oOpportunity.Name,
			'Billing_Notes__c' => oOpportunity.Billing_Notes__c,
			'Billing_Type__c' => oOpportunity.Billing_Type__c,
			'Stage__c' => oOpportunity.StageName,
			'Close_Date__c' => oOpportunity.CloseDate,
			'Changes_to_Scope_Deliverables__c' => oOpportunity.Changes_to_Scope_Deliverables__c
		};
	}

	
	//**************************//
	//*      DELETE LOGIC      *//
	//**************************//
	public static void deleteChangeOrders( Set<ID> aRecordIds ) {
		if ( getSynced() ) {
			return;
		}

		List<Change_Order__c> aChangeOrders = [ SELECT Id FROM Change_Order__c WHERE Change_Order_Opportunity__c IN :aRecordIds ];
		if ( !aChangeOrders.isEmpty() ) {
			delete aChangeOrders;
		}
	}


	//****************************//
	//*      UNDELETE LOGIC      *//
	//****************************//
	public static void udeleteChangeOrders( List<Opportunity> aRecords ) {
		if ( getSynced() ) {
			return;
		}

		List<Change_Order__c> aChangeOrders = [ SELECT Id FROM Change_Order__c WHERE isDeleted = true AND Change_Order_Opportunity__c IN :aRecords ALL ROWS ];
		if ( !aChangeOrders.isEmpty() ) {
			undelete aChangeOrders;
		}
	}

	private class SyncException extends Exception { }
}