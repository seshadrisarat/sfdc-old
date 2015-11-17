/**
 * Test helper class that will handle all of the object construction for test MetricsDataFile objects
 */
@isTest
public class MDFTestObjectBuilder {

	public static final String VALID_TYPE_VF = 'VISUALFORCE';
	public static final String VALID_TYPE_CO = 'CUSTOMOBJECT';
	
	private static final String LINE_TEMPATE_VF_V30 = '"{0}","ORG_NAME","ORG_TYPE","{1}","{2}","{3}","1","30"';
	private static final String LINE_TEMPATE_VF_V31 = '"{0}","ORG_NAME","ORG_TYPE","{1}","1.0","{2}","{3}","1","31"';
	private static final String LINE_TEMPATE_CO_V30 = '"{0}","ORG_NAME","ORG_TYPE","{1}","{2}"';
	private static final String LINE_TEMPATE_CO_V31 = '"{0}","ORG_NAME","ORG_TYPE","{1}","1.0","{2}","{3}"';

	private MDFTestObjectDAO dao;
	
	public MDFTestObjectBuilder() {
		dao = new MDFTestObjectDAO();
	}
	
	public MDFTestObjectDAO getDAO() {
		return dao;
	}
	
	public MetricsDataFileBuilder getMDFBuilder() {
		return new MetricsDataFileBuilder(this);
	}
	
	public MetricsDataFileContentBuilder getMDFContentBuilder() {
		return new MetricsDataFileContentBuilder();
	}
	
	public void save(MetricsDataFile mdf) {
		dao.save(mdf);
	}
	
	/**
	 * Builder styled class which will build a MetricsDataFile (and persist it to the internal test impl of the MDFQueryDAO).
	 * This will default any properties not defined. 
	 */
	public class MetricsDataFileBuilder {
		private Blob content;
		private DateTime endDate;
		private String metricsType;
		private String namespacePrefix;
		private String sendingInstance;
		private DateTime startDate;
		
		private MDFTestObjectBuilder parent;
		
		private MetricsDataFileBuilder(MDFTestObjectBuilder parent) {
			this.parent = parent;
		}
		
		public MetricsDataFile build() {
			MetricsDataFile mdf = new MetricsDataFile();
			mdf.MetricsEndDate = this.endDate == null ? getDateTimeTrunc() : this.endDate;
			mdf.MetricsStartDate = this.startDate == null ? getDateTimeTrunc() : this.startDate;
			mdf.MetricsType = this.metricsType;
			mdf.NamespacePrefix = this.namespacePrefix == null ? 'default_test_ns' : this.namespacePrefix;
			mdf.SendingInstance = this.sendingInstance == null ? 'xx' : this.sendingInstance;
			if (this.content != null) {
				/* this is set internally, but anything greater than 1 suffices for tests */
				mdf.MetricsDataFileLength = 1;
				mdf.MetricsDataFile = content;
			}
			else {
				mdf.MetricsDataFileLength = 0;
			}
			
			parent.save(mdf);
			return mdf;
		}
		
		public MetricsDataFileBuilder withContent(Blob content) {
			this.content = content;
			return this;
		}
		
		public MetricsDataFileBuilder withEndDate(DateTime endDate) {
			this.endDate = endDate;
			return this;
		}
		
		public MetricsDataFileBuilder withMetricsType(String metricsType) {
			this.metricsType = metricsType;
			return this;
		}
		
		public MetricsDataFileBuilder withNamespacePrefix(String namespacePrefix) { 
			this.namespacePrefix = namespacePrefix;
			return this;
		}
		
		public MetricsDataFileBuilder withSendingInstance(String sendingInstance) {
			this.sendingInstance = sendingInstance;
			return this;
		}
		
		public MetricsDataFileBuilder withStartDate(DateTime startDate) {
			this.startDate = startDate;
			return this;
		}
	}
	
	/**
	 * Builder styled class which will build the content for the MetricsDataFile.
	 * This will default any properties not defined. 
	 */
	public class MetricsDataFileContentBuilder {
		private List<String> lines = new List<String>();
		
