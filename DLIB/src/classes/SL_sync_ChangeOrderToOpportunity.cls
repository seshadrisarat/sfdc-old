/**
 * \author Vladimir Dobrelya
 * \date Feb 18, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
public class SL_sync_ChangeOrderToOpportunity {

	public static Boolean isSynced = false;

	private static Boolean getSynced() {
		if ( !isSynced ) {
			SL_sync_OpportunityToChangeOrder.isSynced = true;
		}
		return isSynced;
	}

	//**************************//
	//*      INSERT LOGIC      *//
	//**************************//
	public static void insertNewOpportunities( List<Change_Order__c> aRecords ) {
		if ( getSynced() ) {
			return;
		}

		List<Opportunity> aOpportunities;

		try {
			aOpportunities = createOpportunities( aRecords );	
		} catch ( SyncException se ) {
			if ( Test.isRunningTest() ) {
				throw new SyncException();
			}
			return;
		}

		if ( !aOpportunities.isEmpty() ) {
			insert aOpportunities;
			relateBefore( aRecords, aOpportunities );
		}
	}

	private static void relateBefore( List<Change_Order__c> aRecords, List<Opportunity> aOpportunities ) {
		for ( Integer nI = 0; nI < aRecords.size(); nI++ ) {
			aRecords.get( nI ).Change_Order_Opportunity__c = aOpportunities.get( nI ).Id;
		}
	}

	public static void relateAfter( Map<ID, Change_Order__c> aRecords ) {
		if ( getSynced() ) {
			return;
		}

		List<Opportunity> aOpportunitiesToUpdate = new List<Opportunity>();

		Map<ID, ID> aOppId_ChangeOrderId = getChangeOrdersByOppId( aRecords );

		for ( Opportunity oItem : [ SELECT Id, Project_Change_Order__c FROM Opportunity WHERE Id IN :aOppId_ChangeOrderId.keySet() ] ) {
			if ( psaUtils.refreshRecord( oItem, new Map<String, object>{ 'Project_Change_Order__c' => aOppId_ChangeOrderId.get( oItem.Id ) } ) ) {
				aOpportunitiesToUpdate.add( oItem );
			}
		}

		if ( !aOpportunitiesToUpdate.isEmpty() ) {
			update aOpportunitiesToUpdate;
		}
	}

	private static Map<ID, ID> getChangeOrdersByOppId( Map<ID, Change_Order__c> aRecords ) {
		Map<ID, ID> aResult = new Map<ID, ID>();

		for ( Change_Order__c oItem : aRecords.values() ) {
			aResult.put( oItem.Change_Order_Opportunity__c, oItem.Id );
		}

		return aResult;
	}

	private static List<Opportunity> createOpportunities( List<Change_Order__c> aRecords ) {
		List<Opportunity> aResult = new List<Opportunity>();

		Map<ID, ID> aOldProjectId_OppId = getOppIdByOldProject( aRecords );
		Map<ID, pse__Proj__c> aProjectId_Project = getOppIdByProjectId( aRecords );

		Boolean bHasError = false;

		for ( Change_Order__c oItem : aRecords ) {
			if ( !aProjectId_Project.containsKey( oItem.PSA_Project__c ) ) {
				// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
				if ( !aOldProjectId_OppId.containsKey( oItem.Project__c ) ) { // }
					oItem.PSA_Project__c.addError( 'You must enter a value.' );
					bHasError = true;
				}
			}

			aResult.add(
				new Opportunity(
					Name = oItem.Name,
					AccountId = oItem.Account__c,
					Billing_Notes__c = oItem.Billing_Notes__c,
					Billing_Type__c = oItem.Billing_Type__c,
					StageName = oItem.Stage__c,
					// Original_Opportunity__c = aProjectId_OppId.get( oItem.PSA_Project__c ),
					// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
					Original_Opportunity__c = aProjectId_Project.containsKey( oItem.PSA_Project__c ) ? aProjectId_Project.get( oItem.PSA_Project__c ).pse__Opportunity__c : aOldProjectId_OppId.get( oItem.Project__c ), // }
					pse__Region__c = aProjectId_Project.containsKey( oItem.PSA_Project__c ) ? aProjectId_Project.get( oItem.PSA_Project__c ).pse__Region__c : null,
					pse__Practice__c = aProjectId_Project.containsKey( oItem.PSA_Project__c ) ? aProjectId_Project.get( oItem.PSA_Project__c ).pse__Practice__c : null,
					CloseDate = oItem.Close_Date__c,
					Changes_to_Scope_Deliverables__c = oItem.Changes_to_Scope_Deliverables__c,
					RecordTypeId = psaUtils.idRTOpportunityChangeOrders
				)
			);
		}

		if ( bHasError ) {
			throw new SyncException();
		}

		return aResult;
	}

	private static Map<ID, pse__Proj__c> getOppIdByProjectId( List<Change_Order__c> aRecords ) {
		Map<ID, pse__Proj__c> aResult = new Map<ID, pse__Proj__c>();

		for ( pse__Proj__c oItem : [ SELECT Id, pse__Opportunity__c, pse__Region__c, pse__Practice__c FROM pse__Proj__c WHERE Id IN :getProjectIds( aRecords ) ] ) {
			aResult.put( oItem.Id, oItem );
		}

		return aResult;
	}

	private static Map<ID, ID> getOppIdByOldProject( List<Change_Order__c> aRecords ) {
		Map<ID, ID> aResult = new Map<ID, ID>();

		// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
		for ( Project__c oItem : [ SELECT Id, Opportunity__c FROM Project__c WHERE Id IN :getProjectIds( aRecords ) ] ) {
			aResult.put( oItem.Id, oItem.Opportunity__c );
		}
		//

		return aResult;
	}

	private static Set<ID> getProjectIds( List<Change_Order__c> aRecords ) {
		Set<ID> aResult = new Set<ID>();

		for ( Change_Order__c oItem : aRecords ) {
			// TO REMOVE AFTER MOVING TO USING ONLY pse__Proj__c OBJECT {
			aResult.add( oItem.Project__c );
			// }
			aResult.add( oItem.PSA_Project__c );
		}

		return aResult;
	}


	//**************************//
	//*      UPDATE LOGIC      *//
	//**************************//

	/* --- BEFORE --- */
	public static void updateChangeOrderWithEmptyOpportunity( List<Change_Order__c> aRecords ) {
    	if ( getSynced() ) {
			return;
		}

		List<Change_Order__c> aChangeOrdersWithEmptyOpp = getChangeOrdersWithEmptyOpp( aRecords );
		if ( !aChangeOrdersWithEmptyOpp.isEmpty() ) {
			insertNewOpportunities( aChangeOrdersWithEmptyOpp );
		}
    }

    private static List<Change_Order__c> getChangeOrdersWithEmptyOpp( List<Change_Order__c> aRecords ) {
		List<Change_Order__c> aResult = new List<Change_Order__c>();

    	for ( Change_Order__c oItem : aRecords ) {
    		if ( oItem.Change_Order_Opportunity__c == null ) {
    			aResult.add( oItem );
    		}
    	}

    	return aResult;
	}

	/* --- AFTER --- */
	public static void updateOpportunities( Map<ID, Change_Order__c> aRecords ) {
		if ( getSynced() ) {
			return;
		}

    	List<Opportunity> aOpportunitiesToUpdate = new List<Opportunity>();

    	for ( Opportunity oItem : [
    		SELECT Name, AccountId, Billing_Notes__c, Billing_Type__c, StageName,
				Changes_to_Scope_Deliverables__c, CloseDate, Project_Change_Order__c
			FROM Opportunity
			WHERE Project_Change_Order__c IN :aRecords.keySet() ]
		) {
			if ( psaUtils.refreshRecord( oItem, generateFieldMapping( aRecords.get( oItem.Project_Change_Order__c ) ) ) ) {
				aOpportunitiesToUpdate.add( oItem );
			}
		}

		if ( !aOpportunitiesToUpdate.isEmpty() ) {
			update aOpportunitiesToUpdate;
		}
	}

	private static Map<String, object> generateFieldMapping( Change_Order__c oRecord ) {
		return new Map<String, object> {
			'AccountId' => oRecord.Account__c,
			'Name' => oRecord.Name,
			'Billing_Notes__c' => oRecord.Billing_Notes__c,
			'Billing_Type__c' => oRecord.Billing_Type__c,
			'StageName' => oRecord.Stage__c,
			'CloseDate' => oRecord.Close_Date__c,
			'Changes_to_Scope_Deliverables__c' => oRecord.Changes_to_Scope_Deliverables__c
		};
	}


	//**************************//
	//*      DELETE LOGIC      *//
	//**************************//
	public static void deleteOpportunities( Set<ID> aRecordIds ) {
		if ( getSynced() ) {
			return;
		}

		List<Opportunity> aOpportunities = [ SELECT Id FROM Opportunity WHERE Project_Change_Order__c IN :aRecordIds ];
		if ( !aOpportunities.isEmpty() ) {
			delete aOpportunities;
		}
	}


	//****************************//
	//*      UNDELETE LOGIC      *//
	//****************************//
	public static void undeleteOpportunities( List<Change_Order__c> aRecords ) {
		if ( getSynced() ) {
			return;
		}

		List<Opportunity> aOpportunities = [ SELECT Id FROM Opportunity WHERE isDeleted = true AND Project_Change_Order__c IN :aRecords ALL ROWS ];
		if ( !aOpportunities.isEmpty() ) {
			undelete aOpportunities;
		}
	}

	private class SyncException extends Exception { }
}