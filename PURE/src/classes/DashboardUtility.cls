/**
*       DashboardUtility contains re-usable methods for the dashboard vf controllers
*   
*       Author  :   Wilson Ng
*       Date    :   Mar 05, 2013
*  
*       Revision History:
*           Date    Author          Comments
*
*/
public with sharing class DashboardUtility {

    static public final string BROKER_REC_TYPE = 'Broker';
    static public final string BROKER_GROUP_REC_TYPE = 'Broker_Group';
    static public final string TRIP_REPORT_REC_TYPE = 'Trip_Report'; 
    
    // note: displayed currency values: brokerGroup is in ($MM), whereas broker is in ($thous)
    static public string getCurrencyScaleLabel(boolean isGroup) {
        return '($ ' + (isGroup?'M':'K') + '\'s)';
    }
    
    // returns non-null double value
    static public double getValue(sObject sobj, string fld) {
        return (sobj.get(fld)!=null ? Double.valueOf(sobj.get(fld)) : 0);
    }
    // get value , if currency scale it
    static public decimal getDisplayValue(sObject sobj, string fld, string typ, integer scale, integer precision) {
        decimal val = getValue(sobj, fld);
        
        return typ=='CURRENCY' ? getDisplayValue(val, scale, precision) : val.setScale(2); //hacked on prescision here
    }
    // just scale me a value
    static public decimal getDisplayValue(decimal val, integer scale, integer precision) {
        return ( val / scale ).setScale( precision );
    }
            
    // converts map<int, dec> to list<data>
    static public list<Data> convertToDataList(map<integer, decimal> ytdMap) {
        list<Data> retList = new list<Data>();
        list<integer> keys = new list<integer> ( ytdMap.keySet() );
        keys.sort();
        for(integer mon : keys)
            retList.add(new Data(convertToMonth(mon), ytdMap.get(mon)));
        return retList;
    }
    
    // constructs an initialized map of YTD months (1-to-12)
    static public map<integer, decimal> constructEmptyYTDMap() {
        map<integer, decimal> retMap = new map<integer, decimal>();
        for(integer i=1; i<=12; i++)
            retMap.put(i, 0);
        return retMap;
    }
    
    // month conversions
    static public list<string> monthsAbbrev = new list<string> { 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' };
    static string convertToMonth(integer i) {
        return (i>=1 && i<=12) ? monthsAbbrev.get(i-1) : 'Unk';
    }
    
    //
    // Wrapper class
    public class Data {
        public string name { get; set; }
        public object obj1 { get; set; }
        public string obj1type { get; set; }
        public decimal data1 { get; set; }
        public decimal data2 { get; set; }
        public decimal data3 { get; set; }
        public decimal data4 { get; set; }
        public decimal data5 { get; set; }
        public Data(string name, object obj1, string obj1type) {
            this.name = name;
            this.obj1 = obj1;
            this.obj1type = obj1type;
        }
        public Data(string name, decimal data1) {
            this(name, data1, 0);
        }
        public Data(string name, decimal data1, decimal data2) {
            this(name, data1, data2, 0);
        }
        public Data(string name, decimal data1, decimal data2, decimal data3) {
            this(name, data1, data2, data3, 0);
        }
        public Data(string name, decimal data1, decimal data2, decimal data3, decimal data4) {
            this(name, data1, data2, data3, data4, 0);
        }
        public Data(string name, decimal data1, decimal data2, decimal data3, decimal data4, decimal data5) {
            this.name = name;
            this.data1 = (data1!=null ? data1 : 0);
            this.data2 = (data2!=null ? data2 : 0);
            this.data3 = (data3!=null ? data3 : 0);
            this.data4 = (data4!=null ? data4 : 0);
            this.data5 = (data5!=null ? data5 : 0);
        }
    }
    
    // test methods
    @isTest
    static void testThisClass() {
        
        Test.startTest();
        
        string tmpstr = getCurrencyScaleLabel(true);
        system.assertEquals('($ M\'s)', tmpstr, 'Error: getCurrencyScaleLabel method did not return correct true value.');
        tmpstr = getCurrencyScaleLabel(false);
        system.assertEquals('($ K\'s)', tmpstr, 'Error: getCurrencyScaleLabel method did not return correct false value.');
        
        string testfldname = 'AnnualRevenue';
        Account acct = new Account(Name='testacct');
        double tmpdouble = getValue(acct, testfldname);
        system.assertEquals(0, tmpdouble, 'Error: getValue method did not return null or zero value.');
        acct.AnnualRevenue = 123.45;
        tmpdouble = getValue(acct, testfldname);
        system.assertEquals(123.45, tmpdouble, 'Error: getValue method did not return non-null value.');
        
        decimal tmpdecimal = getDisplayValue(acct, testfldname, 'CURRENCY', 100, 2);
        system.assertEquals(1.23, tmpdecimal, 'Error: getDisplayValue method 1 did not return correct decimal scale and precision');
        
        tmpdecimal = getDisplayValue(987654, 1000, 0);
        system.assertEquals(988, tmpdecimal, 'Error: getDisplayValue method 2 did not return correct decimal scale and precision');
        
        tmpstr = convertToMonth(1);
        system.assertEquals('Jan', tmpstr, 'Error: convertToMonth method did not return correct month string value.');
        map<integer, decimal> mymap = constructEmptyYTDMap();
        list<Data> mylist = convertToDataList(mymap);
        
        Data testdata = new Data('name', 'obj', 'typ');
        
        Test.stopTest();
    }
}