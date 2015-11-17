global class psaRollups implements Database.Batchable<sObject> {
	
	String query;
	public dlrs__LookupRollupSummary__c job;
	public dlrs__LookupRollupSummary__c jobsDef;
	public Schema.DisplayType targetType;
	public List<dlrs__LookupRollupSummary__c> lst;

	global psaRollups(List<dlrs__LookupRollupSummary__c> lst) {
		if(lst == null) {
			this.lst = [select dlrs__Active__c, dlrs__AggregateOperation__c, dlrs__AggregateResultField__c, dlrs__CalculateJobId__c, dlrs__CalculationMode__c, dlrs__ChildObject__c, dlrs__FieldToAggregate__c, dlrs__ParentObject__c, dlrs__RelationshipCriteria__c, dlrs__RelationshipCriteriaFields__c, dlrs__RelationshipField__c, Batch_Active__c, Id from dlrs__LookupRollupSummary__c where dlrs__CalculationMode__c = 'Scheduled' and dlrs__CalculateJobId__c = null and Batch_Active__c = true order by Batch_Order__c];
		} else {
			this.lst = lst;
		}
		if(this.lst.isEmpty() == false) 
		{
			this.job = this.lst[0];
 			// such bullshit
			this.targetType = Schema.getGlobalDescribe().get(job.dlrs__ParentObject__c).getDescribe().fields.getMap().get(job.dlrs__AggregateResultField__c).getDescribe().getType();
		}
	}
	
	global psaRollups() {
		this(null);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(job == null) return null;

		job.dlrs__CalculateJobId__c = BC.getJobId();
		update job;

		return Database.getQueryLocator('select Id from ' + job.dlrs__ParentObject__c);

	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		if(job != null) {
	   		List<sObject> soUpdate = new list<sObject>();
	   		Set<Id> ids = getIds(scope);
	   		for(AggregateResult ar : Database.query('select ' + job.dlrs__RelationshipField__c + ' id, ' + job.dlrs__AggregateOperation__c + '(' + job.dlrs__FieldToAggregate__c + ') aggr' +
										' from ' + job.dlrs__ChildObject__c +
										 (String.isBlank(job.dlrs__RelationshipCriteria__c)  ? (' where ') : (' where ' + job.dlrs__RelationshipCriteria__c + ' and ')) + 
										 job.dlrs__RelationshipField__c + ' in :ids GROUP by ' + job.dlrs__RelationshipField__c)) {
	   			Sobject s = createsObjectWithRollups(ar);
	   			if(s != null) soUpdate.add(s);
	   		}
	   		update soUpdate;
	   	}
	}
	
	global void finish(Database.BatchableContext BC) {
		if(job != null) {
			job.dlrs__CalculateJobId__c = null;
			update job;
			if(this.lst.isEmpty() == false) {
				this.lst.remove(0);
				if(this.lst.isEmpty() == false) Database.executeBatch(new psaRollups(this.lst));
			}
		}
	}

	private String prepareQuery() {

		String q = 'select ' + job.dlrs__RelationshipField__c + ' id, ' + job.dlrs__AggregateOperation__c + '(' + job.dlrs__FieldToAggregate__c + ') aggr' +
									' from ' + job.dlrs__ChildObject__c + ' where ' + job.dlrs__RelationshipCriteria__c + ' and ' + job.dlrs__RelationshipField__c + ' in :getIds(scope) GROUP by ' + job.dlrs__RelationshipField__c;		
		system.debug(q);
		return q;
	}

	private sObject createsObjectWithRollups(AggregateResult ar) {
		sObject s = Schema.getGlobalDescribe().get(job.dlrs__ParentObject__c).newSObject() ;
 		s.Id = (Id)ar.get('id');

 		
		//Schema.DisplayType sourceType = Schema.getGlobalDescribe().get(job.dlrs__ChildObject__c).fields.getMap().get(job.dlrs__AggregateResultField__c).getDescribe().getType();
		if(targetType == Schema.DisplayType.INTEGER) {
			s.put(job.dlrs__AggregateResultField__c, Integer.valueOf((Decimal)ar.get('aggr')));
		} else if(targetType == Schema.DisplayType.DOUBLE) {
			s.put(job.dlrs__AggregateResultField__c, (Decimal)ar.get('aggr'));
		} else {
			return null;
		}
 		
		return s;
	}

	private Set<Id> getIds(List<sObject> scope) {
		List<sObject> projects = (List<sObject>)scope;
		Set<Id> setIds = new Set<Id>();

		for(sObject p : projects) {
			setIds.add(p.Id);
		}

		return setIds;
	}



}