public class SL_Intranet_StandardChatter extends WidgetAbstract 
{
	/* @Name           - newComponent
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for creating Component dynamically.
	*/
	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_Intranet_StandardChatter c = new Component.c.SL_Intranet_StandardChatter();   
		c.aComponentImpl = this; 
		
    	return c;
  	}
  	/* End : newComponent */
}