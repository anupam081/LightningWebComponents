/*
Description: Class to hold all the constant variable used across the application
                                        
    Owner:  Certification Candidate (207295)
    Associated APEX class: none
    Dependencies: none 
    Change History: 
    Date           Person                                   Responsible Details 
    20/02/2016     Certification Candidate (207295)         Created
*/

public class SmartInvestorConstants {
	    
	    //TRIGGER CONSTANTS DECLARATION
        public static final String TRANSACTIONTYPE_BUY = 'BUY';
        public static final String TRANSACTIONTYPE_SELL = 'SELL';
        public static final String TRANSACTIONTYPE_DEPOSIT = 'DEPOSIT';
        public static final String TRANSACTIONTYPE_WITHDRAW = 'WITHDRAW';
        public static final String TRANSACTIONTYPE_REBALANCE = 'REBALANCE';
        
        //VF EXTENSIION CONSTANT DECLARATION		
        public static final String HOMEPAGEURL = '/apex/investmentAccountViewPage?id=';
        public static final integer pageSize = 5;
        public static final String PROFILENAME = 'System Administrator';
}