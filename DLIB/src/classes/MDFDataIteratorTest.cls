@isTest
private class MDFDataIteratorTest {
    
    static testMethod void testBasic() {
		MetricsDataFile mdf = new MetricsDataFile();
		mdf.MetricsType = 'Visualforce';
		mdf.MetricsStartDate = datetime.now();
		mdf.MetricsEndDate = mdf.MetricsStartDate;
		mdf.NamespacePrefix = 'NS';
		mdf.SendingInstance = 'xx';
		mdf.MetricsDataFileLength = 1;
		String metricsDataFileContents = '"00DyyMOCKORG1","Mock Org 1","Enterprise Edition","TRIAL","apex/mockPage1","862","27","47"' + '\n'
			+ '"00DyyMOCKORG2","Mock Org 2","Enterprise Edition","TRIAL","apex/mockPage1","25","20","56"' + '\n';
		mdf.MetricsDataFile = Blob.valueOf(metricsDataFileContents);
		
		MDFDataIterator mdfDataIter = new MDFDataIterator(null, new MDFDataLineParser(), mdf);
		Iterator<MDFDataModel> iter = mdfDataIter.iterator();
		
		/* we should be able to call hasNext infinite times as long as we don't call next() 
		 * (or just more than the actual number of elements...) */
		System.assert(iter.hasNext());
		System.assert(iter.hasNext());
		System.assert(iter.hasNext());
		System.assert(iter.hasNext());
		
        List<MDFDataModel> modelsParsed = new List<MDFDataModel>();
		while (iter.hasNext()) {
			MDFDataModel model = iter.next();
            modelsParsed.add(model);
		}
		
		System.assertEquals(2, modelsParsed.size(), 'There should be 2 models');
        System.assertEquals('00DyyMOCKORG1', modelsParsed.get(0).subscriberOrgId);
		System.assertEquals('00DyyMOCKORG2', modelsParsed.get(1).subscriberOrgId);
        
        /* get a new iterator - it should be stateless so this should start from the beginning again */
        iter = mdfDataIter.iterator();
        /* verify that we can just call next() consecutively (even though I wouldn't advise it...) */
		MDFDataModel model = iter.next();
        System.assertEquals('00DyyMOCKORG1', model.subscriberOrgId);
		model = iter.next();
        System.assertEquals('00DyyMOCKORG2', model.subscriberOrgId);
        /* we know we only have 2 items so this should return null */
        model = iter.next();
        System.assert(model == null);
        /* and now hasNext should return false */
        System.assert(!iter.hasNext());
        
        /* taking a shortcut here and not creating another test method because we can just reuse the data for the mdf we already created above... 
         * - testing the fact that the filtering works */
		mdfDataIter = new MDFDataIterator(new MDFLineFilters.SubscriberOrgFilter('00DyyMOCKORG2'), new MDFDataLineParser(), mdf);
		iter = mdfDataIter.iterator();
		/* start of a fresh iterator */
		System.assert(iter.hasNext());
		/* the first (and only) model should be the second one (matches orgId 00DyyMOCKORG2) */
		model = iter.next();
		System.assertEquals('00DyyMOCKORG2', model.subscriberOrgId);
		System.assert(!iter.hasNext());
		model = iter.next();
		System.assert(model == null);        
	}
	
    static testMethod void testInvalidConstructor() {
        Exception x = null;
        try {
			MDFDataIterator mdfDataIter = new MDFDataIterator(null, null, null);            
        }
        catch (MDFDataIterator.MDFDataIteratorException mdfX) {
            x = mdfX;
        }
        
        System.assert(x != null);
    }
    
    static testMethod void testNullMdfFile() {
		MDFDataIterator mdfDataIter = new MDFDataIterator(null, new MDFDataLineParser(), null);            
        System.assert(!mdfDataIter.iterator().hasNext());
    }
}