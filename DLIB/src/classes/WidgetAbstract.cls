global abstract with sharing class WidgetAbstract implements IWidget {
	
	global String id {get; protected set;}	
	
	/**
	** Widget instance specific error
	**/
	global String error {
		get; protected set;
	}
	
	/**
	** Configuration properties of current widget instance
	**/
	global Map<String, Object> properties {get; protected set;}
	
	// SF component object builder
	global abstract ApexPages.Component newComponent();
	
	/**
	* Returns widget instance Id (must be following to widget interface)
	**/
	public String getId()
	{
		return id;
	}
	
	/**
	* Returns widget name
	**/
	public String getName()
	{
		return Utilities.getClassName(this);
	}
	
	// called after all external data (such as configuration) have been assigned
	protected virtual void initialize() {
		
	}
	
	// called after all events handling is completed
	public virtual void postInitialize() {
		
	}
	 
	// method is called from implementation class to check user has access for current widget's object
	public Boolean getObjectAccess(String accessType, Schema.SObjectType sobjType) {
		return Utilities.getObjectAccess(accessType, sobjType);
	}
		
	/**
	* Factory method creates widget implementation object (widget logics)
	**/
	static public WidgetAbstract getInstance(IWidgetConfiguration configuration)
	{		
		system.debug(System.LoggingLevel.INFO, 'Configuration : ' + configuration);
		String widgetType = configuration.widgetType();
		String widgetNamespace = configuration.widgetNamespace();
		Type compType = Type.forName(widgetType);
		
		// let's try to check for a class outside the managed package (client's widgets) with the supplied namespace
		if(compType == null) compType = Type.forName(widgetNamespace, widgetType);

		if(compType == null) { // no class with such a type has been found in the system
			system.debug(System.LoggingLevel.ERROR, 'Widget implementation class: ' + widgetType + ' hasn\'t been found');
			return null;
		}
		
		WidgetAbstract widgetImpl = (WidgetAbstract)compType.newInstance();		
		widgetImpl.id = configuration.widgetInstanceId();
		
		widgetImpl.properties = configuration.widgetPropertiesConfiguration();
		
		
		widgetImpl.initialize();
		
		return widgetImpl;
	}
	
	/**
	* Factory method creates corresponding VF component
	**/
	static public ApexPages.Component buildComponent(WidgetAbstract w)
	{	
		ApexPages.Component c = w.newComponent();
		// bind their IDs
		c.id = w.id;		
		
		return c;
	}
}