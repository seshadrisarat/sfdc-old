public class FinancialData 
{
    public static testMethod void TestHarness()
    {
        CapitalIQSetup_Controller.InitOrgInfo();
        DisplayItem a = new DisplayItem(); 
        String str = FormatNumber('-3.1456');
        System.assert(str != null);
        String dataName;
        for(Integer x = 0; x < 5000; x++)
        {
            dataName = GetDataItemName(x);
            dataName = GetPeriodTypeName(x);
            dataName = GetInstanceTypeName(x); 
        }
        System.assert(dataName != null);
        GetFinTemplateDataItemsResponse_element b = new GetFinTemplateDataItemsResponse_element();
        ArrayOfInt c = new ArrayOfInt();
        ArrayOfFinancialDataItem d = new ArrayOfFinancialDataItem();
        //FinancialDataSoap e = new FinancialDataSoap();
        FinancialDataItem f = new FinancialDataItem();
        CompanyFinancials g = new CompanyFinancials();
        GetFinTemplateDataItems_element h = new GetFinTemplateDataItems_element();
        GetFinancials_element i = new GetFinancials_element();
        ArrayOfCompanyFinancials j = new ArrayOfCompanyFinancials();
        GetFinancialsResponse_element k = new GetFinancialsResponse_element();
        ArrayOfFinancialDataPoint l = new ArrayOfFinancialDataPoint();
        ArrayOfFinancialInstanceInfo m = new ArrayOfFinancialInstanceInfo();
        FinancialDataPoint n = new FinancialDataPoint();
        
        Integer[] listOfDIds = GetDataItemList();
        Integer place = FindIndexOf(listOfDIds, 28);
        
        FinancialInstanceInfo[] fiList = GetTearsheetFinancials(21835, null);
        
        fiList = new FinancialInstanceInfo[3];
        fiList[0] = new FinancialInstanceInfo();
        fiList[0].PEODate = DateTime.now();
        fiList[0].FilingDate = DateTime.now();
        fiList[0].DataItemList = new ArrayOfFinancialDataPoint();
        fiList[0].DataItemList.FinancialDataPoint = new FinancialDataPoint[1];
        fiList[0].DataItemList.FinancialDataPoint[0] = new FinancialDataPoint();
        fiList[1] = new FinancialInstanceInfo();
        fiList[1].PEODate = DateTime.now();
        fiList[1].FilingDate =  DateTime.now();
        fiList[1].DataItemList = new ArrayOfFinancialDataPoint();
        fiList[1].DataItemList.FinancialDataPoint = new FinancialDataPoint[1];
        fiList[1].DataItemList.FinancialDataPoint[0] = new FinancialDataPoint();
        fiList[2] = new FinancialInstanceInfo();
        fiList[2].DataItemList = new ArrayOfFinancialDataPoint();
        fiList[2].PEODate = DateTime.now();
        fiList[2].FilingDate = DateTime.now();
        fiList[2].DataItemList.FinancialDataPoint = new FinancialDataPoint[1];
        fiList[2].DataItemList.FinancialDataPoint[0] = new FinancialDataPoint();
        
        DisplayItem[] diList = FormatData(fiList);
        
    }
    
    public class DisplayItem
    {
        public DisplayItem()
        {
            Headers = new String[6];
            EffectiveDates = new String[6];
            FilingDates = new String[6];
        }
        
        public String DataItemName {get; set;}
        public String LTMMinus5 {get; set;}
        public String LTMMinus4 {get; set;}
        public String LTMMinus3 {get; set;}
        public String LTMMinus2 {get; set;}
        public String LTMMinus1 {get; set;}
        public String LTM {get; set;}
        public String[] Headers;
        public String[] EffectiveDates;
        public String[] FilingDates;
        public Integer SortIndex;
    }
    
    public static String FormatNumber(String DataItemValue)
    {
        if(DataItemValue == null || DataItemValue == '')
        {
            return '-';
        }
        Decimal value = Decimal.valueOf(DataItemValue);
        String s = '';
        if(value < 0) { s = '('; }
        s = s + String.valueOf(value.abs().setScale(2));
        if(value < 0) { s = s + ')';}
        return s;
    }
    
    public static String GetInstanceTypeName(Integer InstanceTypeId)
    { 
        if (InstanceTypeId == 1) { return 'Press Release'; }
        else if (InstanceTypeId == 2) { return 'Original'; }
        else if (InstanceTypeId == 3) { return 'Restated'; }
        return 'N/A';
    }
    
    public static String GetPeriodTypeName(Integer PeriodTypeId)
    {
        if(PeriodTypeId == 1) { return 'Annual';}
        else if(PeriodTypeId == 2) { return 'Quarterly';}
        else if(PeriodTypeId == 3) { return 'YTD';}
        else if(PeriodTypeId == 4) { return 'LTM';}
        else if(PeriodTypeId == 7) { return 'Calendar Year';}
        else if(PeriodTypeId == 8) { return 'Non-Periodic';}
        else if(PeriodTypeId == 10) { return 'Semi-Annual';}
        else if(PeriodTypeId == 12) { return 'NTM';}
        return 'N/A';
    }
    
    public static String GetDataItemName(Integer DataItemId)
    {
        String dataItemName = '';
        if(DataItemId == 28)    {dataItemName = 'Total Revenue';}
        else if(DataItemId == 10)   {dataItemName = 'Gross Profit';}
        else if(DataItemId == 380)  {dataItemName = 'Other Operating Exp., Total';}
        else if(DataItemId ==   15) {dataItemName = 'Net Income';}
        else if(DataItemId ==   400)    {dataItemName = 'EBIT';}
        else if(DataItemId ==   4051)   {dataItemName = 'EBITDA';}
        else if(DataItemId ==   9)  {dataItemName = 'Basic EPS';}
        else if(DataItemId ==   8)  {dataItemName = 'Diluted EPS';}
        else if(DataItemId ==   1002)   {dataItemName = 'Total Cash & ST Investments';}
        else if(DataItemId ==   1008)   {dataItemName = 'Total Current Assets';}
        else if(DataItemId ==   1004)   {dataItemName = 'Net Property, Plant & Equipment';}
        else if(DataItemId ==   1007)   {dataItemName = 'Total Assets';}
        else if(DataItemId ==   1009)   {dataItemName = 'Total Current Liabilities';}
        else if(DataItemId ==   1276)   {dataItemName = 'Total Liabilities';}
        else if(DataItemId ==   1005)   {dataItemName = 'Total Pref. Equity';}
        else if(DataItemId ==   1006)   {dataItemName = 'Total Common Equity';}
        else if(DataItemId ==   1275)   {dataItemName = 'Total Equity';}
        else if(DataItemId ==   1310)   {dataItemName = 'Tangible Book Value';}
        else if(DataItemId ==   2006)   {dataItemName = 'Cash from Ops.';}
        else if(DataItemId ==   2005)   {dataItemName = 'Cash from Investing';}
        else if(DataItemId ==   2004)   {dataItemName = 'Cash from Financing';}
        else if(DataItemId ==   2021)   {dataItemName = 'Capital Expenditure';}
        else if(DataItemId ==   4422)   {dataItemName = 'Levered Free Cash Flow';}
        else if(DataItemId ==   4423)   {dataItemName = 'Unlevered Free Cash Flow';}
        else if(DataItemId ==   4178)   {dataItemName = 'Return on Assets';}
        else if(DataItemId ==   4363)   {dataItemName = 'Return on Capital';}
        else if(DataItemId ==   4128)   {dataItemName = 'Return on Equity';}
        else if(DataItemId == 112) {dataItemName = 'Revenue';}
        else { dataItemName = 'N/A';}
        
        //dataItemName = dataItemName + ' [' + DataItemId + ']';
        
        return dataItemName;
    }
    
    public static DisplayItem[] FormatData(FinancialInstanceInfo[] input)
    {
        if(input == null || input.size() == 0)
        {
            return null;
        }
        
        Integer[] dataItems = GetDataItemList();
        DisplayItem[] items = new DisplayItem[dataItems.size()];

        //we should prefer Restated (3) > Original (2) > Press Release (1)
        
        Integer infoIndex = 0;
        
        Map<Integer, Integer> maxTypeForCalendarYear = new Map<Integer,Integer>();
        
        for(FinancialInstanceInfo info : input)
        {
            if(!maxTypeForCalendarYear.containsKey(info.CalendarYear))
            {
                maxTypeForCalendarYear.put(info.CalendarYear, info.InstanceTypeId);
            }
            if(maxTypeForCalendarYear.get(info.CalendarYear) < info.InstanceTypeId)
            {   
                maxTypeForCalendarYear.remove(info.CalendarYear);
                maxTypeForCalendarYear.put(info.CalendarYear, info.InstanceTypeId);
            }
        }
        
        Map<Integer, DateTime> maxFilingYearForCalendarYear = new Map<Integer,DateTime>();
        
        for(FinancialInstanceInfo info : input)
        {
            if(info.FilingDate != null)
            {
                if(!maxFilingYearForCalendarYear.containsKey(info.CalendarYear))
                {
                    maxFilingYearForCalendarYear.put(info.CalendarYear, info.FilingDate);
                }
                if(maxFilingYearForCalendarYear.get(info.CalendarYear) < info.FilingDate)
                {
                    maxFilingYearForCalendarYear.remove(info.CalendarYear);
                    maxFilingYearForCalendarYear.put(info.CalendarYear, info.FilingDate);
                }
            }
        }
        
        //these are cursor variables
        Integer x = 0;
        Integer year = 0;
        
        for(FinancialInstanceInfo info : input)
        {
            //we assume there is one instance info for each year, this is wrong
            //we need to assume that there can be a couple, and figure out which is the right one.
            
            if(maxTypeForCalendarYear.get(info.CalendarYear) == info.InstanceTypeId && maxFilingYearForCalendarYear.get(info.CalendarYear) == info.FilingDate)
            {
                x = 0;
                info.DataItemList.FinancialDataPoint = FinancialData.SortDataItems(info.DataItemList.FinancialDataPoint);
                
                for(Integer id : dataItems)
                {
                    FinancialDataPoint d = null;
                    
                    for(Integer y = 0; y < info.DataItemList.FinancialDataPoint.size();y++)
                    {
                        if(info.DataItemList.FinancialDataPoint[y].DataItemId == id)
                        {
                            d = info.DataItemList.FinancialDataPoint[y];
                            break;
                        }
                    }
                    
                    if(d == null)
                    {
                        d = new FinancialDataPoint();
                        d.DataItemId = id;
                    }
                    
                    if(year==0)
                    {
                        DisplayItem di = new DisplayItem();
                        di.DataItemName = GetDataItemName(d.DataItemId);
                        di.LTMMinus5 = FormatNumber(d.DataItemValue);
                        di.Headers[0] = GetInstanceTypeName(info.InstanceTypeId) + ' ' + GetPeriodTypeName(info.PeriodTypeId);
                        di.EffectiveDates[0] = info.PEODate.format('MMM-dd-yyyy', 'GMT');
                        di.FilingDates[0] = info.FilingDate.format('MMM-dd-yyyy', 'GMT');
                        di.SortIndex = FindIndexOf(dataItems, d.DataItemid);
                        items[x] = di;
                    }
                    if(year == 1)
                    {
                        if(items[x] == null)
                        {
                            items[x] = new DisplayItem();
                            items[x].DataItemName = GetDataItemName(d.DataItemId);
                            items[x].LTMMinus5 = '-';
                            items[x].SortIndex = FindIndexOf(dataItems, d.DataItemid);
                        }
                        items[x].LTMMinus4 = FormatNumber(d.DataItemValue);
                        items[x].Headers[1] =  GetInstanceTypeName(info.InstanceTypeId) + ' ' + GetPeriodTypeName(info.PeriodTypeId);
                        items[x].EffectiveDates[1] = info.PEODate.format('MMM-dd-yyyy', 'GMT');
                        items[x].FilingDates[1] = info.FilingDate.format('MMM-dd-yyyy', 'GMT');
                        if(items[x].DataItemName != GetDataItemName(d.DataItemId))
                        {
                            items[x].LTMMinus4 = items[x].LTMMinus4 + ' - ' + GetDataItemName(d.DataItemId);
                        }
                    }
                    else if(year == 2)
                    {
                        if(items[x] == null)
                        {
                            items[x] = new DisplayItem();
                            items[x].DataItemName = GetDataItemName(d.DataItemId);
                            items[x].LTMMinus5 = '-';
                            items[x].LTMMinus4 = '-';
                            items[x].SortIndex = FindIndexOf(dataItems, d.DataItemid);
                        }
                        items[x].LTMMinus3 = FormatNumber(d.DataItemValue);
                        items[x].Headers[2] = GetInstanceTypeName(info.InstanceTypeId) + ' ' + GetPeriodTypeName(info.PeriodTypeId);
                        items[x].EffectiveDates[2] = info.PEODate.format('MMM-dd-yyyy', 'GMT');
                        items[x].FilingDates[2] = info.FilingDate.format('MMM-dd-yyyy', 'GMT');
                        
                        if(items[x].DataItemName != GetDataItemName(d.DataItemId))
                        {
                            items[x].LTMMinus3 = items[x].LTMMinus3 + ' - ' + GetDataItemName(d.DataItemId);
                        }
                        
                    }
                    else if(year == 3)
                    {
                        if(items[x] == null)
                        {
                            items[x] = new DisplayItem();
                            items[x].DataItemName = GetDataItemName(d.DataItemId);
                            items[x].LTMMinus5 = '-';
                            items[x].LTMMinus4 = '-';
                            items[x].LTMMinus3 = '-';
                            items[x].SortIndex = FindIndexOf(dataItems, d.DataItemid);
                        }
                        items[x].LTMMinus2 = FormatNumber(d.DataItemValue);
                        items[x].Headers[3] =  GetInstanceTypeName(info.InstanceTypeId) + ' ' + GetPeriodTypeName(info.PeriodTypeId);
                        items[x].EffectiveDates[3] = info.PEODate.format('MMM-dd-yyyy', 'GMT');
                        items[x].FilingDates[3] = info.FilingDate.format('MMM-dd-yyyy', 'GMT');
                        
                        if(items[x].DataItemName != GetDataItemName(d.DataItemId))
                        {
                            items[x].LTMMinus2 = items[x].LTMMinus2 + ' - ' + GetDataItemName(d.DataItemId);
                        }
                    }
                    else if(year == 4)
                    {
                        if(items[x] == null)
                        {
                            items[x] = new DisplayItem();
                            items[x].DataItemName = GetDataItemName(d.DataItemId);
                            items[x].LTMMinus5 = '-';
                            items[x].LTMMinus4 = '-';
                            items[x].LTMMinus3 = '-';
                            items[x].LTMMinus2 = '-';
                            items[x].SortIndex = FindIndexOf(dataItems, d.DataItemid);
                        }
                        items[x].LTMMinus1 = FormatNumber(d.DataItemValue);
                        items[x].Headers[4] =  GetInstanceTypeName(info.InstanceTypeId) + ' ' + GetPeriodTypeName(info.PeriodTypeId);
                        items[x].EffectiveDates[4] = info.PEODate.format('MMM-dd-yyyy', 'GMT');
                        items[x].FilingDates[4] = info.FilingDate.format('MMM-dd-yyyy', 'GMT');
                        
                        if(items[x].DataItemName != GetDataItemName(d.DataItemId))
                        {
                            items[x].LTMMinus1 = items[x].LTMMinus1 + ' - ' + GetDataItemName(d.DataItemId);
                        }
                    }
                    else if(year == 5)
                    {
                        if(items[x] == null)
                        {
                            items[x] = new DisplayItem();
                            items[x].DataItemName = GetDataItemName(d.DataItemId);
                            items[x].LTMMinus5 = '-';
                            items[x].LTMMinus4 = '-';
                            items[x].LTMMinus3 = '-';
                            items[x].LTMMinus2 = '-';
                            items[x].LTMMinus1 = '-';
                            items[x].SortIndex = FindIndexOf(dataItems, d.DataItemid);
                        }
                        items[x].LTM = FormatNumber(d.DataItemValue);
                        items[x].Headers[5] = GetInstanceTypeName(info.InstanceTypeId) + ' ' + GetPeriodTypeName(info.PeriodTypeId);
                        items[x].EffectiveDates[5] = info.PEODate.format('MMM-dd-yyyy', 'GMT');
                        items[x].FilingDates[5] = info.FilingDate.format('MMM-dd-yyyy', 'GMT');
                        
                        if(items[x].DataItemName != GetDataItemName(d.DataItemId))
                        {
                            items[x].LTM = items[x].LTM + ' - ' + GetDataItemName(d.DataItemId);
                        }
                    }
                    x++;
                }
                year++;
            }
        } 
        return SortDisplayItems(items);
    }
    
    public static Integer FindIndexOf(Integer[] values, Integer valueToFind)
    {
        if(values == null) { return 0; }
        
        for(Integer x = 0; x < values.size(); x++)
        {
            if(values[x] == valueToFind)
            {
                return x;
            }
        }
        
        return 0;
    }
    
    public static Integer[] GetDataItemList()
    {
        List<Integer> int_x = new List<Integer>();
        int_x.add(28);
        int_x.add(10);
        int_x.add(380);
        int_x.add(15);
        int_x.add(400);
        int_x.add(4051);
        int_x.add(9);
        int_x.add(8);
        int_x.add(1002);
        int_x.add(1008);
        int_x.add(1004);
        int_x.add(1007);
        int_x.add(1009);
        int_x.add(1276);
        int_x.add(1005);
        int_x.add(1006);
        int_x.add(1275);
        int_x.add(1310);
        int_x.add(2006);
        int_x.add(2005);
        int_x.add(2004);
        int_x.add(2021);
        int_x.add(4422);
        int_x.add(4423);
        int_x.add(4178);
        int_x.add(4363);
        int_x.add(4128);
        int_x.add(112);
        
        return int_x;
    }
    
    public static FinancialDataPoint[] SortDataItems(FinancialDataPoint[] input)
    {
        //generally, the order for the dataItems is determined by GetDataItemList()
        //go through the GetDataItemList int by int
        //pull out the FinancialDataPoint with that dataItemId, put it in a new list
        
        Integer[] order = FinancialData.GetDataItemList();
        
        List<FinancialDataPoint> sorted = new List<FinancialDataPoint>();
        sorted.clear();
        
        for(Integer i : order)
        {
            //pull out the dataItem with that id
            if(i != null)
            {
                for(FinancialDataPoint fdp : input)
                {
                    if(fdp.DataItemId == i)
                    {
                        sorted.add(fdp);
                    }
                }
            }
        }
        
        return sorted;
    }
    
    public static DisplayItem[] SortDisplayItems(DisplayItem[] input)
    {
        if(input == null) {return null;}
        Integer[] ranks = new Integer[input.size()];
        DisplayItem[] output = new DisplayItem[input.size()];
        Integer index = 0;
        for(DisplayItem di : input)
        {
            if(di.SortIndex == null)
            {
                di.SortIndex = 1000 + index;
            }
            ranks[index] = di.SortIndex;
            index++;
        }
        ranks.sort();
        for(DisplayItem di : input)
        {
            index = 0;
            for(Integer rankIndex : ranks)
            {
                if(di.SortIndex == rankIndex)
                {
                    output[index] = di;
                    break;
                }
                index++; 
            }
        }
        return output;
    }
    
    public static FinancialInstanceInfo[] GetTearsheetFinancials(Integer CompanyId, String ASPNetSessionId)
    {
        ArrayOfInt cids = new ArrayOfInt();
        cids.int_x = new Integer[1];
        cids.int_x[0] = CompanyId;
        
        ArrayOfInt dataItemList = new ArrayOfInt();
        dataItemList.int_x = GetDataItemList();
        
        ArrayOfInt periodTypeIDList = new ArrayOfInt();
        periodTypeIDList.int_x = new Integer[1];
        periodTypeIDList.int_x.add(1);
        //periodTypeIDList.int_x.add(7);
        
        DateTime startPeriod = DateTime.newInstance(DateTime.now().Year() - 6, 1,1);
        DateTime endPeriod = DateTime.now();
        
        
        FinancialDataSoap service = new FinancialDataSoap();
        try
        {
            if(ASPNETSessionId != null)
            {
                service.inputHttpHeaders_x = new Map<String,String>();
                service.inputHttpHeaders_x.put('Cookie', ASPNETSessionId);
                service.inputHttpHeaders_x.put('Accept-Encoding', 'gzip, deflate');
                
                FinancialData.ArrayOfCompanyFinancials results = service.GetFinancials(cids, dataItemList, periodTypeIDList, 1, startPeriod, endPeriod, 160, 1);
                if(results != null && results.CompanyFinancials != null && results.CompanyFinancials.size() != 0)
                {
                    return results.CompanyFinancials[0].FinancialInstanceInfoList.FinancialInstanceInfo;    
                }
            }
        }
        catch(Exception e)
        {
            System.debug('@@@ FinancialData.GetTearsheetFinancials() threw: ' + e);
        }
            
        return null;
    }
    
    public class GetFinTemplateDataItemsResponse_element {
        public FinancialData.ArrayOfFinancialDataItem GetFinTemplateDataItemsResult;
        private String[] GetFinTemplateDataItemsResult_type_info = new String[]{'GetFinTemplateDataItemsResult','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfFinancialDataItem','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'GetFinTemplateDataItemsResult'};
    }
    public class ArrayOfInt {
        public Integer[] int_x;
        private String[] int_x_type_info = new String[]{'int','http://www.w3.org/2001/XMLSchema','int','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'int_x'};
    }
    public class ArrayOfFinancialDataItem {
        public FinancialData.FinancialDataItem[] FinancialDataItem;
        private String[] FinancialDataItem_type_info = new String[]{'FinancialDataItem','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','FinancialDataItem','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'FinancialDataItem'};
    }
    public class FinancialInstanceInfo {
        public String FinancialInstanceId;
        public Integer PeriodTypeId;
        public Integer CalendarYear;
        public Integer CalendarQuarter;
        public Integer InstanceTypeId;
        public Integer CurrencyConversionMethod;
        public Integer CurrencyId;
        public Integer ReportedCurrencyId;
        public Integer FiscalYear;
        public Integer FiscalQuarter;
        public DateTime PEODate;
        public DateTime FilingDate;
        public Integer FinancialDataSetId;
        public FinancialData.ArrayOfFinancialDataPoint DataItemList;
        private String[] FinancialInstanceId_type_info = new String[]{'FinancialInstanceId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PeriodTypeId_type_info = new String[]{'PeriodTypeId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] CalendarYear_type_info = new String[]{'CalendarYear','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] CalendarQuarter_type_info = new String[]{'CalendarQuarter','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] InstanceTypeId_type_info = new String[]{'InstanceTypeId','http://www.w3.org/2001/XMLSchema','short','1','1','false'};
        private String[] CurrencyConversionMethod_type_info = new String[]{'CurrencyConversionMethod','http://www.w3.org/2001/XMLSchema','short','1','1','false'};
        private String[] CurrencyId_type_info = new String[]{'CurrencyId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] ReportedCurrencyId_type_info = new String[]{'ReportedCurrencyId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] FiscalYear_type_info = new String[]{'FiscalYear','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] FiscalQuarter_type_info = new String[]{'FiscalQuarter','http://www.w3.org/2001/XMLSchema','short','1','1','false'};
        private String[] PEODate_type_info = new String[]{'PEODate','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] FilingDate_type_info = new String[]{'FilingDate','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] FinancialDataSetId_type_info = new String[]{'FinancialDataSetId','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] DataItemList_type_info = new String[]{'DataItemList','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfFinancialDataPoint','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'FinancialInstanceId','PeriodTypeId','CalendarYear','CalendarQuarter','InstanceTypeId','CurrencyConversionMethod','CurrencyId','ReportedCurrencyId','FiscalYear','FiscalQuarter','PEODate','FilingDate','FinancialDataSetId','DataItemList'};
    }
    public class FinancialDataSoap 
    {
        public FinancialDataSoap()
        {
            CapitalIQOrganization__c myOrg = [Select org.Username__c, org.Password__c, org.WebServiceUrl__c
                    From CapitalIQOrganization__c org LIMIT 1];
            endpoint_x =  myOrg.WebServiceUrl__c + '/ciqdotnet/api/2.0/financialdata.asmx';
        }
        public String endpoint_x;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData', 'FinancialData'};
        public FinancialData.ArrayOfCompanyFinancials GetFinancials(FinancialData.ArrayOfInt companyIdList,FinancialData.ArrayOfInt dataItemList,FinancialData.ArrayOfInt periodTypeIDList,Integer restatementTypeID,DateTime startPeriodDate,DateTime endPeriodDate,Integer currencyID,Integer currencyConversionMethod) {
            FinancialData.GetFinancials_element request_x = new FinancialData.GetFinancials_element();
            FinancialData.GetFinancialsResponse_element response_x;
            request_x.companyIdList = companyIdList;
            request_x.dataItemList = dataItemList;
            request_x.periodTypeIDList = periodTypeIDList;
            request_x.restatementTypeID = restatementTypeID;
            request_x.startPeriodDate = startPeriodDate;
            request_x.endPeriodDate = endPeriodDate;
            request_x.currencyID = currencyID;
            request_x.currencyConversionMethod = currencyConversionMethod;
            Map<String, FinancialData.GetFinancialsResponse_element> response_map_x = new Map<String, FinancialData.GetFinancialsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData/GetFinancials',
              'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData',
              'GetFinancials',
              'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData',
              'GetFinancialsResponse',
              'FinancialData.GetFinancialsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetFinancialsResult;
        }
        public FinancialData.ArrayOfFinancialDataItem GetFinTemplateDataItems(Integer templateTypeID) {
            FinancialData.GetFinTemplateDataItems_element request_x = new FinancialData.GetFinTemplateDataItems_element();
            FinancialData.GetFinTemplateDataItemsResponse_element response_x;
            request_x.templateTypeID = templateTypeID;
            Map<String, FinancialData.GetFinTemplateDataItemsResponse_element> response_map_x = new Map<String, FinancialData.GetFinTemplateDataItemsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData/GetFinTemplateDataItems',
              'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData',
              'GetFinTemplateDataItems',
              'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData',
              'GetFinTemplateDataItemsResponse',
              'FinancialData.GetFinTemplateDataItemsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetFinTemplateDataItemsResult;
        }
    }
    public class FinancialDataItem {
        public Integer DataItemId;
        public String DataItemName;
        private String[] DataItemId_type_info = new String[]{'DataItemId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] DataItemName_type_info = new String[]{'DataItemName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'DataItemId','DataItemName'};
    }
    public class CompanyFinancials {
        public Integer CompanyId;
        public Integer FinancialGroupId;
        public Integer TemplateTypeId;
        public FinancialData.ArrayOfFinancialInstanceInfo FinancialInstanceInfoList;
        private String[] CompanyId_type_info = new String[]{'CompanyId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] FinancialGroupId_type_info = new String[]{'FinancialGroupId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] TemplateTypeId_type_info = new String[]{'TemplateTypeId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] FinancialInstanceInfoList_type_info = new String[]{'FinancialInstanceInfoList','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfFinancialInstanceInfo','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'CompanyId','FinancialGroupId','TemplateTypeId','FinancialInstanceInfoList'};
    }
    public class GetFinTemplateDataItems_element {
        public Integer templateTypeID;
        private String[] templateTypeID_type_info = new String[]{'templateTypeID','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'templateTypeID'};
    }
    public class GetFinancials_element {
        public FinancialData.ArrayOfInt companyIdList;
        public FinancialData.ArrayOfInt dataItemList;
        public FinancialData.ArrayOfInt periodTypeIDList;
        public Integer restatementTypeID;
        public DateTime startPeriodDate;
        public DateTime endPeriodDate;
        public Integer currencyID;
        public Integer currencyConversionMethod;
        private String[] companyIdList_type_info = new String[]{'companyIdList','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfInt','0','1','false'};
        private String[] dataItemList_type_info = new String[]{'dataItemList','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfInt','0','1','false'};
        private String[] periodTypeIDList_type_info = new String[]{'periodTypeIDList','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfInt','0','1','false'};
        private String[] restatementTypeID_type_info = new String[]{'restatementTypeID','http://www.w3.org/2001/XMLSchema','short','1','1','false'};
        private String[] startPeriodDate_type_info = new String[]{'startPeriodDate','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] endPeriodDate_type_info = new String[]{'endPeriodDate','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] currencyID_type_info = new String[]{'currencyID','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] currencyConversionMethod_type_info = new String[]{'currencyConversionMethod','http://www.w3.org/2001/XMLSchema','short','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'companyIdList','dataItemList','periodTypeIDList','restatementTypeID','startPeriodDate','endPeriodDate','currencyID','currencyConversionMethod'};
    }
    public class ArrayOfCompanyFinancials {
        public FinancialData.CompanyFinancials[] CompanyFinancials;
        private String[] CompanyFinancials_type_info = new String[]{'CompanyFinancials','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','CompanyFinancials','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'CompanyFinancials'};
    }
    public class GetFinancialsResponse_element {
        public FinancialData.ArrayOfCompanyFinancials GetFinancialsResult;
        private String[] GetFinancialsResult_type_info = new String[]{'GetFinancialsResult','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','ArrayOfCompanyFinancials','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'GetFinancialsResult'};
    }
    public class ArrayOfFinancialDataPoint {
        public FinancialData.FinancialDataPoint[] FinancialDataPoint;
        private String[] FinancialDataPoint_type_info = new String[]{'FinancialDataPoint','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','FinancialDataPoint','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'FinancialDataPoint'};
    }
    public class ArrayOfFinancialInstanceInfo {
        public FinancialData.FinancialInstanceInfo[] FinancialInstanceInfo;
        private String[] FinancialInstanceInfo_type_info = new String[]{'FinancialInstanceInfo','https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','FinancialInstanceInfo','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'FinancialInstanceInfo'};
    }
    public class FinancialDataPoint {
        public String DataItemValue;
        public Integer ScaleId;
        public Integer UnitTypeId; 
        public Integer DataItemId;
        public Boolean AuditableFlag;
        public Boolean Subtotal;
        public Integer Order;
        public Integer FinancialDataSetId;
        private String[] DataItemValue_type_info = new String[]{'DataItemValue','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ScaleId_type_info = new String[]{'ScaleId','http://www.w3.org/2001/XMLSchema','short','1','1','true'};
        private String[] UnitTypeId_type_info = new String[]{'UnitTypeId','http://www.w3.org/2001/XMLSchema','short','1','1','false'};
        private String[] DataItemId_type_info = new String[]{'DataItemId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] AuditableFlag_type_info = new String[]{'AuditableFlag','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] Subtotal_type_info = new String[]{'Subtotal','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] Order_type_info = new String[]{'Order','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] FinancialDataSetId_type_info = new String[]{'FinancialDataSetId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.capitaliq.com/CIQDotNet/Financials/FinancialData','true','false'};
        private String[] field_order_type_info = new String[]{'DataItemValue','ScaleId','UnitTypeId','DataItemId','AuditableFlag','Subtotal','Order','FinancialDataSetId'};
    }
}