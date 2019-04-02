/* @author : Dev_Innovation
* Date : 24 May 17
* Description : Util Class for App Project Estimation
*/

public class PE_Utils {
    
    /*@Param : None
* @return : Map<String, Integer>
* @Description : Return the Map of Name & effort from custom metadata type
* @author : Dev_Innovation
* @Date : 24 May 17
*/
    public static Map<String, Integer> fetchBaselineEstimates(){
        
        Map<String, Integer> baseLineEstimateMap = new Map<String, Integer>();
        
        for(DEV_Innovation__Estimation_Baseline__mdt ble : [select id, MasterLabel, DeveloperName, DEV_Innovation__Estimates__c
                                                            from DEV_Innovation__Estimation_Baseline__mdt]){
                  baseLineEstimateMap.put(ble.DeveloperName, Integer.valueof(ble.DEV_Innovation__Estimates__c));                                                  
        }
        
        return baseLineEstimateMap; 
        
    }
}