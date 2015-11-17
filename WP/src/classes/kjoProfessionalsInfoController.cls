public with sharing class kjoProfessionalsInfoController {

    public class Person {
        String label;
        String value;
        
        public Person(String name, String Id) {
            this.label = name;
            this.value = Id;
        }
    }
    
    public String getProfessionalsList() {
        String term = ApexPages.currentPage().getParameters().get('term');
        return getProfessionalsList(term);
    }
    
    private String getProfessionalsList(String searchterm) {

        String query = 
            'Select Id, AccountId, LastName, FirstName, Name, Full_Name__c, ' +
            'ISINVESTMENTPRO__c, Status__c, RecordType.Name, User_ID__r.Id From Contact ' +
            'WHERE RecordType.Name = \'Employee\' ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' AND LastName LIKE \'' + String.escapeSingleQuotes(searchterm) + '%\'';
        
        List<Contact> people = Database.query( query + restriction + ' ORDER BY LastName, FirstName' );
    
        Person p;
        List<Person> lst = new List<Person>();
        for ( Contact person : people ) {
            p = new Person(person.Full_Name__c, person.User_ID__r.Id);
            lst.add(p);
        }
        return JSON.serialize(lst);
    }

}