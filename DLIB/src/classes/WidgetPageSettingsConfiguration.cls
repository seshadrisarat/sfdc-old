/**
* Temporary configuration solution based on current approach
**/
public with sharing class WidgetPageSettingsConfiguration implements IWidgetConfiguration {
	
	private PageRegionWidget__c config;
	
	public WidgetPageSettingsConfiguration(PageRegionWidget__c config)
	{
		if(config == null) throw new InvalidArgumentException('config can\'t be null');
		
		this.config = config;
	}
	
	public String widgetType()
	{
		return config.Widget__r.Type__c;
	}

	public String widgetNamespace()
	{
		return config.Widget__r.Namespace__c;
	}	

	public String widgetInstanceId()
	{
		return config.Name;
	}
	
	/**
	** Returns widget actual configuration object mapped from json. 
	**/
	public Map<String, Object> widgetPropertiesConfiguration() {
		
		if(String.isEmpty(config.Configuration__c) && String.isEmpty(config.Widget__r.Configuration__c)) return null;
		
		Map<String, Object> m;
				
		try {		
			// expecting json in configuration, if there is no widget intance configuration then takes it from default 
			m = (Map<String, Object>)JSON.deserializeUntyped(
				!String.isEmpty(config.Configuration__c) ? config.Configuration__c : config.Widget__r.Configuration__c
			);
		}			
		catch(JSONException e) {
			
		}
		catch(Exception e) { // this is necessary, because not only JSONExcption is raised 
			
		}
		return m;
	}
}