		private String buildingContextOrgId;
		private String buildingContextOrgStatus;
		
		/* default to the original data format (no package version) */
		private Integer version = 30;
		private String type = VALID_TYPE_VF;
		
		private MetricsDataFileContentBuilder() {
		}
		
		public MetricsDataFileContentBuilder addResource(String resourceName, Integer resourceCount) {
			lines.add(buildLine(buildingContextOrgId, buildingContextOrgStatus, resourceName, resourceCount, version, type));
			
			return this;
		}

		public Blob build() {
			String theString = '';
			for (String line : lines) {
				theString += line + '\n';
			}
			
			return Blob.valueOf(theString);
		}
		
		public MetricsDataFileContentBuilder startNewOrgContext(String orgId, String orgStatus) {
			this.buildingContextOrgId = orgId;
			this.buildingContextOrgStatus = orgStatus.toUpperCase(); // org status is always uppercase...			
			
			return this;
		}
		
		public MetricsDataFileContentBuilder withDataFormatVersion(Integer version) {
			this.version = version;
			return this;
		}
		
		public MetricsDataFileContentBuilder withMetricsType(String type) {
			/* only override the default if its a valid type */
			if (type.equals(VALID_TYPE_VF) || type.equals(VALID_TYPE_CO)){
				this.type = type;
			}
			
			return this;
		}
	}
	
	/**
	 * Builds a String line formatted according to the defined version with the provided values.
	 * If any null values are provided, they will be replaced with defaults.
	 */
	public static String buildLine(String orgId, String orgStatus, String resourceName, Integer resourceCount, Integer version, String type) {
		/* all the templates depend on the same order of replacement values */
		List<String> replacementList = new List<String>{
			(orgId != null ? orgId : ''), 
			(orgStatus != null ? orgStatus : ''), 
			(resourceName != null ? resourceName : ''), 
			(resourceCount != null ? String.valueOf(resourceCount) : '0') };
			
		if (version == 30 && type.equalsIgnoreCase(VALID_TYPE_VF)) {
			return String.format(LINE_TEMPATE_VF_V30, replacementList);
		}
		else if (version > 30 && type.equalsIgnoreCase(VALID_TYPE_VF)) {
			return String.format(LINE_TEMPATE_VF_V31, replacementList);
		}
		else if (version == 30 && type.equalsIgnoreCase(VALID_TYPE_CO)) {
			return String.format(LINE_TEMPATE_CO_V30, replacementList);
		}
		else if (version > 30 && type.equalsIgnoreCase(VALID_TYPE_CO)) {
			return String.format(LINE_TEMPATE_CO_V31, replacementList);
		}
		
		/* catch all - will never happen with valid data */
		System.debug('invalid data provided to build line, unable to build line: version=' + version + 'type=' + type);
		return null;
	}
	
	/**
	 * Gets a DateTime object representing "now"
	 */
	public static datetime getDateTimeTrunc(){
       DateTime dt = DateTime.now();
       DateTime myDate =  DateTime.newInstanceGMT(dt.yearGMT(), dt.monthGMT(), dt.dayGMT(),0,0,0);
       
       return myDate;
    }
    
    /**
     * This is a complicated work around to the fact that the MetricsDataFile object is not DML enabled.
     * This is an impl of the MDFQueryDAO which has an internal storage mechanism.
     */
    public class MDFTestObjectDAO implements MDFQueryDAO {
    	/* MetricsType -> SendingInstance -> NamespacePrefix -> MetricsStartDate -> MetricsDataFile */
		private Map<String, Map<String, Map<String, Map<DateTime, MetricsDataFile>>>> theStore;
    	
    	private MDFTestObjectDAO() {
    		this.theStore = new Map<String, Map<String, Map<String, Map<DateTime, MetricsDataFile>>>>();
    	}
    	
