declare module "@salesforce/apex/InTheArea.getLocal" {
  export default function getLocal(param: {searchTerm: any, lat: any, lon: any}): Promise<any>;
}
declare module "@salesforce/apex/InTheArea.getListByAddress" {
  export default function getListByAddress(param: {recordId: any, objectType: any, searchQuery: any}): Promise<any>;
}
