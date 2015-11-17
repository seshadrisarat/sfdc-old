@isTest
private class TestPEDealTeamMemberList {

    static testMethod void myUnitTest() {
        List <PE_Deals__c> deals = new List<PE_Deals__c>();
        PE_Deals__c deal1 = new PE_Deals__c(name = 'Test1', Date_Logged__c = Date.today());
        PE_Deals__c deal2 = new PE_Deals__c(name = 'Test2', Date_Logged__c = Date.today());
        deals.add(deal1);
        deals.add(deal2);
        insert deals;
        List <Employee_Profile__c> emps = new List<Employee_Profile__c>();
        Employee_Profile__c emp1 = new Employee_Profile__c(First_Name__c = 'Ricky', Last_Name__c = 'Ricardo', Group__c = 'Moelis Capital Partners');
        Employee_Profile__c emp2 = new Employee_Profile__c(First_Name__c = 'Jim', Last_Name__c = 'James', Group__c = 'Moelis Capital Partners');
        Employee_Profile__c emp3 = new Employee_Profile__c(First_Name__c = 'Bob', Last_Name__c = 'Robertson', Group__c = 'Moelis Capital Partners');
        Employee_Profile__c emp4 = new Employee_Profile__c(First_Name__c = 'Carl', Last_Name__c = 'Carlson', Group__c = 'Moelis Capital Partners');
        emps.add(emp1);
        emps.add(emp2);
        emps.add(emp3);
        emps.add(emp4);
        insert emps;
        List <PE_Deal_Team_Member__c> dtms = new List <PE_Deal_Team_Member__c>();
        PE_Deal_Team_Member__c dtm1 = new PE_Deal_Team_Member__c(PE_Deals__c = deal1.id, Employee__c = emp1.id);
        PE_Deal_Team_Member__c dtm2 = new PE_Deal_Team_Member__c(PE_Deals__c = deal1.id, Employee__c = emp2.id);
        PE_Deal_Team_Member__c dtm3 = new PE_Deal_Team_Member__c(PE_Deals__c = deal1.id, Employee__c = emp3.id);
        PE_Deal_Team_Member__c dtm4 = new PE_Deal_Team_Member__c(PE_Deals__c = deal1.id, Employee__c = emp4.id);
        PE_Deal_Team_Member__c dtm5 = new PE_Deal_Team_Member__c(PE_Deals__c = deal2.id, Employee__c = emp1.id);
        PE_Deal_Team_Member__c dtm6 = new PE_Deal_Team_Member__c(PE_Deals__c = deal2.id, Employee__c = emp2.id);
        PE_Deal_Team_Member__c dtm7 = new PE_Deal_Team_Member__c(PE_Deals__c = deal2.id, Employee__c = emp3.id);
        PE_Deal_Team_Member__c dtm8 = new PE_Deal_Team_Member__c(PE_Deals__c = deal2.id, Employee__c = emp4.id);
        dtms.add(dtm1);
        dtms.add(dtm2);
        dtms.add(dtm3);
        dtms.add(dtm4);
        dtms.add(dtm5);
        dtms.add(dtm6);
        dtms.add(dtm7);
        dtms.add(dtm8);
        insert dtms;
        PE_Deals__c newDeal1 = [Select name, Deal_Team_Members__c FROM PE_Deals__c where name = 'Test1'];
        PE_Deals__c newDeal2 = [Select name, Deal_Team_Members__c FROM PE_Deals__c where name = 'Test2'];
        System.debug(newDeal1.Deal_Team_Members__c);
        System.debug(newDeal2.Deal_Team_Members__c);
        System.assert(newDeal1.Deal_Team_Members__c.Contains('Jim James'));
        System.assert(newDeal2.Deal_Team_Members__c.Contains('Bob Robertson'));
        System.debug(newDeal1.Deal_Team_Members__c);
        System.debug(newDeal2.Deal_Team_Members__c);
        delete dtm1;
        delete dtm8;
        newDeal1 = [Select name, Deal_Team_Members__c FROM PE_Deals__c where name = 'Test1'];
        newDeal2 = [Select name, Deal_Team_Members__c FROM PE_Deals__c where name = 'Test2'];
        System.assert(newDeal1.Deal_Team_Members__c.Contains('Jim James'));
        System.assert(!(newDeal1.Deal_Team_Members__c.Contains('Ricky Ricardo')));
        System.assert(newDeal2.Deal_Team_Members__c.Contains('Bob Robertson'));
        System.assert(!(newDeal2.Deal_Team_Members__c.Contains('Carl Carlson')));
        System.debug(newDeal1.Deal_Team_Members__c);
        System.debug(newDeal2.Deal_Team_Members__c);
        delete dtm2;
        delete dtm3;
        delete dtm4;
        delete dtm5;
        delete dtm6;
        delete dtm7;
        newDeal1 = [Select name, Deal_Team_Members__c FROM PE_Deals__c where name = 'Test1'];
        newDeal2 = [Select name, Deal_Team_Members__c FROM PE_Deals__c where name = 'Test2'];
        System.assert(newDeal1.Deal_Team_Members__c == null);
        System.assert(newDeal2.Deal_Team_Members__c == null);
        System.debug(newDeal1.Deal_Team_Members__c);
        System.debug(newDeal2.Deal_Team_Members__c);
        
    }
}