public with sharing class WidgetRepository {
	
	public class WidgetRepositoryException extends Exception { }
	
	static public list<PageRegionWidget__c> getWidgetsRegionDataByPage(String page, PageContext context) {
		if(Utilities.getObjectAccess('read', new PageRegionWidget__c().getSobjectType())
			&& Utilities.getObjectAccess('read', new PageRegion__c().getSobjectType())
			&& Utilities.getObjectAccess('read', new Page__c().getSobjectType())
			&& Utilities.getObjectAccess('read', new Widget__c().getSobjectType())
			&& Utilities.getObjectAccess('read', new Region__c().getSobjectType())
			) {
			
			String contexCritetion = '';
			if(context != null) {
				if(context == PageContext.Desktop) {
					contexCritetion = 'AND Widget__r.isDesktop__c = true ';
				}
				else if(context == PageContext.Mobile) {
					contexCritetion = 'AND Widget__r.isMobile__c = true ';
				}
			}
			
			return Database.query('SELECT Id, Name, Configuration__c, Page_Region__c, Page_Region__r.Region__r.Name, ' 
				+ 'Page_Region__r.Page__r.Name, Widget__c, Widget__r.Type__c, ' 
				+ 'Widget__r.Namespace__c, Widget__r.Name, Widget__r.Configuration__c ' 
				+ 'FROM PageRegionWidget__c ' 
				+ 'WHERE Page_Region__r.Page__r.Name =: page ' + contexCritetion 
				+ 'ORDER BY Order__c nulls last');
		}	
		else
			return new List<PageRegionWidget__c>();
	}
	
	
	/* 
	* Configuration implementation can be substitutable 
	*/
	static public Map<String, List<WidgetAbstract>> loadAllWidgetsFromConfiguration(String page, PageContext context)
	{		
		if(page == null) throw new WidgetRepositoryException('Wrong method attribute');
		
		Map<String, List<WidgetAbstract>> widgets = new Map<String, List<WidgetAbstract>>();
		
		// build widgets from configuration settings
		for(PageRegionWidget__c widgetName : getWidgetsRegionDataByPage(page, context))
		{	
			String regionEdentity = widgetName.Page_Region__r.Region__r.Name;
			
			if(String.isEmpty(regionEdentity)) throw new WidgetRepositoryException(
				'Missing required param "Region__c" for widget repository initialization.'
			);
						
			// instantiating widget based on PageSettings implementation			
			WidgetAbstract widgetImpl = WidgetAbstract.getInstance( new WidgetPageSettingsConfiguration(widgetName));
			
			if(widgetImpl == null) 
				throw new WidgetRepositoryException('Widget ' + widgetName.Name + ' can\'t be instantiated' );			
						
			// first initialization
			if(!widgets.containsKey(regionEdentity)) widgets.put(regionEdentity, new List<WidgetAbstract>()); 
			
			widgets.get(regionEdentity).add(widgetImpl);
		}
		
		return widgets;
	}
	
	
	
	static public WidgetAbstract getWidgetInstanceById(String widgetInstanceName) {
		
		if(String.isEmpty(widgetInstanceName)) throw new WidgetRepositoryException('Wrong \'getWidgetInstanceById\' method attribute');
				
		PageRegionWidget__c widgetName = [
			SELECT Id, Name, Configuration__c, Page_Region__c, Page_Region__r.Region__r.Name, 
				   Page_Region__r.Page__r.Name, Widget__c, Widget__r.Type__c, Widget__r.Namespace__c, 
				   Widget__r.Name, Widget__r.Configuration__c  
			FROM PageRegionWidget__c 
			WHERE PageRegionWidget__c.Name = :widgetInstanceName
		];
		return WidgetAbstract.getInstance( new WidgetPageSettingsConfiguration(widgetName) ); 
	}
		
}