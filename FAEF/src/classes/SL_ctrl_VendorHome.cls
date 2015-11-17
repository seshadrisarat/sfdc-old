public with sharing class SL_ctrl_VendorHome {
		
	public List<SL_util_VendorCommunity.PortalContact> contacts {get;set;}
	public SL_util_VendorCommunity.PortalMessage message {get;set;}
	public String chatterGroupId {get;set;}

	public SL_ctrl_VendorHome() {
		this.message = SL_util_VendorCommunity.getPortalMessage();
		this.contacts = SL_util_VendorCommunity.getPortalContacts();
		this.chatterGroupId = SL_util_VendorCommunity.getChatterGroupId();
	}
}