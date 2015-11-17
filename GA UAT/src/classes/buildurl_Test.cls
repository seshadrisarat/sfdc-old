@isTest
public class buildurl_Test {
    static testMethod void Test_buildurl() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        buildurl.getpic('http://api.salesforce.com/foo/bar');
    }
}