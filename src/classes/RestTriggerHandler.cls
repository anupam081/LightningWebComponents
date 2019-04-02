public class RestTriggerHandler {

 public static String response {get;set;}
 
  public static string tid {
  get;
  set;
 }

 @future(callout = true)
 public static void createCustomTrigger(String json, String session_id) {
 
 system.debug('session_id  >>'+session_id);

  Httprequest req = new HttpRequest();
  req.setEndpoint('https://proof2-dev-ed.my.salesforce.com/services/data/v28.0/tooling/sobjects/ApexTrigger');
  req.setMethod('POST');
  req.setHeader('Content-Type', 'application/json');
  req.setHeader('Authorization','Bearer '+session_id);
  req.setBody(json);

  System.debug('request   >>'+req);
  Http httpReq = new Http();
  HttpResponse res = httpReq.send(req);
  //HttpResponse res = new HttpResponse(); 
  
  

  System.debug('Trigger Response >>>>>>>>' + res.getBody());

  response = string.valueof(res.getBody());
  system.debug('-----------' + response);
  if (response.contains('true')) {
   string rstr = response.remove('"');
   string[] strs = rstr.split(':');
   string[] fstr = strs[1].split(',');
   tid = fstr[0];
   system.debug('.................' + tid);
  }

 }

}