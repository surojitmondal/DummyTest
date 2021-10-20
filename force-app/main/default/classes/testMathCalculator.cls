@isTest
public class testMathCalculator {
    //public decimal a = 10;
    //public decimal b = 12;
    
    Static testMethod void testAdd(){
        mathCalculator mc = new mathCalculator();
        mc.add(2 , 3);
        System.assertEquals(5, mc.add(2 , 3));
    }
    Static testMethod void testminus(){
        mathCalculator mc = new mathCalculator();
        mc.minus(15,4);
        System.assertEquals(11, mc.minus(15,4));
    }
    Static testMethod Void testMulti(){
        mathCalculator mc = new mathCalculator();
        mc.multi(4,5);
    }
}