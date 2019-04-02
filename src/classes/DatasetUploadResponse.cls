/*Einstein Intent API*/
Global class DatasetUploadResponse{
	webservice Integer id;	//1001408
	webservice String name;	//weather
	webservice String createdAt;	//2017-06-05T20:33:56.000+0000
	webservice String updatedAt;	//2017-06-05T20:33:56.000+0000
	webservice cls_labelSummary labelSummary;
	webservice Integer totalExamples;	//0
	webservice boolean available;
	webservice String statusMsg;	//UPLOADING
	webservice String type;	//text-intent
	webservice String objects;	//dataset
	Global class cls_labelSummary {
		webservice String[] labels;
	}
		
}