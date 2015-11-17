/***
** Singleton for registering events for widgets (components) collaboration 
**/
public with sharing class WidgetConfigurationListener {
	static private WidgetConfigurationListener instance = null;
	
	private Map<String, List<IObservable>> listeners;	
	private List<IWidget> delayedBroadcasters;
	
	private WidgetConfigurationListener() {
		listeners = new Map<String, List<IObservable>>();
		delayedBroadcasters = new List<IWidget>();
	}
	
	static public WidgetConfigurationListener getInstance() {
		
		if(instance == null) {
			instance = new WidgetConfigurationListener();
		}
		
		return instance;
	} 
	
	public void addEventListener(String eventWidgetName, IObservable widget) {
		if(String.isEmpty(eventWidgetName) || widget == null) return;
		
		if(!listeners.containsKey(eventWidgetName)) {
			listeners.put(eventWidgetName, new List<IObservable>() );
		}
		
		listeners.get(eventWidgetName).add(widget);
	}

	// notifies all subscribed (to this widget) listeners about its completed initialization (for example, all configuration has been loaded and prepeared)
	public void notify(IWidget widget) {
		
		if(widget == null) return;
		
		String eventWidgetName = Utilities.getClassName(widget);
		
		if(listeners.containsKey(eventWidgetName) && listeners.get(eventWidgetName) != null) {
			for(IObservable w : listeners.get(eventWidgetName)) {
				w.notify(widget);
			}
			listeners.remove(eventWidgetName);
		}
	} 
	
	public void addDelayedBroadcaster(IWidget w) {
		if(w == null) return;
		delayedBroadcasters.add(w);
	}
	
	public void notifyDelayed() {
		for(IWidget w : delayedBroadcasters) notify(w);		
		delayedBroadcasters.clear();
	}
}