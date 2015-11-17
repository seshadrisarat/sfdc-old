/**
* \arg ClassName       : SL_ProposalBuilder_SelectTemplateCont
* \arg JIRATicket      : SLPSA-17
* \arg CreatedOn       :  Shailendra, 21/August/2013 
* \arg ModifiedBy      : Praful, 15/October/2013 
* \arg Description     : 
*/

global with sharing class SL_ProposalBuilder_SelectTemplateCont
{
	/* Start of public variables */  
    public String strjson 											{get;set;}      // To maintain the content which will be used to display in tree format.
    public List<Opps_Template__c> lstOppTemplates                   {get;set;}      // To store all OppTemplate records which would be used to display those records in left portion of SL_ProposalBuilder_SelectTemplate page.
    public String strSelectedOppTemplateId							{get;set;}		// To maintain the OppTemplate Id which is selected by user in page.
    public String selectedOpportunityComponentIds					{get;set;}		// To store the CSV format Ids of all the opportunity components which are selected from page
    public String selectedOpportunityComponentFeatureIds			{get;set;}		// To store the CSV format Ids of all the opportunity component features which are selected from page
    public String selectedOpportunityComponentDetailIds				{get;set;}		// To store the CSV format Ids of all the opportunity component detail which are selected from page
    public String strOpportunityId									{get;set;}		// To store the Id of Opportunity record from where this page has been launched			
    
    
    /*
    	Name: TreeNode
    	Description: Inner class to create a hierarchical tree nodes and binding their attributes
    */
    
    public class TreeNode
    {
    	public String text;					//Holds the Node Text	
    	public String cls;					//For applying the class such as Folder/leaf
    	public Boolean expanded;			//To decide if Node will render in expanded mode or collapsed
    	public Boolean checked;				//To decide if Node will render as checked/unchekced
    	public Boolean leaf;				//To decide if Node is child or parent of other nodes
    	public String id;					//To store the id of the node
    	public List<TreeNode> children;		//To store all the childs of Node
    	
    	/* Constructor */
    	
    	public TreeNode(String text, String cls, Boolean expanded, Boolean checked, Boolean leaf, String recordId)
    	{
    		this.text = text;
    		this.cls = cls;
    		this.expanded = expanded;
    		this.checked = checked;
    		this.leaf = leaf;
    		this.id = recordId;
    	}
    }
    
    /* Constructor */
    
    public SL_ProposalBuilder_SelectTemplateCont(Apexpages.standardcontroller stdController)
    {
    	
    	//To initialize all the required variables and query all the Existing Opportunity templates
    	initialize(); 
    	
    	strOpportunityId = stdController.getId(); 
    	
		// Praful updated this
		// Setting selected template onload 
		if(lstOppTemplates != Null && !lstOppTemplates.isEmpty()) 
		strSelectedOppTemplateId = lstOppTemplates[0].Id;

	}
    
    /**
     * Name: initialize
     * Parameters: NA
     * Method used to initialize global variables of class and called from constructor. 
    */
    
    public void initialize()
    {
    	strjson = '';
    	selectedOpportunityComponentIds = '';
    	selectedOpportunityComponentFeatureIds = '';
    	selectedOpportunityComponentDetailIds = '';
    	lstOppTemplates = new List<Opps_Template__c>();
    	
    	//Querying all OppTemplate records to display in SL_ProposalBuilder_SelectTemplate page.
        lstOppTemplates = [ SELECT Name, Id, Description__c
                            FROM Opps_Template__c];
    }
    
    
    /**
     * Name: getTreeHeirarchy
     * Parameters: Id of the selected Opportunity template
     * Description: To create the heirarchical tree structure based on selected Opportunity Template Id 
    */
    
    @remoteAction
    public static List<TreeNode> getTreeHeirarchy(String strSelectedOppTemplateId)
    {
    	System.debug('%%%%%%%%%%strSelectedOppTemplateId%%%%%%%%%% : '+strSelectedOppTemplateId);
    	//Splitting and getting template id from string
    	strSelectedOppTemplateId = strSelectedOppTemplateId.substring(strSelectedOppTemplateId.indexOf('strSelectedOppTemplateId') + 25,strSelectedOppTemplateId.length()-1);
    	System.debug('%%%%%%%%%%strSelectedOppTemplateId%%%%%%%%%% : '+strSelectedOppTemplateId);
    	try
    	{
	    	
	    	//To containa all the Opportunity Template Components which are related to selected Opportunity template record
	    	List<Opps_Template_Component__c> lstOpportunityTemplateComponents = new List<Opps_Template_Component__c>();
	    	
	    	//Defining map between parent and child records for creating the Hierarchy structure 
	    	Map<Id, List<Opps_Template_Component_Feature__c>> mapOTCId_lstOTCF = new map<Id, List<Opps_Template_Component_Feature__c>>();
	    	Map<Id, List<Opps_Template_Component_Detail__c>> mapOTCFId_lstOTCD = new map<Id, List<Opps_Template_Component_Detail__c>>();
	    	
	    	
	    	//Query all the Opportunity template component related to Selected template
	    	lstOpportunityTemplateComponents = [SELECT Id, Name 
	    										FROM Opps_Template_Component__c
	    										WHERE Template__c = :strSelectedOppTemplateId];
	    	
	    	//If not empty then procees further to Query the child records to display into Tree hierarchy
	    	if(!lstOpportunityTemplateComponents.isEmpty())
	    	{
				//Query child Opps Template Component Features and Opps Template Component Detail records to form a Tree Node
				for(Opps_Template_Component_Feature__c obj : [SELECT Id, Name, Opps_Template_Component__c, SOW_Description_Default__c, Component_Detail_Sort_Order__c,
																	 (SELECT Id, Name FROM Opps_Template_Component_Detail__r)
														      FROM Opps_Template_Component_Feature__c
														      WHERE Opps_Template_Component__c in :lstOpportunityTemplateComponents])
				{
					// Adding entries into map for 1st level heirarchy				
					if(mapOTCId_lstOTCF.containsKey(obj.Opps_Template_Component__c))
						mapOTCId_lstOTCF.get(obj.Opps_Template_Component__c).add(obj);
					else
						mapOTCId_lstOTCF.put(obj.Opps_Template_Component__c, new list<Opps_Template_Component_Feature__c>{obj});
						
					// Adding entries into map for second level hierarchy
					mapOTCFId_lstOTCD.put(obj.Id, new List<Opps_Template_Component_Detail__c>());
					mapOTCFId_lstOTCD.get(obj.Id).addAll(obj.Opps_Template_Component_Detail__r);		
					
				}
				
				//To store the final list of Tree nodes as opportunity components will be the root level 
				List<TreeNode> lstComponentNodes = new List<TreeNode>();
				
				//Iterate through the Map and create a Tree node object in hierarchical manner 
				for(Opps_Template_Component__c objOTC :lstOpportunityTemplateComponents)
				{
					TreeNode objComponentNode;
					//If the map contains the key i.e. this Template must have child Opportunity template component feature
					if(mapOTCId_lstOTCF.containsKey(objOTC.Id))
					{
						 // Level1
						objComponentNode = new TreeNode(objOTC.Name, 'folder', true, true, false, objOTC.Id);  
						
						//List to hold the child Feature nodes
						List<TreeNode> lstFeatureNodes = new List<TreeNode>();
						
						//Iterate through child Opportunity component feature records to create a second level hierarchy
						for(Opps_Template_Component_Feature__c objOTCF :mapOTCId_lstOTCF.get(objOTC.Id))
						{
							TreeNode objFeatureNode;
							
							// Level2, Div element have been introduced to create a line break between Feature name and its Description anf for proper alignment
							//objFeatureNode = new TreeNode(objOTCF.Name + '<div class="test1">' + objOTCF.SOW_Description_Default__c + '</div>', 'folder', false, true, false, objOTCF.Id);   
							objFeatureNode = new TreeNode(objOTCF.Name, 'folder', false, true, false, objOTCF.Id);   

							//List to hold the child Deatil nodes
							List<TreeNode> lstDetailNodes = new List<TreeNode>();
							
							//Iterate through child Opportunity component Detail records to create a third level hierarchy
							for(Opps_Template_Component_Detail__c objOTCD :mapOTCFId_lstOTCD.get(objOTCF.Id))
							{
								//  Level3
								lstDetailNodes.add(new TreeNode(objOTCD.Name, '', false, true, true, objOTCD.Id));   
							}
							
							//Adding all the child detail nodes into Feature node
							objFeatureNode.children = lstDetailNodes;
							
							lstFeatureNodes.add(objFeatureNode);	
						}
						
						//Adding child feature node into Component node
						objComponentNode.children = lstFeatureNodes;	
					}	
					else
					{
						//To create a blank Component node
						objComponentNode = new TreeNode(objOTC.Name, 'folder', true, true, false, objOTC.Id); //Level1
						objComponentNode.children = new List<TreeNode>{};
					}
					
					lstComponentNodes.add(objComponentNode);						
				}			
				
				return lstComponentNodes;
				
	    	}
	    	
	    	return null;
    	}
    	catch(Exception e)
    	{
    		return null;
    	}	
    	
    }
    
    /**
     * Name: getExistingOpportunityComponent
     * Parameters: NA
     * Description: To query the existing Opportunity component for the Opportunity in context and create a set which contains unique key  identifier for the 
     				opportunity component and will be used to avoid duplication
    */
 
      private set<String> getExistingOpportunityComponent()
    {	
  		Set<String> setComponent_Feature_Detail = new set<String>();
    	
    	//Query existing Opportunity component Details record and iterate through it to push the unique identifier into set
    	for(Opportunity_Component_Detail__c objOCD :[SELECT Id, Opps_Template_Component_Detail_Id__c 
    										 		FROM Opportunity_Component_Detail__c 
    										 		WHERE Opportunity_Component_Feature__r.Opportunity_Component__r.Opportunity__c = :strOpportunityId])
    	{
    		//setComponent_Feature_Detail.add(string.valueOf(objOCD.Opps_Template_Component_Detail_Id__c));
			setComponent_Feature_Detail.add(objOCD.Opps_Template_Component_Detail_Id__c);
		}
											 		
   		//Query existing Opportunity component Feature record and iterate through it to push the unique identifier into set
   		for(Opportunity_Component_Feature__c  objOCF :[SELECT Id, Opps_Template_Component_Feature_Id__c, Sow_Group__c, Product__c
   														FROM Opportunity_Component_Feature__c
   														WHERE Opportunity_Component__r.Opportunity__c = :strOpportunityId])
   		{
			setComponent_Feature_Detail.add(objOCF.Opps_Template_Component_Feature_Id__c);
		}
		
   		//Query existing Opportunity component record and iterate through it to push the unique identifier into set
   		for(Opportunity_Component__c  objOC :[SELECT Id, Opps_Template_Component__c
   												FROM Opportunity_Component__c
   												WHERE Opportunity__c = :strOpportunityId])
   																								
		{
			setComponent_Feature_Detail.add(objOC.Opps_Template_Component__c);
		}
		
		return 	setComponent_Feature_Detail;								 
    } 
    
    /**
     * Name: createOpportunityComponent
     * Parameters: NA
     * Description: To create Opportunity component records based on User selection made on the main page
    */
    
     public pageReference createOpportunityComponent()
    {
	    	Set<String> setComponent_Feature_DeatilForExistingOppComponent = getExistingOpportunityComponent();
	    	
	    	//Set to holds the Ids of all the selected tree nodes(records) to query respetive records
	    	Set<String> setSelectedOpportunityComponentDetailsId = new set<String>();
	    	Set<String> setselectedOpportunityComponentFeatureId = new set<String>();
	    	Set<String> setselectedOpportunityComponentIds = new set<String>();
	    	
	    	//Map of Opps Template Component Id and Opportunity Component Id.
	    	map<Id, Id> mapTemplateComp_OppComp = new map<Id, Id>();
	    		    	
	    	//Map of Opps Template Component Feature Id and Opportunity Component Feature Id.
	    	map<Id, Id> mapTemplateFeature_OppFeature = new map<Id, Id>();
	    	
	    	//To store the Opportunity components records which are going to be created 
	    	List<Opportunity_Component__c> lstOpportunityComponentsNeedToBeCreated = new List<Opportunity_Component__c>();
	    	
	    	//To store the Opportunity component Features records which are going to be created 
	    	List<Opportunity_Component_Feature__c> lstOpportunityComponentFeaturesNeedToBeCreated = new List<Opportunity_Component_Feature__c>();
	    	
	    	//To store the Opportunity component Details records which are going to be created 
	    	List<Opportunity_Component_Detail__c> lstOpportunityComponentDetailsNeedToBeCreated = new List<Opportunity_Component_Detail__c>();
	    	
	    	//Taking all the Selected Opportunity ComponentDetail records Id into list to Query and get the details
	    	setSelectedOpportunityComponentDetailsId.addAll(selectedOpportunityComponentDetailIds.split(','));
	    	
	    	//Taking all the Selected Opportunity ComponentFeature records Id into list to Query and get the details
	    	setselectedOpportunityComponentFeatureId.addAll(selectedOpportunityComponentFeatureIds.split(','));
	    	
	    	//Taking all the Selected Opportunity Component records Id into list to Query and get the details
	    	setselectedOpportunityComponentIds.addAll(selectedOpportunityComponentIds.split(','));
	    	
	    	Integer i = 0;
	    	Map<Id,Integer> mapTemplate_SortOrder = new Map<Id,Integer>();
	    	//Querying all the Opps Component which all are selected by users from Tree hierarchy and creating the Opportunity component records
	    	For(Opps_Template_Component__c objOTC :[Select Template__r.Name, Template__c, Name, Id, Product__c
	    											From Opps_Template_Component__c
	    											where Id in: setselectedOpportunityComponentIds])
	    	{
	    		if(!setComponent_Feature_DeatilForExistingOppComponent.contains(objOTC.Id))
	    		{
	    			//Adding object's to the List of Opportunity components
		    		lstOpportunityComponentsNeedToBeCreated.add(new Opportunity_Component__c(Opps_Template_Component__c = objOTC.Id,
		    																				 Opportunity__c = strOpportunityId,
		    																				 Description__c = objOTC.Name,
		    																				 JFRSNSort__c = i
		    																				 //Product__c = objOTC.Product__c
		    																				 /*  																				/* Sort_Order__c = objOTC.Component_Detail_Sort_Order__c,
		    																				 Limit_Dependency__c =  objOTC.Limit_Dependency__c,
		    																				 Limit__c = objOTC.Limit__c,
		    																				 Pricing_Description__c = objOTC.Pricing_Description_Default__c,
		    																				 
		    																				 SOW_Description__c = objOTC.SOW_Description_Default__c */
		    																				 ));
		    		mapTemplate_SortOrder.put(objOTC.Id, i);
		    		i++;
	    		}
	    	}
	    	
	    	//Inserting OpportunityComponents records into database
	    	if(!lstOpportunityComponentsNeedToBeCreated.isEmpty())
	    		insert(lstOpportunityComponentsNeedToBeCreated);
	    	
	    	for(Opportunity_Component__c objOC : lstOpportunityComponentsNeedToBeCreated)
			{ 
			     mapTemplateComp_OppComp.put(objOC.Opps_Template_Component__c, objOC.Id);
			}
	    	
	    	i = 0;
	    	//Querying all the Component Feature which all are selected by users from Tree hierarchy and creating the Opportunity component Feature records
	    	For(Opps_Template_Component_Feature__c objOTCF :[Select Id, Name, SOW_Description_Default__c, Opps_Template_Component__c, Component_Detail_Sort_Order__c, Sow_Group__c, Product__c
	    													 From Opps_Template_Component_Feature__c
	    													 where Id in: setselectedOpportunityComponentFeatureId])
	    	{
	    		if(!setComponent_Feature_DeatilForExistingOppComponent.contains(objOTCF.Id))
	    		{
	    			//Adding object's to the List of Opportunity component Features
	    			lstOpportunityComponentFeaturesNeedToBeCreated.add(new Opportunity_Component_Feature__c(Opps_Template_Component_Feature_Id__c = objOTCF.Id,
	    																									Component_Detail_Sort_Order__c = objOTCF.Component_Detail_Sort_Order__c,
	    																									SOW_Description__c = objOTCF.SOW_Description_Default__c,
	    																									Sow_Group__c = objOTCF.SOW_Group__c,
	    																									Product__c = objOTCF.Product__c,
	    																									Opportunity_Component__c = mapTemplateComp_OppComp.get(objOTCF.Opps_Template_Component__c),
	    																									JFRSNSortKey__c = mapTemplate_SortOrder.get(objOTCF.Opps_Template_Component__c) + '-' + i,
	    																									Description__c = objOTCF.Name));
	    			i++;
	    		}
	    	}
	    	
	    	//Inserting OpportunityComponentFeatures records into database
	    	if(!lstOpportunityComponentFeaturesNeedToBeCreated.isEmpty())
	    		insert(lstOpportunityComponentFeaturesNeedToBeCreated);
	    		
	    	for(Opportunity_Component_Feature__c objOCF : lstOpportunityComponentFeaturesNeedToBeCreated)
	    	{
	    		mapTemplateFeature_OppFeature.put(objOCF.Opps_Template_Component_Feature_Id__c, objOCF.Id);
	    	}	
	    	
	    	//Querying all the Component detail which all are selected by users from Tree hierarchy and creating the Opportunity component Detail records
	    	For(Opps_Template_Component_Detail__c objOTCD :[Select Id, Name, Opps_Template_Component_Feature__c From Opps_Template_Component_Detail__c 
	    													where Id in: setSelectedOpportunityComponentDetailsId])
	    	{
	    		if(!setComponent_Feature_DeatilForExistingOppComponent.contains(objOTCD.Id))
	    		{
	    			//Adding object's to the List of Opportunity component Details																						
	    			lstOpportunityComponentDetailsNeedToBeCreated.add(new Opportunity_Component_Detail__c(Opps_Template_Component_Detail_Id__c = objOTCD.Id,
	    																								  Description__c = objOTCD.Name,
	    																								  Opportunity_Component_Feature__c = mapTemplateFeature_OppFeature.get(objOTCD.Opps_Template_Component_Feature__c)));
	    		}																					 
	    		
	    	}
	    	
	    	//Inserting OpportunityComponentDetails records into database
	    	if(!lstOpportunityComponentDetailsNeedToBeCreated.isEmpty())
	    		insert(lstOpportunityComponentDetailsNeedToBeCreated);
	    			
	    	return new Pagereference('/apex/jfrsn?oppty=' + strOpportunityId);
	    	   		
    }
    
    /**
     * Name: redirectionControl
     * Parameters: NA
     * Description: Method used to decide if we need to redirect on Main page or stay on the Proposal builder page 
    */
    
    public Pagereference redirectionControl()
    {
    	
    	//This extra check have been introduced to allow the user to come back on this select template page from the main page. When user comes from Main page the "ism" i.e  
    	// is main page parameter will be added to to the URl for identification if user is coming from Opportunity detail page or coming from Main page
    	if(Apexpages.currentPage().getParameters().containsKey('ism') && Boolean.valueOf(Apexpages.currentPage().getParameters().get('ism')))
    	{
	    	return null;
    	}
    	else
    	{
    		List<Opportunity_Component__c> lstAlreadyCreatedOpportunitycomponents = [SELECT Id, Opportunity__r.StageName, Opportunity__r.CreatedDate
	    																			 FROM Opportunity_Component__c
	    																			 WHERE Opportunity__c = :strOpportunityId
	    																			 limit 1];
	    	
	    	//If any Opportunity Component is already present in the database i.e this opportunity have already proposals in place so no need to render the Proposal builder page
	    	if(lstAlreadyCreatedOpportunitycomponents != null && !lstAlreadyCreatedOpportunitycomponents.isEmpty()) {

	    		JfrsnSettings__c objJfrsnSettings = JfrsnSettings__c.getInstance('standard');
	    		
	    		if(lstAlreadyCreatedOpportunitycomponents[0].Opportunity__r.CreatedDate < objJfrsnSettings.EventHorizon__c) {
	    			return new Pagereference('/p/opp/SelectSearch?addTo=' + strOpportunityId + '&retURL=%2F' + strOpportunityId);
	    		}
	    		return new Pagereference('/apex/jfrsn?oppty='+ strOpportunityId + '&stageName=' + lstAlreadyCreatedOpportunitycomponents[0].Opportunity__r.StageName);
	    	}
	    	else
	    		return null;	
    	}
    	
    }
    
    
}