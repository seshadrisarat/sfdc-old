/*
*	MapSearch_Helper contains helper methods and functions for the Map Search controller.
*
*	Author: Wilson Ng
*	Date:   October 18, 2012
*
*/
public with sharing class MapSearch_Helper {

	// Calculates whether location point is located inside specific poligon (area)
	//    poligon = Coordinates of each point in polyline
	//    point = Location point
	public static boolean PoligonContains(Coordinates[] poligon, Coordinates point)
	{
		boolean isIn = false;
		integer i, j = 0;
		integer mycount = poligon.Size();
		for (i = 0, j = mycount - 1; i < mycount; j = i++)
		{
			if ((((poligon[i].Y <= point.Y) && (point.Y < poligon[j].Y))
				|| ((poligon[j].Y <= point.Y) && (point.Y < poligon[i].Y)))
				&& (point.X < (poligon[j].X - poligon[i].X) * (point.Y - poligon[i].Y) / (poligon[j].Y - poligon[i].Y) + poligon[i].X))
			{
				isIn = !isIn;
			}
		}
		return isIn;
	}

	// Calculates whether location point is located inside specific poligon (area)
	public static boolean PoligonContains(string poligon, string point)
	{
		return PoligonContains(ParseToPoligon(poligon, ';', ','), ParseToPoint(point, ','));
	}
	
	// Parses array in points in a string to list of coordinates
	public static list<Coordinates> GetPointsFromString(string poins, string pointsDelimiter, string coordinatesDelimiter)
	{
		return ParseToPoligon(poins, pointsDelimiter, coordinatesDelimiter);
	}

	// Find max and min Lat(y) and Long(x) coordinates
	// return[0] = minLat, minLong
	// return[1] = maxLat, maxLong
	public static list<Coordinates> SetMaxMinPoints(Coordinates[] coordinates)
	{
		Coordinates min = new Coordinates(coordinates[0]);
		Coordinates max = new Coordinates(coordinates[0]);

		for (Coordinates item : coordinates)
		{
			if (item.X > max.X)
				max.X = item.X;
			if (item.Y > max.Y)
				max.Y = item.Y;

			if (item.X < min.X)
				min.X = item.X;
			if (item.Y < min.Y)
				min.Y = item.Y;
		}
			
		return new list<Coordinates> { min, max };
	}
	
	// Parses array in points in a string to list of coordinates
	public static List<Coordinates> ParseToPoligon(string obj, string pointsDelimeter, string coordinatesDelimeter)
	{
		if (IsNullOrEmpty(obj))
			return null;

		list<Coordinates> result = new List<Coordinates>();
		list<string> points = obj.Split(pointsDelimeter);
		for (string point : points)
		{
			Coordinates coordinate = ParseToPoint(point, coordinatesDelimeter);
			if (coordinate != null)
				result.Add(coordinate);
		}
		return result;
	}

	// Parses 1 coordinate point from string
	public static Coordinates ParseToPoint(string obj, string coordinatesDelimeter)
	{
		if (IsNullOrEmpty(obj))
			return null;

		list<string> nums = obj.Split(coordinatesDelimeter);
		return new Coordinates( double.valueOf(nums[0]), double.valueOf(nums[1]) );
	}
	
	public static boolean IsNullOrEmpty(string str) {
		return (str == null || str == '');
	}

	//
	// Coordinates class for X (Lat) and Y (Long)
	public class Coordinates {
		public double X {get;set;}		// lat
		public double Y {get;set;}		// long
		public Coordinates() { }
		public Coordinates(Coordinates coordinates) {
			this.X = coordinates.X;
			this.Y = coordinates.Y;
		}
		public Coordinates(double x, double y) {
			this.X = x;
			this.Y = y;
		}
		public boolean equals(Coordinates coord1) {
			return (coord1!=null && coord1.X==this.X && coord1.Y==this.Y);
		}
	}
	
	//
	// Location/neighborhood class
	public class Location {
		public string Value {get;set;}
		public string Oid {get;set;}
		public Location(string value) {
			this.Value = value;
			this.Oid = value;
		}
	}
	
	//
	// Profile Info class for map search results per property (or profile)
	public class ProfileInfo {
		public string Oid {get;set;}		// SF id of the Name
		public string Street {get;set;}
		public string Photo {get;set;}
		public string Status {get;set;}		// or expiration date
		public string Name {get;set;}
		public double Latitude {get;set;}
		public double Longitude {get;set;} 
		public decimal SizeFilter {get;set;}
		public decimal SizeTotal {get;set;}
		public decimal AnnualRent {get;set;}
		public ProfileInfo() { }
	}
	
	//
	// test methods
	@isTest
	static void testThisClass() {
		
		Test.startTest();
		string rect = '40,-70; 41,-70; 41,-69; 40,-69';
		boolean res = PoligonContains(rect, '40.5, -69.5');		// test inside
		system.assertEquals(true, res, 'Error: PoligonContains method inside polygon failed.');
		res = PoligonContains(rect, '42, -69.5');				// test outside
		system.assertEquals(false, res, 'Error: PoligonContains method outside polygon failed.');
	
		list<Coordinates> coords = GetPointsFromString(rect, ';', ',');
		system.assertEquals(4, coords.size(), 'Error: GetPointsFromString method did not parse correct number of coordinates.');
	
		list<Coordinates> minMaxCoords = SetMaxMinPoints(coords);
		system.assert((new Coordinates(40, -70)).equals(minMaxCoords[0]), 'Error: SetMaxMinPoints method did not return correct min coordinates.');
		system.assert((new Coordinates(41, -69)).equals(minMaxCoords[1]), 'Error: SetMaxMinPoints method did not return correct max coordinates.');
	
		Test.stopTest();
	}
	
	@isTest
	static void testThisClass_innerClasses() {
		
		Test.startTest();
		
		// Coordinates class
		Coordinates coord1 = new Coordinates();
		coord1.X = 1;	coord1.Y = 2;
		Coordinates coord2 = new Coordinates(2, 3);
		Coordinates coord3 = new Coordinates(coord1);
		system.assert(!coord1.equals(coord2), 'Error: Coordinates equals method test1 failed.');
		system.assert(coord1.equals(coord3), 'Error: Coordinates equals method test1 failed.');
		
		// Location/neighborhood class
		Location loc1 = new Location('teststr');
		loc1.Value = 'test';	loc1.Oid = 'str';
		
		// Profile Info class
		ProfileInfo pinfo = new ProfileInfo();
		pinfo.Oid = 'testoid';		pinfo.Street = 'teststreet';
		pinfo.Photo = 'testphoto';	pinfo.Status = 'teststatus';
		pinfo.Name = 'testname';	pinfo.Latitude = 1;
		pinfo.Longitude = 2;		pinfo.SizeFilter = 3;
		pinfo.SizeTotal = 4;		pinfo.AnnualRent = 5;
		
		Test.stopTest();
	}
}