public class BitbucketRefresh {
	public string projectName	{get;set;}
	public BitbucketRefresh() {
		projectName = ApexPages.currentPage().getParameters().get('project');
	}

	public void refresh() {
		if (projectName!=null) {
			projectName = projectName.toLowerCase();
			Database.executeBatch(new BitbucketBatch(projectName, null));
		}
	}
}