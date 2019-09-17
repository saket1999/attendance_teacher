
String timeConverter(String time) {
	String ans = time.substring(time.indexOf("(")+1, time.indexOf(")"));
	return ans;
}