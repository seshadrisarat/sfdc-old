public class StringUtils {

	// Checks if two strings are equal (case insensitive).
	// str1			str2		result
	// null			null		true
	// null			''			true
	// ''			null		true
	// ''			''			true
	// 'a'			'A'			false
	// 'A'			'A'			true
	public static boolean isEqual(string str1, string str2) {
		if ((str1 == null && str2 == null) || (String.isEmpty(str1) && String.isEmpty(str2))) {
			return true;
		}
		else if ((String.isEmpty(str1) && !String.isEmpty(str2)) || (String.isEmpty(str2) && !String.isEmpty(str1))) {
			return false;	
		}
		else {
			return str1.equals(str2);
		}
	}
	
	public static boolean isNotEqual(string str1, string str2) {
		return !isEqual(str1, str2);
	}
	
	public static boolean isEqualIgnoreCase(string str1, string str2) {
		if ((str1 == null && str2 == null) || (String.isEmpty(str1) && String.isEmpty(str2))) {
			return true;
		}
		else if ((String.isEmpty(str1) && !String.isEmpty(str2)) || (String.isEmpty(str2) && !String.isEmpty(str1))) {
			return false;	
		}
		else {
			return str1.equalsIgnoreCase(str2);
		}	
	}
	
	public static boolean isNotEqualIgnoreCase(string str1, string str2) {
		return !isEqualIgnoreCase(str1, str2);
	}
}