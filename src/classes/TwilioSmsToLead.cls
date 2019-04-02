/* Create lead based on SMS reply in salesforce*/

@RestResource(urlMapping='/smstolead')
global class TwilioSmsToLead {
	
	static TwilioAccount account = TwilioAPI.getDefaultAccount();
	
	
	@HttpPost
	global static void incomingSMS() {
		
		String myPhoneNumber = account.getIncomingPhoneNumbers().getPageData()[0].getPhoneNumber();
		// This will error out with System.LimitException if we would exceed 
		// our daily email limit
		Messaging.reserveSingleEmailCapacity(1);
		
		String expectedSignature = RestContext.request.headers.get('X-Twilio-Signature');
		String url = 'https://' + RestContext.request.headers.get('Host') + '/services/apexrest' + RestContext.request.requestURI;
		Map <String, String> params = RestContext.request.params;

		// Validate signature
		if (!TwilioAPI.getDefaultClient().validateRequest(expectedSignature, url, params)) {
		    RestContext.response.statusCode = 403;
		    RestContext.response.responseBody = 
		        Blob.valueOf('Failure! Rcvd '+expectedSignature+'\nURL '+url /* + '\nHeaders'+RestContext.request.headers*/);
		    return;
		}
		
		// Twilio likes to see something in the response body, otherwise it reports
		// a 502 error in https://www.twilio.com/user/account/log/notifications
		RestContext.response.responseBody = Blob.valueOf('ok');
		
		// Extract useful fields from the incoming SMS
		String leadNumber = params.get('From');
		String contactNumber = params.get('To');
		String SMSBody = params.get('Body');
		
		// Try to find a matching Contact
		Contact conntact = null;
		try {
		    conntact = [SELECT Id, Name, MobilePhone 
		        FROM Contact 
		        WHERE MobilePhone = :contactNumber 
		        LIMIT 1];
		} catch (QueryException qe) {
		    reply(myPhoneNumber, contactNumber, 'No Contact configured. Sorry.');
		    return;
		}
		
		
		// Create and insert a new SMS activity
		SMS_Activity__c sms = new SMS_Activity__c(SMS_Body__c = SMSBody, SMS_From__c = leadNumber, Contact__c = conntact.id);
		
		try {
		    insert sms;
		} catch (DmlException dmle) {
		    String message = (dmle.getDmlType(0) == StatusCode.INVALID_EMAIL_ADDRESS)
		        ? SMSBody+' doesn\'t look like an email address. Please try again.'
		        : 'An error occurred. Sorry.';
		    reply(myPhoneNumber, contactNumber, message);
		    return;
		}
	
	}
	
	
	//Sending SMS to the number
	@future(callout=true)
	public static void reply(String myPhoneNumber, String toNumber, String message) {
	    Map<String, String> params = new Map<String, String>{
	        'From' => myPhoneNumber, 
	        'To' => toNumber, 
	        'Body' => message
	    };
	
	    TwilioSms sms = account.getSmsMessages().create(params);
	    System.debug('Sent SMS SID: '+sms.getSid());
	}
	
}