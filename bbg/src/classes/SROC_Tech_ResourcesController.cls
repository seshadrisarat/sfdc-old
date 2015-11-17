public without sharing class SROC_Tech_ResourcesController {
    
    public String selectedCategory {get;set;}
    public String selectedFaqCategory {get;set;}
    public String currArticleId {get;set;}
    public String keywordSearch {get;set;}
    public String selectedArticleType {get;set;}
    public String filterBy {get;set;}
    
    public List<SelectOption> yearCatList {get;set;}
    public List<SelectOption> boatCatList {get;set;}
    public List<SelectOption> chatterCatList {get;set;}
    public Boolean hasResults {get;set;}
    //public List<SelectOption> modelCatList {get;set;}
    
    public Boolean isOwner {get;private set;}
    
    public SROC_Tech_ResourcesController() {
        
        this.selectedCategory = 'All';
        this.selectedFaqCategory = 'All';
        this.selectedArticleType = 'Owners_Manual__kav,Parts_Manual__kav,Component_Manual__kav,Engine_Drive_and_Prop_Matrix__kav,Full_Brochure__kav,General_Information_Manual__kav,Prop_Chart__kav,Specification_Sheet__kav';
        this.filterBy = 'Year';
        this.keywordSearch = '';
        this.SpecifiedPageNumber = 1;
        this.isOwner = SROCUtilities.isOwner();
        yesResults();
        
        buildCategoryLists();
        buildChatterCategoryList();
        //buildModelCategoryList();
        
        
    }

    public PageReference forwardToLogin(){
        return CORECONNECT.CC_CommunityUtil.forwardToLogin();
    }
    
    public String getZoneId() {
        SROC_System_Settings__c setting = SROC_System_Settings__c.getInstance(Site.GetName());
        if(setting != null)
        {
            return setting.Chatter_Answers_Zone_Id__c;
        }
        else {return '';}
    }
    
    public void selectCategory() {
        System.debug('selectedCategory: ' + this.selectedCategory);
        System.debug('selectedArticleType: ' + this.selectedArticleType);
        System.debug('filterBy: ' + this.filterBy);
        System.debug('keywordSearch: ' + this.keywordSearch);
    }
    
    public PageReference doFilter() {

    	this.SpecifiedPageNumber = 1;
    	yesResults();
    	return null;
    }
    
    public PageReference doFaqFilter() {
    	return null;
    }
    
    public void resetFilter()
    {
    	this.selectedCategory = 'All';
        this.selectedArticleType = 'Owners_Manual__kav,Parts_Manual__kav,Component_Manual__kav';
        this.filterBy = 'Year';
        this.SpecifiedPageNumber = 1;
        yesResults();
        
    }
    
    public void selectFilterBy() {
    	//used on page	
    }
    
    public void noResults() {
    	this.hasResults = false;
    }
    
    public void yesResults() {
    	this.hasResults = true;
    }
    
    private void buildCategoryLists() {
    	this.yearCatList = new List<SelectOption>();
    	this.boatCatList = new List<SelectOption>();
    	List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
    	
    	DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
    	pair1.setSobject('KnowledgeArticleVersion');
		pair1.setDataCategoryGroupName('Support_Documentation');
    	
    	pairs.add(pair1);
    	
    	List<Schema.DataCategory> topCats = Schema.describeDataCategoryGroupStructures(pairs, false)[0].getTopCategories();
    	System.debug('topCats: ' + topCats);
    	List<Schema.DataCategory> topSubCats = topCats[0].getChildCategories();
    	System.debug('topSubCats: ' + topSubCats);
    	
    	for(Schema.DataCategory result : topSubCats)
    	{
    		System.debug('topCatResult: '+result);
    		
    		if(result.getName() == 'Year')
    		{
    			for(Schema.DataCategory subresult : result.getChildCategories())
    			{
    				this.yearCatList.add(new SelectOption(subresult.getName(), subresult.getLabel()));
    			}
    		}
    		else if(result.getName() == 'Boat_Category')
    		{
    			for(Schema.DataCategory subresult : result.getChildCategories())
    			{
    				this.boatCatList.add(new SelectOption(subresult.getName(), subresult.getLabel()));
    			}
    		}
    			
    	}
    	
    }
    
    /*
    private void buildModelCategoryList() {
    	this.modelCatList = new List<SelectOption>();
    	List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
    	
    	DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
    	pair1.setSobject('KnowledgeArticleVersion');
		pair1.setDataCategoryGroupName('Support_Documentation_Models');
    	
    	pairs.add(pair1);
    	
    	List<Schema.DataCategory> topCats = Schema.describeDataCategoryGroupStructures(pairs, false)[0].getTopCategories();
    	System.debug('topCats: ' + topCats);
    	//List<Schema.DataCategory> topSubCats = topCats[0].getChildCategories();
    	//System.debug('topSubCats: ' + topSubCats);
    	
    	for(Schema.DataCategory result : topCats)
    	{
    		System.debug('topCatResult: '+result);
    		
    		for(Schema.DataCategory subresult : result.getChildCategories())
    		{
    			this.modelCatList.add(new SelectOption(subresult.getName(), subresult.getLabel()));
    		}
    			
    	}
    	
    }
    */
    
    private void buildChatterCategoryList() {
    	this.chatterCatList = new List<SelectOption>();
    	List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
    	
    	DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
    	pair1.setSobject('KnowledgeArticleVersion');
		pair1.setDataCategoryGroupName('SROC_Chatter_Answers');
    	
    	pairs.add(pair1);
    	
    	List<Schema.DataCategory> topCats = Schema.describeDataCategoryGroupStructures(pairs, false)[0].getTopCategories();
    	System.debug('topCats: ' + topCats);
    	//List<Schema.DataCategory> topSubCats = topCats[0].getChildCategories();
    	//System.debug('topSubCats: ' + topSubCats);
    	
    	for(Schema.DataCategory result : topCats)
    	{
    		System.debug('topCatResult: '+result);
    		
    		for(Schema.DataCategory subresult : result.getChildCategories())
    		{
    			this.chatterCatList.add(new SelectOption(subresult.getName(), subresult.getLabel()));
    		}
    			
    	}
    	
    }
    
    public List<selectOption> getCategoryList() {
    	
    	List<SelectOption> slList = new List<SelectOption>();
    	slList.add(new SelectOption('All', 'All'));
    	System.debug('yearCarList: ' + this.yearCatList);
    	System.debug('boatCatList: ' + this.boatCatList);
    	
    	if(this.filterBy == 'Year')
    	{	
	    	slList.addAll(this.yearCatList);
    	}
    	else if(this.filterBy == 'Boat_Category')
    	{
    		slList.addAll(this.boatCatList);
    	}
    	/*else if(this.filterBy == 'Model')
    	{
    		slList.addAll(this.modelCatList);
    	}*/
    	
    	System.debug('slList: ' + slList);
    	
    	return slList;
    	
    }
    
    public List<selectOption> getChatterCategoryList() {
    	
    	List<SelectOption> slList = new List<SelectOption>();
    	slList.add(new SelectOption('All', 'All'));
    	System.debug('chatterCatList: ' + this.chatterCatList);
    		
	    slList.addAll(this.chatterCatList);
    	
    	
    	System.debug('slChatterList: ' + slList);
    	
    	return slList;
    	
    }
    
    /**
        Methods for pagenation
    */
 
    public Boolean hasNextSet {
        get {
            return true;
        }
        set;
    }
 	
    public Boolean hasPrevSet {
        get {
            if(PageNumber > 1)
            {
            	return true;
            }
            else
            {
            	return false;
            }
        }
        set;
    }
 
    public Integer PageNumber {
        get {
            return SpecifiedPageNumber;
        }
        set;
    }

    public  Integer SpecifiedPageNumber{
        get;
        set;
    } 

    public void prevSet() {
            if(SpecifiedPageNumber > 1)
            {
            	SpecifiedPageNumber--;
            }
    }
 
 
    public void nextSet() {
            SpecifiedPageNumber++;     
    }
 
    public void GoToPage () {
        
   }
   
    

}