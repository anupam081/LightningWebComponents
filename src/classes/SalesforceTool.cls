/*
 create trigger dynamically through tooling api
	create trigger through rest api.
*/
public with sharing class SalesforceTool
{
    final String endpoint = 'https://proof2-dev-ed.my.salesforce.com/services/data/v28.0/tooling/sobjects';

    // SomeValues to be store
    public String oid ;
    public String cid ;
    public String apmid ;
    public String carid ;

    public SalesforceTool()
    {
    }

    // used receive response by sending a http request
    private String getResponse(HttpRequest req)
    {
        try
        {
            Http httpreq = new Http();
            HttpResponse res = httpreq.send(req);
            String reqresponse = res.getBody();
            return reqresponse;
        }
        catch (Exception e)
        {
          return 'Error:' +e.getMessage();
        }
    }

    // create a http request with required endpoint and request method
    private HttpRequest createHttpRequest(String endpoint, String method)
    {
        HttpRequest req = new
        HttpRequest();
        endpoint += '';
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        return req;
    }
    
    
    //Create apex class dynamically
    public void createApexClass()
	{
            
        	
        	String trgName = 'testtrigger123456';
        	String selObj = 'Account';
        	String type2 = 'before insert';
        	String body = 'trigger '+ trgName + ' on '+ selObj +' (' + type2 + '){ }';    
        	map<string,string> mapinfo= new map<string,string>();
        	mapinfo.put('Name',trgName);
    		mapinfo.put('TableEnumOrId',selObj);
        	mapinfo.put('Body',body);
        	String serialized1 = JSON.serialize(mapinfo);
			
        	System.debug('serialized1 == '+serialized1);
        	
        	//List<Map<String,String>> ls = new List<Map<String,String>>();
            Map<String,String> mp = new Map<String,String>();
            mp.put('Name','AcTrigger1');
            mp.put('TableEnumOrId','Account');
            mp.put('Body','trigger AcTrigger1 on Account (after insert) {}');
            //ls.add(mp);
            String serialized = JSON.serialize(mp);
            
            mp = new Map<String,String>();
            mp.put('Name','AcTrigger2');
            mp.put('TableEnumOrId','Account');
            mp.put('Body','trigger AcTrigger2 on Account (after insert) {}');
            
            //ls.add(mp);
            serialized = serialized + ',' + JSON.serialize(mp);
            
        	
            System.debug('serialized = '+serialized);
        	
        
        	// create a Http request with post method
            HttpRequest req = createHttpRequest(endpoint+'/ApexTrigger','POST');        	
        
            //req.setBody( '{"Name":"testtrigger","TableEnumOrId":"Account",Body":"trigger testtrigger on Account (after insert) {}"}');
            req.setBody(serialized);

        	System.debug('req = '+req);
            // send request and receive response
            String response = getResponse(req);
        	System.debug('response = '+response);
            // These two lines have no role in creating apex class. So they can be ignored for now.
            //Map<String,Object> rmp = (Map<String,Object>)JSON.deserializeuntyped(response);
            //oid = (String)rmp.get('id');
   }
                          

}