public class PieChartDealsWithESGController {
	public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        Integer dealcount = [SELECT COUNT() FROM Deal__c Where Status__c='Portfolio'];
        data.add(new PieWedgeData('Portfolio Companies (' + dealcount + ')', dealcount));
        data.add(new PieWedgeData('Deals With Green IT (2)', 2));
        /*
        data.add(new PieWedgeData('Jan', 30));
        data.add(new PieWedgeData('Feb', 15));
        data.add(new PieWedgeData('Mar', 10));
        data.add(new PieWedgeData('Apr', 20));
        data.add(new PieWedgeData('May', 20));
        data.add(new PieWedgeData('Jun', 5));
		*/        
		return data;
    }

    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
}