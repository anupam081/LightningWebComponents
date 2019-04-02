/* @author : Dev_Innovation
 * Date : 24 May 17
 * Description : Util Class for Trigger PE_ReqDetailTrigger
*/

public class PE_ReqDetailTriggerUtil {
	
    /*@Param : List of requirement detail object
     * @return : void
     * @Description : Calculate the effort for each requirement subtype
     * @author : Dev_Innovation
     * @Date : 24 May 17
    */
    public void calculateEfforts(List<DEV_Innovation__Requirement_Details__c> newRDList){
        
        // fetch base line estimates
        Map<String, Integer> baseLineEstimateMap = PE_Utils.fetchBaselineEstimates();
        
        //iterate through list of requirement details and set the correct effort based on the complexity
        if(newRDList != null && newRDList.size() > 0 && baseLineEstimateMap != null){
            for(DEV_Innovation__Requirement_Details__c rd : newRDList){
                if(baseLineEstimateMap.containsKey(rd.DEV_Innovation__SubType__c)){
                	rd.DEV_Innovation__Effort__c = Integer.valueof(rd.DEV_Innovation__Number_of_Items__c) * Integer.valueof(rd.DEV_Innovation__Complexity__c) * baseLineEstimateMap.get(rd.DEV_Innovation__SubType__c);
                }else{
                    rd.DEV_Innovation__Effort__c = Integer.valueof(rd.DEV_Innovation__Number_of_Items__c) * Integer.valueof(rd.DEV_Innovation__Complexity__c);
                }
            }
        }
        
    }
}