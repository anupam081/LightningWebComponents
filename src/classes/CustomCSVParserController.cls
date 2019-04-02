/*Description     :    Custom CSV file parser controller.*/
public class CustomCSVParserController {           
    
    //List to hold the options
    public List<SelectOption> options {get;set;}
    public string selectedValue {get; set;}
    
    //DML Operations
    string dmlOpps = null;
    
    //Boolean to load the rest of rhe page when operation is selected
    boolean IsChecked=false;
    
    
    public boolean getIsChecked(){
        return IsChecked;
    } 
    
    //method to check the RadioButton is checked
    public void onclickaction(){
        if(dmlOpps != '' && dmlOpps != null)
            IsChecked = true;
        else
            IsChecked = false;
    }
    
    //choose value
    public List<SelectOption> getOperations() {
        
        //Initiallizing
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('insert','INSERT')); 
        options.add(new SelectOption('upsert','UPSERT')); 
        options.add(new SelectOption('delete','DELETE')); 
        return options;     
    }
    
    public String getdmlOpps() {
        return dmlOpps ;
    }
    
    public void setdmlOpps (String dmlOpps ){
        this.dmlOpps = dmlOpps ;
    }
    
    //Boolean to load the upload page 
    boolean IsSelected = false;
    public boolean getIsSelected(){
        return IsSelected;
    }
   
    //Method to check the Sobject is selected or not
    public void OnSelectAction(){
        if( selectedValue != null && selectedValue != '' )
            IsSelected = true;
        else
            IsSelected = false;
    } 
    
    //Calling constructor   
    public CustomCSVParserController() {                                                                                                     
        
        //memory allocation and default value assignment
        options = new List<SelectOption>();
        options.add(new SelectOption('','Select one'));                                                                 
        
        //Loop through sObject list
        for(Schema.SObjectType sobj : Schema.getGlobalDescribe().Values()) {
            schema.DescribeSObjectResult f = sobj.getDescribe();
            
            //filtering the sobject list 
            if(f.isCreateable() && f.isDeletable() && f.isQueryable() && f.isUpdateable() && f.isAccessible() && f.isUndeletable()){
                
                //populate list with options
                options.add(new SelectOption(f.getName(),f.getLabel()));
            }
        } 
        
        //sorting the list alphabetially   
        options.sort();
    }
    
    //Destination of the cancel Button 
    public PageReference cancel(){
        
        PageReference  pr = new PageReference('/home/home.jsp');
        return pr;
    }                                                                         
    
    //================here starts page 3=====================================================================================
    
    //Defining list, sets and string
    public blob BlobFile{get;set;}
    public string RecordsInTheFile {get;set;}
    public list<Schema.Sobjectfield> sObjectFieldsList {get; set;}
    public set<string> FieldNames{get;set;}
    
    //transient used to limit the page size
    transient list<string> headersList{get;set;}
    transient set<Integer> headersContainedList{get;set;}
    transient list<list<string>> csvRows{get;set;}
    transient String[] ListOfRecordsOnly {get; set;}
    transient String[] ListOfRecordsWithId {get; set;} 
    transient map<string, object> fieldswithDataType;
    
    //Method                                                                             
    public void processingFile(){
        
        //Initiallizing
        FieldNames = new set<string>();
        headersList = new list<string>();
        headersContainedList = new set<Integer>();
        ListOfRecordsOnly = new String[]{};
        csvRows = new list<list<String>>();
        ListOfRecordsWithId = new String[]{};
            sObject dynObject;
        string firsTRecordIds = '';                   
        fieldswithDataType = new map<string, object>();
        
        //Sobject which is selected     
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.DescribeSObjectResult r = gd.get(selectedValue).getDescribe(); 
        
        //get name of Sobject
        String tempName = r.getName(); 
        
        //get first 3 digits of the Id
        String tempPrefix = r.getKeyPrefix(); 
        
        //initiallizing
        list<list<Sobject>> listOfListOfSobject = new list<list<Sobject>>();
        list<sObject> dynsObjectList = new list<sObject>();   
        list<object> datatypeOfField = new list<object>();                   
        
        //Fields of sobject
        sObjectFieldsList = Schema.getGlobalDescribe().get(selectedValue).getDescribe().fields.getMap().values();
        
        //Loop over fields list
        for(Schema.Sobjectfield schemaField : sObjectFieldsList) {
            Schema.Describefieldresult FieldResult = schemaField.getDescribe();
            
            //Check if the is updatable or creatable
            if( FieldResult.isUpdateable() && FieldResult.isCreateable()) {
                
                //Populated list with fields label
                FieldNames.add(FieldResult.getName().toLowerCase());
                
                //map of field with corresponding data type values
                fieldswithDataType.put(FieldResult.getName().toLowerCase(), FieldResult.getType());
            }               
        }       
        
        //Check if the no file is selected
        if(blobFile == null){
            
            //Error Message
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.FATAL,'Kindly Choose your File');
            ApexPages.addMessage(errormsg);
            return;
        }
        
        //file processing
        RecordsInTheFile = BlobFile.tostring();//taking blob file to a string
        headersList = RecordsInTheFile.split('\r\n');//splitting at new line
        
        //list of headers (field Names) only
        headersList = headersList[0].split(',');   
        
        //here defining the records which are having valid headers And removing Id columns and unkwon fields
        integer index = 0;
        
        for(string headerstring : headersList){
            
            //Getting index(List of integers) values of the unknown fields in the csv file                 
            if(!fieldswithDataType.containskey(headerstring.toLowerCase())){                               
                headersContainedList.add(index);
            }
            
            index++;
        }
        
        //list for Indexes with Id also
        set<Integer> IdContainedIndex = new set<Integer>();
        
        //here adding Id column but removing other unkwon fields
        integer WithId = 0;
        
        for(string head : headersList){
            
            //Getting index(List of integers) values of the unknown fields in the csv file
            if(!fieldswithDataType.containskey(head.toLowerCase())){ 
                IdContainedIndex.add(WithId);
                for(integer d=0; d<headersList.size(); d++){
                    if(headersList[d]== 'Id'){
                        IdContainedIndex.remove(d);
                    }
                }
            }
            WithId++;
        }
        
        list<object> MyHeaderMap = new  list<object>();
        
        //get the fields datatype which are in file
        for(string head : headersList){
            
            object mapofFile = fieldswithDataType.get(head.toLowerCase());
            
            //list of object contains data type of fields in the file
            MyHeaderMap.add(mapofFile);                 
        }
        
        //get the CSV lines
        for(String row : RecordsInTheFile.split('\r\n')) {
            
            //add row
            csvRows.add(row.split(',')); 
        }
        
        //Checking for values 
        for(integer j=1; j<csvRows.size(); j++ ){                                                                 
            
            //Record on the rows of this  string
            ListOfRecordsOnly = csvRows.get(j);
            
            //Creating a new sObject dynamically
            dynObject = Schema.getGlobalDescribe().get(selectedValue).newSObject();
            
            for(integer i=0; i<ListOfRecordsOnly.size(); i++){
                
                //Check the index is matching with index of unknownHeaders 
                if(!headersContainedList.contains(i)){ 
                    
                    Object s = null;
                    
                    try {       
                        
                        //processing the datatype of the record and the field
                        if (MyHeaderMap[i]==DisplayType.Double||MyHeaderMap[i]==DisplayType.Currency || MyHeaderMap[i]==DisplayType.Percent){
                            s = decimal.valueOf((String)ListOfRecordsOnly[i]); 
                            
                        } else if (MyHeaderMap[i]==DisplayType.Boolean){                 
                            if (ListOfRecordsOnly[i]=='true'){
                                s = true;               
                            }else if (ListOfRecordsOnly[i]=='false'){
                                s = false;             
                            }else {
                                s = Boolean.valueOf(ListOfRecordsOnly[i]);
                            }
                            
                        } else if (MyHeaderMap[i]==DisplayType.Integer) {
                            s = Integer.valueOf(ListOfRecordsOnly[i]);
                        } else if (MyHeaderMap[i]==DisplayType.Date) {
                            s = Date.valueOf(ListOfRecordsOnly[i]);
                        } else if (MyHeaderMap[i]==DisplayType.DateTime) {                                     
                            s = DateTime.valueOf(ListOfRecordsOnly[i]);
                        } else if (MyHeaderMap[i]==DisplayType.REFERENCE) {
                            id idList = Id.valueOf(ListOfRecordsOnly[i]);
                            s = idList; 
                        } else if ((MyHeaderMap[i]==DisplayType.PickList || MyHeaderMap[i]==DisplayType.PickList) && MyHeaderMap[i]==null) {
                            s = '';
                        }else{ 
                            s = ListOfRecordsOnly[i];
                        }           
                        
                    }catch (System.TypeException e){
                        continue;                                     
                    } 
                    
                    //Put value according with the index in the Sobject variable
                    dynObject.put(headersList[i], s); 
                } 
            }
            
            //adding values in the list of object
            dynsObjectList.add(dynObject);
            listOfListOfSobject.add(dynsObjectList); 
        }             
        
        //Insert=================================================Insert================================================
        
        if(dmlOpps == 'insert'){
            try
            {
                System.debug('dynsObjectList == '+dynsObjectList);
                insert dynsObjectList;
                /*
                Database.SaveResult[] result = Database.insert(dynsObjectList , false);
                for(Database.SaveResult sr : result){
                    System.debug(sr.isSuccess());
                }
				*/
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,'Record Successfully Created');
                ApexPages.addMessage(errormsg);
            }
            
            catch (Exception e)
            {
                
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later' + e.getMessage());
                ApexPages.addMessage(errormsg);
                return;
            }   
        }                                     
        
        //list of the Records with corresponding Id's
        list<string> FieldValueWithId = new list<string>();
        sObject ObjectWithIdRecords;//sObject
        list<Sobject> SobjectForUpdate = new list<Sobject>();//List of records
        
        //========================================================upsert===========================================
        
        //Here's is upsert method
        if(dmlOpps == 'upsert'){
            
            //Limiting the loop
            for(Integer k=0; k<headersList.size(); k++ ){
                
                //Check if the Id Column is there
                if(headersList[k]== 'Id')
                    
                    //Loop for the size of the string
                    for(Integer h=1; h<csvRows.size(); h++){
                        
                        //Assigning the value of csvrows to list
                        ListOfRecordsWithId = csvRows.get(h);
                        
                        firsTRecordIds = '';
                        integer b = 0;
                        
                        //List of Id's in the record
                        FieldValueWithId = ListOfRecordsWithId[b].split(',');
                        
                        for(string fvw : FieldValueWithId){
                            firsTRecordIds += fvw.subString(0, 3); 
                        }                                                             
                        
                        b++;
                        
                        //Defining a dynamic object
                        ObjectWithIdRecords = Schema.getGlobalDescribe().get(selectedValue).newSObject();
                        
                        //putting value of field according to the field index
                        for(Integer y=0; y<ListOfRecordsWithId.size(); y++){ 
                            
                            //Check weather is provided or not
                            if(!IdContainedIndex.contains(y)){ 
                                
                                //check if the first 3 digits of Id are same or not
                                if(firsTRecordIds == tempPrefix ){
                                    
                                    //sobject
                                    Object s = null;
                                    
                                    try {       
                                        
                                        //processing the datatype of the record and the field
                                        if (MyHeaderMap[y]==DisplayType.Double||MyHeaderMap[y]==DisplayType.Currency || MyHeaderMap[y]==DisplayType.Percent){
                                            s = decimal.valueOf((String)ListOfRecordsOnly[y]); 
                                        } else if (MyHeaderMap[y]==DisplayType.Boolean){                 
                                            
                                            if (ListOfRecordsOnly[y]=='true'){
                                                s = true;               
                                            }else if (ListOfRecordsOnly[y]=='false'){
                                                s = false;             
                                            }else {
                                                s = Boolean.valueOf(ListOfRecordsOnly[y]);
                                            }
                                            
                                        } else if (MyHeaderMap[y]==DisplayType.Integer) {
                                            s = Integer.valueOf(ListOfRecordsOnly[y]);
                                        } else if (MyHeaderMap[y]==DisplayType.Date) {
                                            s = Date.valueOf(ListOfRecordsOnly[y]);
                                        } else if (MyHeaderMap[y]==DisplayType.DateTime) {                                     
                                            s = DateTime.valueOf(ListOfRecordsOnly[y]);
                                        } else if (MyHeaderMap[y]==DisplayType.REFERENCE) {
                                            id idList = Id.valueOf(ListOfRecordsOnly[y]);
                                            s = idList; 
                                        } else if ((MyHeaderMap[y]==DisplayType.PickList || MyHeaderMap[y]==DisplayType.PickList) && MyHeaderMap[y]==null) {
                                            s = '';
                                        }else{ 
                                            s = ListOfRecordsOnly[y];
                                        }           
                                    }catch (System.TypeException e){
                                        continue;                                     
                                    } 
                                    
                                    ObjectWithIdRecords.put(headersList[y], s);                                             
                                }
                            }
                        }
                        
                        //Add object ot list of object
                        SobjectForUpdate.add(ObjectWithIdRecords);
                    }
            }                                         
            
            if(firsTRecordIds == tempPrefix ){             
                
                //Update Record with database method
                try{
                    Database.SaveResult[] srList = Database.update(SobjectForUpdate, false); 
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,'Records Have been Upserted Succesfully');
                    ApexPages.addMessage(errormsg);           
                }
                
                catch (Exception e)
                    
                {
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
                    ApexPages.addMessage(errormsg);
                } 
            }
        }
        
        //upsert when the Id is not provided
        if(dmlOpps == 'Upsert'){
            
            try
            {
                Database.SaveResult[] srList = Database.insert(SobjectForUpdate, false); 
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,'Your Records Have Benn Succesfully Created');
                ApexPages.addMessage(errormsg);
            }
            catch (Exception e)
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
                ApexPages.addMessage(errormsg);
            } 
        }
        
        //When delete is chosen=====================================================Delete=======================
        
        list<string> DeletingIds = new list<string>(); 
        if(dmlOpps=='delete'){
            
            //Limiting the loop
            for(Integer k=0; k<headersList.size(); k++ ){
                
                //Check if the Id Column is there
               if(headersList[k]== 'Id'){
                    integer idColumn = k;
                    
                    //Loop for the size of the string
                    for(Integer h=1; h<csvRows.size(); h++){
                        
                        //Assigning the value of csvrows to list
                        ListOfRecordsWithId = csvRows.get(h);
                        firsTRecordIds = '';
                        integer b = 0;
                        
                        //List of Id's in the record
                        FieldValueWithId = ListOfRecordsWithId[b].split(',');
                        
                        //first 3 digits of the Id
                        for(string fvw : FieldValueWithId){
                            firsTRecordIds += fvw.subString(0, 3); 
                        }                                                             
                        b++;
                        
                        //List Of Id's Only
                        deletingIds.add(FieldValueWithId[idColumn]);
            
                        //Defining a dynamic object
                        ObjectWithIdRecords = Schema.getGlobalDescribe().get(selectedValue).newSObject();
                        
                        //putting value of field according to the field index
                        for(Integer y=0; y<deletingIds.size(); y++){ 
                            
                            //Check weather is provided or not
                            if(!IdContainedIndex.contains(y)){ 
                                
                                //check if the first 3 digits of Id are same or not
                                if(firsTRecordIds == tempPrefix ){
                                    
                                    //put header column with id's
                                    ObjectWithIdRecords.put( headersList[k] , deletingIds[y]);   
                                }
                            }
                        }
                        
                        //Add object ot list of object
                        SobjectForUpdate.add(ObjectWithIdRecords);
                    }
                }                                         
            }
            
            if(firsTRecordIds == tempPrefix ){             
                
                Database.DeleteResult[] results = Database.delete(SobjectForUpdate, false);
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,'Records Have been Removed Succesfully');
                ApexPages.addMessage(errormsg);
                
            } else {
                
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
                ApexPages.addMessage(errormsg);
                return;    
            } 
            
            //If the records don't have the column                       
            if(SobjectForUpdate.size()==0){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Records Dont have ID');
                ApexPages.addMessage(errormsg);                                             
                return;                                           
            }                    
        }   
        
}

}