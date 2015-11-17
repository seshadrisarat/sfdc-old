public with sharing class SROC_CommunityController {

	public PageReference forwardToLogin(){
        return CORECONNECT.CC_CommunityUtil.forwardToLogin();
    }

}