public class MyLists_Controller 
{
	public static testMethod void TestHarness()
	{
		MyLists_Controller controller = new MyLists_Controller();
		
		GetLists.CIQList[] li = controller.myLists;
		controller.myLists = li;
		
		Integer i = controller.TargetListId;
		controller.TargetListId = i;
		
		i = controller.TargetListTypeId;
		controller.TargetListTypeId = i;
		
		PageReference pr = controller.GetList();
		controller.OnInit(); 	
	}
	
	//Life Cycle and Functions
	public PageReference OnInit() 
	{
		String sessionId = Session.getASPNETSessionId();
		if(sessionId != null)
		{
			myLists =  GetLists.GetListsForServiceUser(sessionId); 
		}
		return null; 
	}
	
	public GetLists.CIQList[] myLists { get; set;} 
	
	public Integer TargetListId { get; set; }
	public Integer TargetListTypeId { get; set; }
	
	public PageReference GetList()
	{
		PageReference p = new PageReference('/apex/MyListConstituents?ListTypeId=' + TargetListTypeId + '&ListId=' + TargetListId);
		p.setRedirect(true);
		return p;
	}
}