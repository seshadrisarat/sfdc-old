public with sharing class CommunityDebuggerCtrl {
	public String failingPageResponse { get; set; }

	String toLoad {get; private set;}
	Map<String, String> params {get; private set;}
	String queryString = '?';

	public CommunityDebuggerCtrl() {
		params = ApexPages.currentPage().getParameters();
		toLoad = (String) params.get('page');
		params.remove('page');

		system.debug('params' + params);

		boolean first = true;
		for (String key : params.keyset()) {
			if(first){
				queryString = queryString + key + '=' + params.get(key);
				first = false;
			}
			else
				queryString = queryString + '&' + key + '=' + params.get(key);
		}
	}

	public void fetchFailingPage() {
		try {
			system.debug('Loading this url: ' + toLoad +  queryString);
			PageReference fail = new PageReference('/' + toLoad + queryString);
			failingPageResponse = fail.getContent().toString();
		} catch (Exception e) {
			failingPageResponse = e.getTypeName() + ' : ' + e.getMessage() + ' : ' + e.getStackTraceString();
		}
	}
}