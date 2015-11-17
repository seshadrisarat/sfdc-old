public with sharing class MDFQueryDAOImpl implements MDFQueryDAO {
	
	public List<MetricsDataFile> findMDFs(String sendingInstanceId, Date lookbackStartDate) {
		return  [SELECT NamespacePrefix, MetricsDataFileLength, MetricsDataFile FROM MetricsDataFile 
    														WHERE SendingInstance = :sendingInstanceId 
    														AND MetricsStartDate >= :lookbackStartDate];
	}
	
	public List<MetricsDataFile> findMDFs(String metricsType, String namespacePrefix, Date lookbackStartDate) {
		return [SELECT Id, SendingInstance, NamespacePrefix, MetricsType, MetricsStartDate, MetricsEndDate, MetricsDataFileLength, MetricsDataFile
                        FROM MetricsDataFile WHERE MetricsType = :metricsType AND NamespacePrefix = :namespacePrefix
                        AND MetricsStartDate >= :lookbackStartDate ORDER BY MetricsStartDate DESC];
	}
	
	public Set<String> findNamespaces() {
		Set<String> namespaces = new Set<String>();

		List<AggregateResult> results =  [SELECT NamespacePrefix FROM MetricsDataFile GROUP BY NamespacePrefix limit 25];
		for(AggregateResult r : results){
			namespaces.add(String.valueOf(r.get('NamespacePrefix')));
		}   
		
		return namespaces;     	
	}
}