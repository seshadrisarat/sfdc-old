public with sharing class SL_IntranetChatterTopic extends WidgetAbstract
{   
    public List<Topic> topicsList {get; private set;} 
    public String url {get; private set;}
    
    
    public SL_IntranetChatterTopic()
    {        
        topicsList = new List<Topic>();
    }
    
    /* 
    * initialize method called on component's initialize
    * Configuration: 
    * {"topicId":"", "url":""}
    * url: https://silverline--dlib.cs24.my.salesforce.com/apex/SL_Intranet?page=Home&topicId=SELECTEDTOPICID
    * SELECTEDTOPICID - will be substitued with picked value
    */
    public override protected void initialize()
    {
        // Fetch the configuration for the widget
        if(this.properties != null) {
        	
            if(this.properties.containsKey('topicId')) {
            	String topicIdsParam = String.valueOf(this.properties.get('topicId'));
            	
            	if(!String.isBlank(topicIdsParam)) {
            		Set<Id> topicIds = new Set<Id>();
            		
            		for(String s : topicIdsParam.trim().split(',')) {
            			topicIds.add(s.trim());
	            	}	
	            	topicsList = [SELECT id, Name FROM TOPIC WHERE Id IN : topicIds];
            	}
            }
            
            if(this.properties.containsKey('url')) {
            	url = String.valueOf(this.properties.get('url'));
            }            	
        }
    }
    
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically.
    */
    public override ApexPages.Component newComponent() { 
        Component.SL_IntranetChatterTopic2 c = new Component.SL_IntranetChatterTopic2();   
        c.aComponentImpl = this;  
        
        return c;
    }
    /* End : newComponent */
}