		public List<MetricsDataFile> findMDFs(String sendingInstanceId, DateTime lookbackStartDate) {
			List<MetricsDataFile> mdfs = new List<MetricsDataFile>();
			
			for (Map<String, Map<String, Map<DateTime, MetricsDataFile>>> m : theStore.values()) {
				Map<String, Map<DateTime, MetricsDataFile>> mdfBySendingInstance = m.get(sendingInstanceId);
				if (mdfBySendingInstance != null) {
					System.debug('found data by sendingInstanceId=' + sendingInstanceId);
					
					for (Map<DateTime, MetricsDataFile> m2 : mdfBySendingInstance.values()) {
						for (DateTime d : m2.keySet()) {
							System.debug('comparing startdate=' + d + ' to lookback=' + lookbackStartDate);
							if (d >= lookbackStartDate) {
								System.debug('we found a good mdf');
								mdfs.add(m2.get(d));
							}
							else {
								System.debug('no good');
							}
						}						
					}
				}
			}
			
			return mdfs;
		}
	
		public List<MetricsDataFile> findMDFs(String metricsType, String namespacePrefix, Date lookbackStartDate) {
			List<MetricsDataFile> mdfs = new List<MetricsDataFile>();
			
			Map<String, Map<String, Map<DateTime, MetricsDataFile>>> dataByMetricsType = theStore.get(metricsType);
			if (dataByMetricsType != null) {
				System.debug('found data by metricstype=' + metricsType);
				for (Map<String, Map<DateTime, MetricsDataFile>> dataBySendingInstance : dataByMetricsType.values()) {
					Map<DateTime, MetricsDataFile> dataByNamespacePrefix = dataBySendingInstance.get(namespacePrefix);
					if (dataByNamespacePrefix != null) {
						System.debug('found data by namespaceprefix=' + namespacePrefix);
						for (DateTime d : dataByNamespacePrefix.keySet()) {
							System.debug('comparing startdate=' + d + ' to lookback=' + lookbackStartDate);
							if (d >= lookbackStartDate) {
								System.debug('we found a good mdf');
								mdfs.add(dataByNamespacePrefix.get(d));
							}
							else {
								System.debug('no good');
							}
						}
					}
										
				}
			}
			
			return mdfs;
		}
		
		public Set<String> findNamespaces() {
			Set<String> namespaces = new Set<String>();
			for (Map<String, Map<String, Map<DateTime, MetricsDataFile>>> m : theStore.values()) {
				for (Map<String, Map<DateTime, MetricsDataFile>> m2 : m.values()) {
					namespaces.addAll(m2.keySet());
				}
			}
			
			return namespaces;
		}

		private void save(MetricsDataFile mdf) {
			if (theStore.containsKey(mdf.MetricsType)) {
				if (theStore.get(mdf.MetricsType).containsKey(mdf.SendingInstance)) {
					if (theStore.get(mdf.MetricsType).containsKey(mdf.NamespacePrefix)) {
						theStore.get(mdf.MetricsType).get(mdf.SendingInstance).get(mdf.NamespacePrefix).put(mdf.MetricsStartDate, mdf);
					}
					else {
						theStore.get(mdf.MetricsType).get(mdf.SendingInstance).put(mdf.NamespacePrefix, new Map<DateTime, MetricsDataFile>{mdf.MetricsStartDate => mdf});
					}
				}
				else {
					theStore.get(mdf.MetricsType).put(mdf.SendingInstance, new Map<String, Map<DateTime, MetricsDataFile>>{mdf.NamespacePrefix => new Map<DateTime, MetricsDataFile>{mdf.MetricsStartDate => mdf}});
				}
			}
			else {
				theStore.put(mdf.MetricsType, new Map<String, Map<String, Map<DateTime, MetricsDataFile>>>{mdf.SendingInstance => new Map<String, Map<DateTime, MetricsDataFile>>{mdf.NamespacePrefix => new Map<DateTime, MetricsDataFile>{mdf.MetricsStartDate => mdf}}});
			}
		}
    }
}