public with sharing virtual class PageControllerBase {
   
    /**
    * All widgets objects grouped by regions that present on the current page
    **/
	protected Map<String, List<WidgetAbstract>> widgets;
	
	/**
	* Used for lazy loading 
	**/ 
	transient private IWidget[] wList;	
	transient private Set<String> wClasses;
	
	public String userTimeZone {
		get {
			TimeZone tz = UserInfo.getTimeZone();
			return tz.toString();
		}
	}
		
	private void lzFlattenWidgets(Boolean callPostInitialization) {
		if(wList == null) {
						
			wList = new IWidget[]{};
			wClasses = new Set<String>{};
			
			if(widgets == null) return;	
			
			for(List<WidgetAbstract> innerList : widgets.values()){
				for(WidgetAbstract w : innerList){					
					wList.add((IWidget)w);
					wClasses.add(w.getName());
					if(callPostInitialization) ((WidgetAbstract)w).postInitialize();
				}
			}
		}			
	}	
		
	/**
	* Returns flattened (all page widgets) widgets 
	**/
	public IWidget[] allWidgets {
		get {			
			lzFlattenWidgets(false);
			return wList;
		}
	}
	
	public String[] widgetClasses {
		get {			
			lzFlattenWidgets(false);
			String[] t = new String[]{};
			t.addAll(wClasses); 
			return t;
		}
	}		
    
	public PageControllerBase getThis() {
		return this;
	}
  
    /**
    * Overloaded default page context init
    **/ 
  	protected void init(String page) {
  		init(page, null);
  	}
  
    /**
    * Preloads all page related widgets on the page
    **/
	protected void init(String page, PageContext context) {
		system.debug('SL_DEBUG: page: ' + page);
		
		// first initialization phase happens - all subscribers are in place
		widgets = WidgetRepository.loadAllWidgetsFromConfiguration(page, context); 
		
		if(widgets == null) return; 
		
		// event broadcasting phase 
		WidgetConfigurationListener.getInstance().notifyDelayed(); // notify all listeners with postponed broadcasters
		
		// post initialization phase
		lzFlattenWidgets(true);
	}
    
    /**
    * Returns corresponding group of widgets (for example, left sidebar widgets) 
    **/
    public List<WidgetAbstract> getWidgetsByIdentity(String identity)
    {
    	
    	if(identity == null || !widgets.containsKey(identity) ) return null; 
    	
    	return widgets.get(identity);
    }
    
    /**
    * Renders region components
    **/
    public ApexPages.Component renderRegionComponents(String regionIdentity) {
    	ApexPages.Component c;
		List<ApexPages.Component> components = new List<ApexPages.Component>();
		
		List<WidgetAbstract> widgets = getWidgetsByIdentity(regionIdentity);
		
		if(widgets != null) 
		{
			for(WidgetAbstract widget : widgets)
			{	
				c = WidgetAbstract.buildComponent(widget); 
				components.add(c);
			}
		}	
				
		return decorateWidgets(components);
    }
    
    /**
    * Wraps multiple components List<ApexPages.Component> with PageBlock container (composite) to get rid of List<> 
    * and maintains correct return type for "dynamicComponent" VF element 
    **/
    protected ApexPages.Component decorateWidgets(List<ApexPages.Component> components)
	{	
		system.debug(components);
		
		if(components == null || components.isEmpty()) return null;
		
		if(components.size() == 1) return components[0]; // not necessary to wrap
		
		Component.Apex.Pageblock pb = new Component.Apex.Pageblock();
		pb.childComponents.addAll(components);
		
		return pb; 
	}        
}