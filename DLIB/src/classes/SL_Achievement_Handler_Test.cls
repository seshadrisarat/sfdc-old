@IsTest
public class SL_Achievement_Handler_Test{
    
    @IsTest
        public static void testCreate(){
            Achievement__c aa = new Achievement__c(Name = 'Test', Points__c = 5, Track__c = 'All');
            INSERT aa;
            Achievement__c ab = new Achievement__c(Name = 'Wore a Silverline logo', Points__c = 5, Track__c = 'All');
            INSERT ab;
            Achievement__c ac = new Achievement__c(Name = 'Attended the FinServ dinner', Points__c = 5, Track__c = 'All');
            INSERT ac;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = 'fName',
                            lastName = 'lName',
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p.id);
            INSERT tuser;
            Contact c = new Contact(LastName = 'Testerson', User__c = tuser.id);
            INSERT c;
            
            Test.startTest();
            System.RunAs(tuser){
            Dreamforce_Achievements__c dfa = new Dreamforce_Achievements__c(Achievement__c = aa.id, Notes__c = 'Testing');
            INSERT dfa;
                
                Dreamforce_Achievements__c dfa4 = new Dreamforce_Achievements__c(Achievement__c = ab.id, Notes__c = 'Testing');
            	INSERT dfa4;
                UPDATE dfa4;
                DELETE dfa4;
                UNDELETE dfa4;
                Dreamforce_Achievements__c dfa2 = new Dreamforce_Achievements__c(Achievement__c = ac.id, Notes__c = 'Testing');
                INSERT dfa2;
            	
            }
            Test.stopTest();
        }
    

}