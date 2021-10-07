declare module "@salesforce/apex/CustomParkingLotFormController.getParkingLotDetails" {
  export default function getParkingLotDetails(param: {eventId: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomParkingLotFormController.createParkingLot" {
  export default function createParkingLot(param: {eventId: any, session: any, email: any, phone: any, description: any, type: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomParkingLotFormController.updateParkingLots" {
  export default function updateParkingLots(param: {parkingLots: any}): Promise<any>;
}
