/*
 * \author Vladimir Dobrelya
 * \see https://silverline.jira.com/browse/SLFF-18
 */
global with sharing class psaProjectRefesh {
	
	// Custom Button on Project's detail page calls this method
	WebService static void refreshProject( ID idProject ) {
		psaRefreshProjectFuture( new Set<ID>{ idProject } );
	}

	@future // Refreshes summary fields on pse__Proj__c object
	public static void psaRefreshProjectFuture( Set<ID> aProjectIds ) {
		psaRefreshProject( aProjectIds );
	}

	public static void psaRefreshProject( Set<ID> aProjectIds ) {
		refreshProjectPhases( aProjectIds );
		//psaRefreshProject_Milestones( aProjectIds );
		refreshProjectFields(aProjectIds);
	}

	/*public static void psaRefreshProject_Milestones( Set<ID> aProjectIds ) {
		List<pse__Proj__c> aProjectsToUpdate = new List<pse__Proj__c>();
		Map<ID, Map<String, object>> aCalculatedProjectData = getCalculatedProjectData( aProjectIds, getMilestonesByProjectId( refreshParentMilestones( aProjectIds ) ) );

		for ( pse__Proj__c oItem : [ SELECT Id, Actual_Hours__c, Estimated_Hours__c FROM pse__Proj__c WHERE Id IN :aProjectIds ] ) {
			if ( psaUtils.refreshRecord( oItem, aCalculatedProjectData.get( oItem.Id ) ) ) {
				aProjectsToUpdate.add( oItem );
			}
		}

		if ( !aProjectsToUpdate.isEmpty() ) {
			update aProjectsToUpdate;
		}
	}*/

	// Returns calculated data for pse__Proj__c objects as Map ( pse__Proj__c.ID => Map<String, object> )
	private static Map<ID, Map<String, object>> getCalculatedProjectData( Set<ID> aProjectIds, Map<ID, List<pse__Milestone__c>> aMilestonesByProjectId ) {
		Map<ID, Map<String, object>> aResult = new Map<ID, Map<String, object>>();

		for ( ID idProject : aProjectIds ) {
			if ( !aResult.containsKey( idProject ) ) {
				aResult.put( idProject,
					new Map<String, object> {
						'Actual_Hours__c' => 0.0//,
						//'Estimated_Hours__c' => 0.0
					}
				);
			}
			if ( aMilestonesByProjectId.containsKey( idProject ) ) {
				for ( pse__Milestone__c oMilestone : aMilestonesByProjectId.get( idProject ) ) {
					aResult.get( idProject ).put( 'Actual_Hours__c', ( Decimal )aResult.get( idProject ).get( 'Actual_Hours__c' ) + oMilestone.Actual_Hours__c );
					//aResult.get( idProject ).put( 'Estimated_Hours__c', ( Decimal )aResult.get( idProject ).get( 'Estimated_Hours__c' ) + oMilestone.Estimated_Hours__c );
				}
			}
		}

		return aResult;
	}

	// Calculates and updates summary fields of PARENT_TASK Milestones
	private static List<pse__Milestone__c> refreshParentMilestones( Set<ID> aProjectIds ) {

		Map<ID, pse__Milestone__c> aParentMilestones = getParentMilestones( aProjectIds );
		if ( aParentMilestones.isEmpty() ) {
			return aParentMilestones.values();
		}

		Set<ID> aRefreshedMilestones = new Set<ID>();
		List<pse__Milestone__c> aMilestonesToUpdate = new List<pse__Milestone__c>();
		Map<ID, pse__Milestone__c> aRolledUpMilestones = new Map<ID, pse__Milestone__c>();

		ID idParentMilestone;

		// Refresh the PARENT_CHILD Milestones which have CHILD_TASK
		for ( AggregateResult oItem : [
			SELECT SUM( Actual_Hours__c ) ah, SUM( Estimated_Hours__c ) eh, Parent_Milestone__c p
			FROM pse__Milestone__c
			WHERE pse__Project__c IN :aProjectIds AND
				pse__Status__c != 'Canceled' AND
				Parent_Milestone__c IN :aParentMilestones.keySet() AND 
				RecordTypeId = :psaUtils.idRTChildTask
			GROUP BY Parent_Milestone__c
		] ) {
			idParentMilestone = ( ID )oItem.get( 'p' );

			if ( psaUtils.refreshRecord( aParentMilestones.get( idParentMilestone ),
				new Map<String, object> {
					'Actual_Hours__c' => oItem.get( 'ah' ) != null ? oItem.get( 'ah' ) : 0.0,
					'Estimated_Hours__c' => oItem.get( 'eh' ) != null ? oItem.get( 'eh' ) : 0.0
				} )
			) {
				aMilestonesToUpdate.add( aParentMilestones.get( idParentMilestone ) );
			}
			aRolledUpMilestones.put( idParentMilestone, aParentMilestones.get( idParentMilestone ) );
		}

		// Refresh the Milestones which have no CHILD_TASKs
		if ( !aRolledUpMilestones.keySet().containsAll( aParentMilestones.keySet() ) ) {
			for ( pse__Milestone__c oItem : aParentMilestones.values() ) {
				if ( !aRolledUpMilestones.keySet().contains( oItem.Id ) ) {
					if ( psaUtils.refreshRecord( oItem,
						new Map<String, object> {
							'Actual_Hours__c' => 0.0,
							'Estimated_Hours__c' => 0.0
						} )
					) {
						aMilestonesToUpdate.add( oItem );
						aRolledUpMilestones.put( oItem.Id, oItem );
					}
				}
			}
		}

		update aMilestonesToUpdate;
		return aRolledUpMilestones.values();
	}

	// Converts List of Milestones to Map ( Milestone.pse__Project__c => Milestone )
	private static Map<ID, List<pse__Milestone__c>> getMilestonesByProjectId( List<pse__Milestone__c> aMilestones ) {
		Map<ID, List<pse__Milestone__c>> aResult = new Map<ID, List<pse__Milestone__c>>();

		for ( pse__Milestone__c oItem : aMilestones ) {
			if ( !aResult.containsKey( oItem.pse__Project__c ) ) {
				aResult.put( oItem.pse__Project__c, new List<pse__Milestone__c>() );
			}
			aResult.get( oItem.pse__Project__c ).add( oItem );
		}

		return aResult;
	}

	// Returns map of PATENT_TASK Milestones related to Projects( aProjectIds )
	private static Map<ID, pse__Milestone__c> getParentMilestones( Set<ID> aProjectIds ) {
		// Get PARENT_TASK Milestones
		return new Map<ID, pse__Milestone__c>( [
			SELECT Id, Actual_Hours__c, Estimated_Hours__c, pse__Project__c
			FROM pse__Milestone__c
			WHERE pse__Project__c IN :aProjectIds AND
				pse__Status__c != 'Canceled' AND
				RecordTypeId = :psaUtils.idRTParentTask
		] );
	}
	
	public static void rollupTimecardFieldsToProjectPhase(set<id> setProjectPhaseIds) {
		map<Id,list<Decimal>> mapBillableHours = new map<Id,list<Decimal>>();
		map<Id,list<Decimal>> mapNonBillableHours = new map<Id,list<Decimal>>();
		map<Id,list<Decimal>> mapBillableAmount = new map<Id,list<Decimal>>();
		for (pse__Timecard_Header__c item:[Select pse__Billable__c, pse__Total_Hours__c, pse__Total_Billable_Amount__c, pse__Project_Phase_Object__c 
										FROM pse__Timecard_Header__c 
										//WHERE pse__Project_Phase_Object__c IN :setProjectPhaseIds AND pse__Status__c = 'Approved'])
										WHERE pse__Project_Phase_Object__c IN :setProjectPhaseIds AND pse__Approved__c = true])
		{
			if (!mapBillableHours.containsKey(item.pse__Project_Phase_Object__c)) mapBillableHours.put(item.pse__Project_Phase_Object__c, new list<Decimal>());
			if (!mapNonBillableHours.containsKey(item.pse__Project_Phase_Object__c)) mapNonBillableHours.put(item.pse__Project_Phase_Object__c, new list<Decimal>());
			if (!mapBillableAmount.containsKey(item.pse__Project_Phase_Object__c)) mapBillableAmount.put(item.pse__Project_Phase_Object__c, new list<Decimal>());
			
			if (item.pse__Billable__c) {
				mapBillableHours.get(item.pse__Project_Phase_Object__c).add(item.pse__Total_Hours__c);
			} else {
				mapNonBillableHours.get(item.pse__Project_Phase_Object__c).add(item.pse__Total_Hours__c);
			}
			
			mapBillableAmount.get(item.pse__Project_Phase_Object__c).add(item.pse__Total_Billable_Amount__c);
		}
		
		list<pse__Project_Phase__c> lstProjectPhases = new list<pse__Project_Phase__c>();
		for (pse__Project_Phase__c item:[Select Id, Actual_Hours_Billable__c, Actual_Hours_Non_Billable__c, Total_Billable_Amount__c 
										FROM pse__Project_Phase__c WHERE Id IN :setProjectPhaseIds limit 10000])
		{
			item.Actual_Hours_Billable__c = 0;
			if (mapBillableHours.containsKey(item.Id)) {
				for (decimal h:mapBillableHours.get(item.Id)) {
					item.Actual_Hours_Billable__c += h;
				}
			}
			
			item.Actual_Hours_Non_Billable__c = 0;
			if (mapNonBillableHours.containsKey(item.Id)) {
				for (decimal h:mapNonBillableHours.get(item.Id)) {
					item.Actual_Hours_Non_Billable__c += h;
				}
			}
			
			item.Total_Billable_Amount__c = 0;
			if (mapBillableAmount.containsKey(item.Id)) {
				for (decimal a:mapBillableAmount.get(item.Id)) {
					item.Total_Billable_Amount__c += a;
				}
			}
			lstProjectPhases.add(item);
		}
		if (lstProjectPhases.size()>0) update lstProjectPhases;
		
		psaTimecardHandler.isDone = true;
	}
	
	private static void refreshProjectPhases( Set<ID> aProjectIds ) {
		set<Id> setProjectPhaseIds = new set<Id>();
		for (pse__Project_Phase__c item:[Select Id FROM pse__Project_Phase__c WHERE pse__Project__c IN :aProjectIds limit 10000]) {
			setProjectPhaseIds.add(item.id);
		}
		
		if (setProjectPhaseIds.size()>0) rollupTimecardFieldsToProjectPhase(setProjectPhaseIds);
	}
	
	public static void refreshProjectFields(Set<ID> setProjectIds) {
		map<Id,decimal> mapBudgets = new map<Id,decimal>();
		map<Id,decimal> mapEstHours = new map<Id,decimal>();
		list<pse__Proj__c> lstProjects = new list<pse__Proj__c>();
		
		Map<ID, Map<String, object>> aCalculatedProjectData = getCalculatedProjectData( setProjectIds, getMilestonesByProjectId( refreshParentMilestones( setProjectIds ) ) );
		
		for (pse__Budget__c item:[Select pse__Project__c, pse__Amount__c FROM pse__Budget__c WHERE pse__Project__c IN :setProjectIds limit 10000]) {
			if (item.pse__Amount__c!=null) {
				if (!mapBudgets.containsKey(item.pse__Project__c)) mapBudgets.put(item.pse__Project__c,item.pse__Amount__c);
				else mapBudgets.put(item.pse__Project__c,mapBudgets.get(item.pse__Project__c)+item.pse__Amount__c);
			}
		}
		
		for (pse__Milestone__c item:[Select pse__Project__c, Estimated_Hours__c FROM pse__Milestone__c 
							WHERE pse__Project__c IN :setProjectIds 
							AND RecordType.DeveloperName = 'CHILD_TASK' AND pse__Status__c!='Canceled' limit 10000]) {
			if (item.Estimated_Hours__c!=null) {
				if (!mapEstHours.containsKey(item.pse__Project__c)) mapEstHours.put(item.pse__Project__c,item.Estimated_Hours__c);
				else mapEstHours.put(item.pse__Project__c,mapEstHours.get(item.pse__Project__c)+item.Estimated_Hours__c);
			}
		}
		
		for (pse__Proj__c item:[Select Id, Budget_Amount__c, Estimated_Hours__c, Actual_Hours__c FROM pse__Proj__c WHERE Id IN :setProjectIds]) {
			psaUtils.refreshRecord(item, aCalculatedProjectData.get(item.Id));
			
			if (mapBudgets.containsKey(item.Id)) item.Budget_Amount__c = mapBudgets.get(item.Id);
			else item.Budget_Amount__c = 0;
			
			if (mapEstHours.containsKey(item.Id)) item.Estimated_Hours__c = mapEstHours.get(item.Id);
			else item.Estimated_Hours__c = 0;
			
			lstProjects.add(item);
		}
		
		if (!lstProjects.isEmpty()) update lstProjects;
	}
	
	
	/*private static void refreshProjectPhases( Set<ID> aProjectIds ) {
		Map<ID, pse__Project_Phase__c> aProjectPhases = new Map<ID, pse__Project_Phase__c>( [ SELECT Id, SomeField FROM pse__Project_Phase__c WHERE pse__Project__c IN :aProjectIds ] );
		List<pse__Project_Phase__c> aProjectPhasesToUpdate = new List<pse__Project_Phase__c>();
		
		ID idProjectPhase;
		
		for ( AggregateResult oItem : [ SELECT SUM( pse__Total_Hours__c ) th, pse__Project_Phase_Object__c pp FROM pse__Timecard_Header__c WHERE pse__Project_Phase_Object__c IN :aProjectPhases.keySet() ] ) {
			idProjectPhase = ( ID )oItem.get( 'pp' );
			
			if ( psaUtils.refreshRecord( aProjectPhases.get( idProjectPhase ),
				new Map<String, object> {
					'SomeField' => ( Decimal )oItem.get( 'th' )
				} )
			) {
				aProjectPhasesToUpdate.add( aProjectPhases.get( idProjectPhase ) );
			}
		}
		
		if ( !aProjectPhasesToUpdate.isEmpty() ) {
			update aProjectPhasesToUpdate;
		}
	}*/
}