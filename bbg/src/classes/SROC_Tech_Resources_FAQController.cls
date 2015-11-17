public with sharing class SROC_Tech_Resources_FAQController {
	
	public Integer numOfResults {get;set;}
	
	public String faqCategory {get;set;}
	
	public Boolean showCategories {get;set;}

	public String searchKey 	{get;set;}
	
	private List<SelectOption> chatterCatList;
	
	
	public SROC_Tech_Resources_FAQController() {
		searchKey = '';
		buildChatterCategoryList();
	}
	
	
	public String selectedFaqCategory { 
			get{
				
				
				if(selectedFaqCategory != null && selectedFaqCategory.trim() != '')
				{
					return selectedFaqCategory;
				}
				else if(this.faqCategory != null && this.faqCategory != '')
				{
					return this.faqCategory;
				}
				else
				{
					return 'All';
				}
				
			} 
			set;
		} 
		
	
	
	public Boolean selectedShowCategories {
		get{
			if(this.showCategories == null)
			{
				return true;
			}
			else
			{
				return this.showCategories;
			}
		}
	}
	
	public Integer selectedNumOfResults {
		get{
			if(this.numOfResults == null)
			{
				return 5;
			}
			else
			{
				return this.numOfResults;
			}
		}
	}
	
	public List<selectOption> chatterCategoryList {
    	get{
    		List<SelectOption> slList = new List<SelectOption>();
    		slList.add(new SelectOption('All', 'All'));
    		System.debug('chatterCatList: ' + this.chatterCatList);
    		
	    	slList.addAll(this.chatterCatList);
    	
    	
    		System.debug('slChatterList: ' + slList);
    	
    		return slList;
    	}
    }
    
    public PageReference doFaqFilter() {
    	return null;
    }
    
    private void buildChatterCategoryList() {
    	this.chatterCatList = new List<SelectOption>();
    	List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
    	
    	DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
    	pair1.setSobject('KnowledgeArticleVersion');
		pair1.setDataCategoryGroupName('SROC_Chatter_Answers');
    	
    	pairs.add(pair1);
    	
    	List<Schema.DataCategory> topCats = Schema.describeDataCategoryGroupStructures(pairs, false)[0].getTopCategories();
    	System.debug('topCats: ' + topCats);
    	
    	for(Schema.DataCategory result : topCats)
    	{
    		System.debug('topCatResult: '+result);
    		
    		for(Schema.DataCategory subresult : result.getChildCategories())
    		{
    			this.chatterCatList.add(new SelectOption(subresult.getName(), subresult.getLabel()));
    		}
    			
    	}
    	
    }
	
}