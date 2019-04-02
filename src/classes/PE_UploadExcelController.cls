/* @author : Dev_Innovation
* Date : 19 June 17
* Description : Controller for excel file upload
*/

public class PE_UploadExcelController {
    
    //Final variable
    private static final Integer NUMBEROFCOLUMNS = 13;
    private static final String EXTENSIONS = 'csv';
    
    // Global variables
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    Set<DEV_Innovation__Projects__c> projectSet = new Set<DEV_Innovation__Projects__c>();
    Set<DEV_Innovation__Requirement_Details__c> reqDetailSet = new Set<DEV_Innovation__Requirement_Details__c>();
    
    //public Schedule__C objSchedule{get;set;}
    
    //String array for taking csv data by line.
    public String[] filelines = new String[]{};
        
    //string array for taking csv columns.
    public String[] fileColumns = new String[]{};
    
    //set for storing all id's from csv.
    set<String> projtoupload{get;set;}
    set<String> reqDetailtoupload;
    
    //map for storing data from csv.
    public map<String,String> mapOppIDMonthYearToAccAmount{get;set;}
    public map<String, List<String>> mapUnmatchedSchedules{get;set;}  
    
       
       //Main constructor
    public PE_UploadExcelController()
    {
        //Initalizing required objects.
        //objSchedule = new Schedule__c();
        projtoupload = new set<String>();
        mapOppIDMonthYearToAccAmount = new map<String,String>();
        mapUnmatchedSchedules  = new map<String, List<String>>();
    }
    //Method to read file content and check extension and file format.
    public Pagereference ReadFile()
    {
        try{
            //If without selecting csv file you clicked on upload it will give error message.
            if(nameFile == null)
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'You should select csv file to upload');
                ApexPages.addMessage(errormsg);
                return null;
            }
            
            //Taking file extension.
            String extension = nameFile.substring(nameFile.lastIndexOf('.')+1);
            
            //Checking if file extension is .csv.
            if(extension.equalsIgnoreCase(EXTENSIONS))
            {
                nameFile=contentFile.toString();
                //Spliting by new line
                filelines = nameFile.split('\n');
                System.debug('filelines  == '+filelines.size());
                
                //Spliting values by (,) for checking coloumn size
                fileColumns = filelines[0].split(',');
                System.debug('fileColumns  == '+fileColumns.size());
                
                //If column size is 5 then only it will proceed.
                if(fileColumns.size() == NUMBEROFCOLUMNS)
                {
                    
                    for (Integer i=1; i<filelines.size(); i++)
                    {
                        String[] inputvalues = new String[]{};
                        inputvalues = filelines[i].split(',');
                        //projtoupload.add(inputvalues[0]);
                        for(integer j = 0; j < inputvalues.size() ; j++){
                            
                           
                            DEV_Innovation__Projects__c prObj = new DEV_Innovation__Projects__c();                        
                            if(fileColumns[j] == 'Project Name'){
                                prObj.put('name', inputvalues[j]);
                                continue;
                            }                  
                               
                            if(j < 6){
                                if(fileColumns[j] == 'DEV_Innovation__Start_Date__c'){                               
                                    prObj.put(fileColumns[j], Date.parse(inputvalues[j]));
                                    continue;
                                }
                                if(fileColumns[j] == 'DEV_Innovation__End_Date__c'){                               
                                    prObj.put(fileColumns[j], Date.parse(inputvalues[j]));
                                    continue;
                                }
                                prObj.put(fileColumns[j], inputvalues[j]);                            
                                projectSet.add(prObj);
                            }else{
                                DEV_Innovation__Requirement_Details__c reqobj = new DEV_Innovation__Requirement_Details__c();
                                if(fileColumns[j] == 'Requirement Details Name'){
                                    reqobj.put('name', inputvalues[j]);
                                    continue;
                                }
                                
                                if(fileColumns[j] == 'DEV_Innovation__Number_of_Items__c'){                               
                                    reqobj.put(fileColumns[j], Integer.valueof(inputvalues[j]));
                                    continue;
                                }
                                
                               if(fileColumns[j].contains('Effort')){   
                                   System.debug('fileColumns[j]  == '+fileColumns[j]);
                                   reqobj.put('DEV_Innovation__Effort__c', Integer.valueof(inputvalues[j]));
                                   continue;
                                }
                                
                                reqobj.put(fileColumns[j], inputvalues[j]);
                                reqDetailSet.add(reqobj);
                            }
                        }
                       
                    }               
                    
                    if(projectSet.Size()>0)
                    {	
                        
                            insert new List<DEV_Innovation__Projects__c>(projectSet);
                        
                    }
                    
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.info,'File uploaded successfully');
                    ApexPages.addMessage(errormsg);
                   
                    return null;
                }
                else
                {
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'There should be 13 columns in csv file');
                    ApexPages.addMessage(errormsg);
                    return null;
                }
                return null;
            }
            //If file is not csv type then it will give error message.
            else
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'File type should be csv type');
                ApexPages.addMessage(errormsg);
                return null;
            }
        }catch(Exception e){
			ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.error, e.getMessage() + ' -- '+e.getStackTraceString());
			ApexPages.addMessage(errormsg);
			return null;
		}
		
	}
    

}