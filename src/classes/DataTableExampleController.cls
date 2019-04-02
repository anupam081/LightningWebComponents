public class DataTableExampleController {  

    public String accountName { get; set; }
    public static Case account { get; set; }   
    
    @RemoteAction
    public static List<NBWrapper> getAccounts( ) {
        List<NBWrapper> accnts = new List<NBWrapper>();
        for(Case nbb : [Select Casenumber, id 
                                       from Case limit 10000]){
           
           NBWrapper nbr = new NBWrapper(true,nbb);
           accnts.add(nbr);                         
        }
        return accnts;
    }
    
    public class NBWrapper{
        Boolean check {get;set;}
        Case nb {get;set;}  
        public NBWrapper(Boolean flag, Case nbb){
            check = flag;
            nb = nbb;
        }
    }

}