@isTest
private class TestRestrictContactByName
{
    @isTest static void testRestrictContactByName()
    {
        Contact objContact = new Contact(LastName = 'INVALIDNAME');
        insert objContact ;
    }
}