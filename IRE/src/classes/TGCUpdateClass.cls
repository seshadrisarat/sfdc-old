public class TGCUpdateClass {
    public void UpdateContactInfo(list<contact> ContactList) {
        Set<ID> ContactIdSet = new Set<ID>();
        List<ID> ContactIdList = new list<ID>();
        for(Contact c: ContactList){
            if(c.Id != null){
                ContactIDSet.add(c.Id);
            }
        }
        ContactIdList.addall(ContactIDSet);
        
        //Nightly_Jobs SalesRating = new Nightly_Jobs();
        //SalesRating.Sales_Rating(ContactIdList);
        list<contact> TGCcontacts = new list<contact>([SELECT id, Status__c, Timezone_DST__c, sales_rating__c, Additional_Account_Notes__c, MailingCity, MailingState, mailingpostalcode, Contact_Type__c, Prospect_Type__c, Time_Zone__c, TGC__c, wholesaler__c, internal__c, IPCC_Specialist__c, Account.BD_Inland_Contact__c, Account.BD_Specific_Info__c, IREIT_Sales__c,
                                                       (
                                                           select id from Home_Office_Roles__r limit 1
                                                       ),
                                                       (
                                                           select id, sales_date__c, fund_acronym__c from Daily_sales__r order by sales_date__c desc limit 1
                                                       )
                                                       from contact
                                                       where id = :ContactIdSet and mailingstate != null and mailingpostalcode != null
                                                       order by mailingstate]);
        list<Territory_Grouping_Code__c> TGClist = new list<Territory_Grouping_Code__c>();
        Map<string, Territory_Grouping_Code__c> CitytoTGC = new Map<string, Territory_Grouping_Code__c>();
        Map<string, Contact> ContactsUpdate = new Map<string, Contact>();
        integer i = 0;
        integer j = 0;
        integer k = 0;
        string CurrentState = 'none';
        system.debug('Current State: '+CurrentState);
        for (contact c: TGCcontacts){
            i += 1;
            string SalesRatingBefore = c.Sales_Rating__c;
	        c.Sales_Rating__c = Contact_Sales_Rating(c);
            if (c.Sales_Rating__c != SalesRatingBefore){
                ContactsUpdate.put(c.id, c);
            }
            //Checks if current state of contact matches the current list
            //This is to make sure we have smaller queries, and less queries
            if (CurrentState != c.MailingState){
                system.debug('Current State: '+CurrentState+' | New State: '+c.MailingState);
                TGClist = new list<Territory_Grouping_Code__c>([SELECT City__c, state__c, POSTAL_PREFIX__c, Territory_Grouping_Code__c, Time_Zone_Name__c, Wholesaler__c, Wholesaler_Internal__c, Wholesaler_IPCC__c, Daylight_Savings__c from Territory_Grouping_Code__c where state__c = :c.MailingState order by city__c]);
                CurrentState = c.MailingState;
                CitytoTGC = new Map<string, Territory_Grouping_Code__c>();
                //Feeds TGC info into an easy to reference map
                for (Territory_Grouping_Code__c tgc: TGClist){
                    string CitytoTGCKey = tgc.City__c.toUpperCase() +'-'+tgc.POSTAL_PREFIX__c;
                    CitytoTGC.put(CitytoTGCKey, tgc);
                }
            }
            if (c.Account.BD_Specific_Info__c != c.Additional_Account_Notes__c){
                c.Additional_Account_Notes__c = c.Account.BD_Specific_Info__c;
                ContactsUpdate.put(c.id, c);
            }
            
            list<Daily_sale__c> DS = c.Daily_sales__r;
            list<Home_Office_Roles__c> HOR = c.Home_Office_Roles__r;
            
            //Updates Lead/Prospect/Client
            date Date365Ago = date.today();
            Date365Ago = date365ago.addDays(-365);
            
            if (c.Status__c != 'Inactive'){
                if (c.IREIT_Sales__c > 0){
                    if(c.Prospect_Type__c != 'Client'){
                        c.Prospect_Type__c = 'Client';
                        ContactsUpdate.put(c.id, c);
                    }
                }
                else If (ds.size() > 0){
                    for (daily_sale__c ds1: DS){
                        if (ds1.sales_date__c > Date365Ago){
                            if(c.Prospect_Type__c != 'Client'){
                                c.Prospect_Type__c = 'Client';
                                ContactsUpdate.put(c.id, c);
                            }
                        }
                        else
                        {
                            if(c.Prospect_Type__c != 'Prospect'){
                        		c.Prospect_Type__c = 'Prospect';
                        		ContactsUpdate.put(c.id, c);
                            }
                        }
                    }
                }
                else if (c.Prospect_Type__c == 'lead'){
                    //do nothing, this could probably be cleaned up 
                    //but i'm just copying the old logic right now in case there's a reason for this
                }
                else {
                    if(c.Prospect_Type__c != 'Prospect'){
                        c.Prospect_Type__c = 'Prospect';
                        ContactsUpdate.put(c.id, c);
                    }
                }
            }
            else
            {
            	if(c.Prospect_Type__c != null){
                	c.Prospect_Type__c = null;
                    ContactsUpdate.put(c.id, c);
                }
            }
            
            //Updates Contact Type
            //Ignores a variety over override types for specific situations
            if ((c.Contact_Type__c != '3rd Party Research') && (c.Contact_Type__c != 'Partner') && (c.Contact_Type__c != 'International') && (c.Contact_Type__c != 'Inland Staff')){
                if ((HOR.size() > 0) && (ds.size() == 0)){
                    if (c.Contact_Type__c != 'Dealer' && c.Contact_Type__c != 'Advisor/Dealer'){
	                    c.Contact_Type__c = 'Dealer';
    	                ContactsUpdate.put(c.id, c);
                    }
                } else if ((HOR.size() > 0) && (ds.size() > 0)){
                    if (c.Contact_Type__c != 'Advisor/Dealer'){
                        c.Contact_Type__c = 'Advisor/Dealer';
                        ContactsUpdate.put(c.id, c);
                    }
                } else if ((HOR.size() == 0)){
                    if (c.Contact_Type__c != 'Advisor'  && c.Contact_Type__c != 'Dealer'){
                    	c.Contact_Type__c = 'Advisor';
                    	ContactsUpdate.put(c.id, c);
                    }
                }
            }
            //Updates Home Office Contact Wholesaler
            if (c.Contact_Type__c == 'Dealer') {
                if (c.Account.BD_Inland_Contact__c != null) {
                    if (c.Account.BD_Inland_Contact__c != c.wholesaler__c){
                    	c.wholesaler__c = c.Account.BD_Inland_Contact__c;
                    }
                }
                else {
                    if (c.Account.BD_Inland_Contact__c != c.wholesaler__c){
                        if (c.wholesaler__c != 'Vaughan'){
                    		c.wholesaler__c = 'Vaughan';
                        }
                    }
                }
                c.Internal__c = 'Neese - GA';
                c.IPCC_Specialist__c = null;
                ContactsUpdate.put(c.id, c);
            }
            //Updates 3rd Party Research
            if (c.Contact_Type__c == '3rd Party Research') {
                c.wholesaler__c = 'Curtis';
                c.internal__c = 'Curtis - IL';
                c.IPCC_Specialist__c = null;
                ContactsUpdate.put(c.id, c);
            }
            //Updates Inland Staff
            if (c.Contact_Type__c == 'Inland Staff') {
                c.wholesaler__c = null;
                c.internal__c = null;
                c.IPCC_Specialist__c = null;
                ContactsUpdate.put(c.id, c);
            }
            //Gets TGC and other info
            //system.debug('TGC Key: '+TGCoutKey);
            string TGCoutKey = null;
            if (c.mailingpostalcode.length() > 4){
            	TGCoutKey = c.MailingCity.toUpperCase() +'-'+c.mailingpostalcode.substring(0,5);
        	}
            
            //Gets TGC Info
            Territory_Grouping_Code__c TGCout = CitytoTGC.get(TGCoutKey);

            if (TGCout != null){
                j += 1;
                //Update Timezone
                if (c.Time_Zone__c != TGCout.Time_Zone_Name__c){
                    c.Time_Zone__c = TGCout.Time_Zone_Name__c;
                    ContactsUpdate.put(c.id, c);
                }    
                //Daylight Savings
                if (TGCout.Daylight_Savings__c != c.Timezone_DST__c){
                    c.Timezone_DST__c = TGCout.Daylight_Savings__c;
                    ContactsUpdate.put(c.id, c);
                }
                //Updates TGC if TGC isn't null
                if (TGCout.Territory_Grouping_Code__c != null){
                    if (c.TGC__c != TGCout.Territory_Grouping_Code__c){
                        c.tgc__c = TGCout.Territory_Grouping_Code__c;
                        ContactsUpdate.put(c.id, c);
                        //system.debug('tgc change from: '+c.TGC__c+' to: '+TGCout.Territory_Grouping_Code__c);
                    }
                }
                
				//If type is advisor related it adds wholesaler
                if ((c.Contact_Type__c == 'Advisor/Dealer' || c.Contact_Type__c == 'Advisor')){
                    if (TGCout.wholesaler__c != null){
                        c.Wholesaler__c = TGCout.Wholesaler__c;
                        c.Internal__c = tgcout.Wholesaler_Internal__c;
                        c.IPCC_Specialist__c = tgcout.Wholesaler_IPCC__c;
                    	ContactsUpdate.put(c.id, c);
                    }
                }
            }
            Else
            {
                k += 1;  
                if (c.Contact_Type__c != 'Dealer'){
                	c.wholesaler__c = null;
                	c.Internal__c = null;
                	c.IPCC_Specialist__c = null;    
                }
                c.Time_Zone__c = null;
                c.tgc__c = null;
                ContactsUpdate.put(c.id, c);
                system.debug('Null Reference: ' +c.MailingCity +', ' +c.MailingState);
                system.debug('TGC Reference: '+ TGCoutKey);
                //break;
            }
        }
        system.debug('Records: ' + i + ' Matched TGC items: ' + j + ' Unmatched Items: ' + k);
        update ContactsUpdate.values();
        }
    
    	//SalesRating
        Public string Contact_Sales_Rating(Contact c){
            if (c.Status__c == 'Inactive'){
                return '6';
            }
            //Updates non-inactive people to 5, doesn't break the loop in case
            //they have sales
            if (c.Status__c != 'Inactive' && c.Sales_Rating__c == '6'){
                c.Sales_Rating__c = '5';
            }
            if (c.Sales_Rating__c == null){
                c.Sales_Rating__c = '5';
            }
            if (c.IREIT_Sales__c >= 1000000){
                return '1';
            }
            if (c.IREIT_Sales__c >= 500000){
                return '2';
            }
            if (c.IREIT_Sales__c >= 250000){
	            return '3';
            }
            if (c.IREIT_Sales__c >= 1){
                return '4';                
            }
            return c.Sales_Rating__c;
        }
}