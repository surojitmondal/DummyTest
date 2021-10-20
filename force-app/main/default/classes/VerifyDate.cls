public class VerifyDate {
    //method to handle potential checks against two dates
	public static Date CheckDates(Date date1, Date date2) {
		//if date2 is within the next 30 days of date1, use date2.  Otherwise use the end of the month
		if(DateWithin30Days(date1,date2)) {
			return date2;
		} else {
			return SetEndOfMonthDate(date1);
		}
	}
    //method to check if date2 is with in 30 days of date1
    private static Boolean dateWithin30Days(Date d1, Date d2){
        if(d2 < d1)
            return false;
        Date date30Days = d1.addDays(30);
        if(d2 >= date30Days){
            return false;
        }
        else{
            return true;
        }
    }
        
        //method to return end of month of a given date
        public static Date setEndofMonthDate(Date d1){
            Integer totalDays = Date.daysInMonth(d1.year(), d1.month());
            Date lastDay = Date.newInstance(d1.year(),d1.month(), totalDays);
            return lastDay;
            
        }    

}