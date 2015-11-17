/*
*Class: SL_MyProfile_Controller
*Description: This class is used to redirect the currently loggedin Portal User on the corresponding Contact record 
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_MyProfile_Controller {

    public PageReference redirect() {
        User u = [SELECT ContactID FROM User WHERE id =: UserInfo.getUserId()];
        pagereference pageref = new pagereference('/' + u.ContactID);
        pageref.setredirect(true);
        return pageref;
    }

}