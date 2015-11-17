@isTest
private class MDFDataManagerTest {

	static testMethod void testFindNamespacesForSubscriberOrg() {
		MDFTestObjectBuilder testObjectBuilder = new MDFTestObjectBuilder();
		
		MDFTestObjectBuilder.MetricsDataFileContentBuilder contentBuilder = testObjectBuilder.getMDFContentBuilder();
		contentBuilder.withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
			.withDataFormatVersion(30)
			.startNewOrgContext('00Daa00TESTORG1', 'TRIAL')
			.addResource('apex/foo1', 100)
			.addResource('apex/foo2', 200);
		
		/* this one should match */	
		testObjectBuilder.getMDFBuilder()
			.withContent(contentBuilder.build())
			.withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
			.withNamespacePrefix('test_ns_1')
			.withSendingInstance('aa')
			.build();
		/* this one should not */	
		contentBuilder = testObjectBuilder.getMDFContentBuilder();
		contentBuilder.withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
			.withDataFormatVersion(30)
			.startNewOrgContext('00Daa00TESTORG2', 'TRIAL')
			.addResource('apex/foo1', 200);		
		testObjectBuilder.getMDFBuilder()
			.withContent(contentBuilder.build())
			.withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
			.withNamespacePrefix('test_ns_2')
			.withSendingInstance('aa')
			.build();
		
		MDFDataManager mgr = new MDFDataManager(testObjectBuilder.getDAO());
			
		Set<String> namespaces = mgr.findNamespacesForSubscriberOrg('00Daa00TESTORG1', MDFTestObjectBuilder.VALID_TYPE_VF);
		System.assertEquals(1, namespaces.size());
		System.assert(namespaces.contains('test_ns_1'));
	}
}