global with sharing abstract class ComponentControllerBase {
    
    /**
    * Returns widget (component) ID
    **/
    public String getId() {
        return compImpl.id;     
    }
    
    public String getError() {
		return compImpl.error;
	}
  
    /**
    * getter/setter for component implementation
    **/
    global WidgetAbstract compImpl {  
        get; set {
            if(value != null) {
                compImpl = value;
                // compImpl.setController(this);
            }
        }
    }
}