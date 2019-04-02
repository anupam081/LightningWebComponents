/*Driving lincense image scanner*/

public class HackathonImageScanner {
    
    @Future(callout = true)
    public static void performScanningAndUpdateApp(String appId, Blob file_body, String file_name) {
        System.debug(LoggingLevel.DEBUG, '=====>>> Start driver scanning ==================>> ');
        System.debug(LoggingLevel.DEBUG, 'appId == ' + appId);
        System.debug(LoggingLevel.DEBUG, 'file_body.size() == ' + file_body.size());
        System.debug(LoggingLevel.DEBUG, 'file_name == ' + file_name);

        Blob bodyBlob = prepareRequestBody(file_body, file_name);
        HttpRequest req = new HttpRequest();

        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setHeader('Authorization', 'HzLrS5NDkrkAWv2Ejp5hXPdnghcylTmp'); 
        req.setMethod('POST');
        req.setEndpoint('https://wabr.inliteresearch.com/barcodes');
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res);
        System.debug(res.getBody());
        System.debug(res.getHeaderKeys());
        DriverLicenseScanningResult scanRes = parseDriverLic(res.getBody());
        applyRecognitionResultToApplication(scanRes, appId);
    }
    
   
    public static void scanDrivingLicense(String appId, Blob file_body, String file_name) {
        System.debug(LoggingLevel.DEBUG, '=====>>> Start driver scanning ==================>> ');
        System.debug(LoggingLevel.DEBUG, 'appId == ' + appId);
        System.debug(LoggingLevel.DEBUG, 'file_body.size() == ' + file_body.size());
        System.debug(LoggingLevel.DEBUG, 'file_name == ' + file_name);

        Blob bodyBlob = prepareRequestBody(file_body, file_name);
        HttpRequest req = new HttpRequest();

        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setHeader('Authorization', 'zKuEOpu0Vpv4CUlomzWS73wSSFsItc4A'); 
        req.setMethod('POST');
        req.setEndpoint('https://wabr.inliteresearch.com/barcodes');
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res);
        System.debug(res.getBody());
        System.debug(res.getHeaderKeys());
        DriverLicenseScanningResult scanRes = parseDriverLic(res.getBody());
        applyRecognitionResultToApplication(scanRes, appId);
    }

    private static String boundary;

    private static Blob prepareRequestBody(Blob file_body, String file_name) {
        boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="'+file_name + '"\r\nContent-Type: image/jpeg'; 
        String footer = '--'+boundary+'--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while (headerEncoded.endsWith('=')) {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);

        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer + '\r\n'));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer + '\r\n'));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer + '\r\n'));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        return bodyBlob;  
    }

    private static DriverLicenseScanningResult parseDriverLic(String jsonStr) {
        JSONParser parser = JSON.createParser(jsonStr);
        DriverLicenseScanningResult drvLic;
        while (parser.nextToken() != null) {
            // Start at the array of invoices.
            System.debug(LoggingLevel.DEBUG, parser.getCurrentToken());
            if (parser.getCurrentName() == 'Values') {
                while (parser.nextToken() != null) {
                    System.debug(parser.getCurrentName());
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() != 'Values') {
                        drvLic = (DriverLicenseScanningResult)parser.readValueAs(DriverLicenseScanningResult.class);
                        System.debug(drvLic);
                        //parser.skipChildren();
                        return drvLic;
                    }
                }
            }
        }
        return null;
    }
    
    
    private static Application__c queryCurrentApp(String appId) {
        return [
            SELECT  Id, DEV_Innovation__Last_Name__c, DEV_Innovation__First_Name__c, DEV_Innovation__Middle_Initial__c, 
			DEV_Innovation__Gender__c, DEV_Innovation__Prefix__c, DEV_Innovation__BirthDate__c,
            DEV_Innovation__Primary_Address__c, DEV_Innovation__Primary_City__c, DEV_Innovation__Primary_State__c, 
			DEV_Innovation__Primary_Zip__c, DEV_Innovation__Primary_Country__c
            FROM DEV_Innovation__Application__c WHERE Id =: appId
        ];
    }

    
   
    private static void applyRecognitionResultToApplication(DriverLicenseScanningResult scanResult, String appId) {
        System.debug(LoggingLevel.DEBUG, scanResult);
        System.debug(LoggingLevel.DEBUG, appId);
        if (scanResult != null) {
            DEV_Innovation__Application__c app = queryCurrentApp(appId);
            app.DEV_Innovation__Last_Name__c = scanResult.last;
            app.DEV_Innovation__First_Name__c = scanResult.first;
            app.Name = (app.Last_Name__c + ' ' + app.First_Name__c).left(79);
            app.DEV_Innovation__Middle_Initial__c = scanResult.middle == null ? null : scanResult.middle.left(1);
            app.DEV_Innovation__Gender__c = scanResult.sex;
            app.DEV_Innovation__Prefix__c = scanResult.suffix;
            app.DEV_Innovation__BirthDate__c = Date.valueOf(scanResult.dob); // Date.parse('05/23/1930');//
            app.DEV_Innovation__Primary_Address__c = scanResult.street;
            app.DEV_Innovation__Primary_City__c = scanResult.city;
            app.DEV_Innovation__Primary_State__c = scanResult.state;
            app.DEV_Innovation__Primary_Zip__c = scanResult.postal == null ? null : scanResult.postal.left(10);
            app.DEV_Innovation__Primary_Country__c = scanResult.country;

            upsert app;
        }
    }

    
    
/*
    private static Application__c queryCurrentApp(String appId) {
        return [
            SELECT  Id, Last_Name__c, First_Name__c, Middle_Initial__c, Gender__c, Prefix__c, Birthdate__c,
                    Primary_Address__c, Primary_City__c, Primary_State__c, Primary_Zip__c, Primary_County__c
            FROM Application__c WHERE Id =: appId
        ];
    }
*/
    
 /*   
    private static void applyRecognitionResultToApplication(DriverLicenseScanningResult scanResult, String appId) {
        System.debug(LoggingLevel.DEBUG, scanResult);
        System.debug(LoggingLevel.DEBUG, appId);
        if (scanResult != null) {
            Application__c app = queryCurrentApp(appId);
            app.Last_Name__c = scanResult.last;
            app.First_Name__c = scanResult.first;
            app.Name = (app.Last_Name__c + ' ' + app.First_Name__c).left(79);
            app.Middle_Initial__c = scanResult.middle == null ? null : scanResult.middle.left(1);
            app.Gender__c = scanResult.sex;
            app.Prefix__c = scanResult.suffix;
            app.Birthdate__c = Date.valueOf(scanResult.dob); // Date.parse('05/23/1930');//
            app.Primary_Address__c = scanResult.street;
            app.Primary_City__c = scanResult.city;
            app.Primary_State__c = scanResult.state;
            app.Primary_Zip__c = scanResult.postal == null ? null : scanResult.postal.left(10);
            app.Primary_Country__c = scanResult.country;

            upsert app;
        }
    }
*/

    public class DriverLicenseScanningResult {
        public String last;
        public String first;
        public String middle;
        public String suffix;
        public String dob;
        public String street;
        public String city;
        public String state;
        public String sex;
        public String postal;
        public String country;
        public String id;
        public String issued;
        public String expires;
    }

}