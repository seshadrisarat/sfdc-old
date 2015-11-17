/*
MOELIS-96
Trigger on Employee (after insert) to create new Employee registration.
Have a new 'Employee Registration' record created automatically whenever new employee record is added 
into SalesForce with the following fields populated:
Name,Title,Location/Main Office
(and link the records using existing relationship)
*/
trigger SL_EmployeeProfile_create on Employee_Profile__c (after insert)
{
    Employee_Registrations__c newER;
    List<Employee_Registrations__c> listERToInsert = new List<Employee_Registrations__c>();
    for (Employee_Profile__c item : Trigger.new) 
    {
        newER = new Employee_Registrations__c(Employee_Name__c = item.id);
        listERToInsert.add(newER);
    }
    if(listERToInsert.size() > 0) insert listERToInsert;
}