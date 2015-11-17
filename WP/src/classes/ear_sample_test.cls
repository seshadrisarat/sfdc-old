@isTest(SeeAllData=true)
public class ear_sample_test {

static testMethod void myUnitTest() {
	ear_sample_pdf_page_controller x=new ear_sample_pdf_page_controller();
	Decimal d1 = x.getDecimalMod(1.0, 2.0);
	//x.deal_id= [ select id from Deal (limit 1)].first();
	Deal__c d_l = [Select Id from Deal__c where Name like '%Antero%' limit 1];
	x.deal_id = d_l.Id ;
	
	
	String s1 = x.pad2(25);
	s1 = x.pad2(25);
	s1 = x.getDealTeam();
	s1 = x.getCurrencySymbolFromIso('JPY');
	s1 = x.formatDate(Date.today());
	s1 = x.getCompCurrencyCode();
	s1 = x.getRevenue_MM();
	s1 = x.getEBITDA_MM();
	s1 = x.getWP_Investment_MM();
	s1=x.getWP_Ownership_Fully_Diluted();
	s1 = x.getTransaction_Value_MM();
	s1 = x.getEAR_Description();
	}
}



/* private class SL_test_deal_team {

    static testMethod void myUnitTest() {
        SL_handler_Deal_Team x = new SL_handler_Deal_Team(false,1);
      
      Deal_Team__c fo = new Deal_Team__c();
     Contact emp = [Select Id from Contact where lastname = 'Chiu' limit 1];
      Deal__c dlX = [Select Id From Deal__c limit 1];
      fo.Employee__c=emp.Id;
      fo.Deal__c = dlX.Id;
      insert fo;
    }  
}
*/