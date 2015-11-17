public class ComboLookupResult
{

public static testMethod void testMe(	)
      {
      ComboLookupResult x = new ComboLookupResult();
      x.RowNumber = 1;
      integer x2 = x.RowNumber;
      x.Id = 'abc';
      string s2 = x.Id;
      s2 = x.DisplayText;
      x.DisplayText = s2;
      }

public integer RowNumber { get; set; }
public string Id { get; set; }
public string DisplayText { get; set; }
}