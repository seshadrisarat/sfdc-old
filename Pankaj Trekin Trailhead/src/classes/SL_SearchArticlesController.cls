/**
* \arg ClassName      : SL_SearchArticlesController
* \arg JIRATicket     : TT-141
* \arg CreatedOn      : 27/MAY/2015
* \arg LastModifiedOn : 28/MAY/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to display the articles on the basis of search parameters passed from the page.
*/
public without sharing class SL_SearchArticlesController 
{
	/* Start - Variables */	
	public String strSearchString				{get;set;}// variable to store the value of search keyword typed by user on UI corresponding to which the user wants to find the articles
	public String strSelectArticleType			{get;set;}// variable to store the value of selected article type from UI.
	public String strSelectedDataCategory 		{get;set;}// variable to store the value of selected data category from UI.
	public List<KnowledgeArticleVersion> lstKAV {get;set;}// variable to store the searching results.
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_SearchArticlesController()
	{
		initialize();
		lstKAV = new List<KnowledgeArticleVersion>();
	}
	/* End - Constructor */
	
	private void initialize()
	{
		strSearchString = strSelectArticleType = strSelectedDataCategory = '';
	}
	
	public List<SelectOption> getArticleTypes()
	{
		Map<String, Schema.SObjectType> getObjects = Schema.getGlobalDescribe();
		List<SelectOption> lstSelectOption = new List<SelectOption>{new SelectOption('','None')};
		for(String strKeySet : getObjects.keyset())
		{
			if(strKeySet.endsWith('kav'))
			{
				Schema.Sobjecttype objSobjectType = getObjects.get(strKeySet);
				lstSelectOption.add(new SelectOption(objSobjectType.getDescribe().getName(), objSobjectType.getDescribe().getLabel()));
			}
		}
		return lstSelectOption;
	}
	
	public List<SelectOption> getDataCategory()
	{
		List<SelectOption> lstSelectOption = new List<SelectOption>{new SelectOption('','None')};
		
		for(DescribeDataCategoryGroupResult objDCResult : Schema.describeDataCategoryGroups(new List<String>{'KnowledgeArticleVersion'}))
		{
			lstSelectOption.add(new SelectOption(objDCResult.getName()+'__c', objDCResult.getLabel()));
		}
		
		return lstSelectOption;
	}
	
	public void searchArticles()
	{
		lstKAV.clear();
		if(String.isNotEmpty(strSearchString) || String.isNotEmpty(strSelectArticleType) || String.isNotEmpty(strSelectedDataCategory))
		{
			String strQuery = 'SELECT Id, ArticleType, Summary, Title FROM KnowledgeArticleVersion WHERE PublishStatus = \'Online\' AND language = \'en_US\'';
			if(String.isNotEmpty(strSearchString))
			{
				strQuery+=' AND Title LIKE '+'\''+'%'+strSearchString.trim()+'%'+'\'';
			}
			
			if(String.isNotEmpty(strSelectArticleType))
			{
				strQuery+=' AND ArticleType ='+'\''+strSelectArticleType+'\'';
			}
			
			if(String.isNotEmpty(strSelectedDataCategory))
			{
				strQuery+=' WITH DATA CATEGORY '+strSelectedDataCategory+' ABOVE_OR_BELOW ALL__c';
			}
			strSearchString = strSelectArticleType = strSelectedDataCategory = '';
			lstKAV = Database.query(strQuery);
		}
	}
	
	@RemoteAction
	public static List<String> getMatchedArticles(String strSearchString)
	{
		List<String> lstMatchedArticles = new List<String>();
		
		for(KnowledgeArticleVersion objKAV : [SELECT Title FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND language = 'en_US' AND Title LIKE :'%'+strSearchString+'%'])
		{
			lstMatchedArticles.add(objKAV.Title);
		}
		return lstMatchedArticles;
	}
}