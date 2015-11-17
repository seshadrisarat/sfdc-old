@isTest
public class TestVerifyDate
{
    @isTest static void testTaskPriorityInvalid()
    {
        Date dateOfToday = VerifyDate.CheckDates(date.Today(), date.Today().addDays(2));
        dateOfToday = VerifyDate.CheckDates(date.Today(), date.Today().addDays(60));
    }
}