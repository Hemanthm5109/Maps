@isTest
public class TestAddressInformation {
    
    public static void direction(){
        // Set up test data
        String originAddress = '1036 San Jacinto Dr';
        String destinationAddress = '3945 E 17th St N';
        String result = '';

        // Create a mock HTTP response for the Google Maps API callout
        String mockResponseBody = '{"directions": "Mock directions"}';
        Integer mockStatusCode = 200;
        // MockHttpResponseGenerator mockHttp = new MockHttpResponseGenerator(mockResponseBody, mockStatusCode);
        
        // Set the mock implementation for the HttpCalloutMock interface
       Test.setMock(HttpCalloutMock.class, new mockHttp());

        // Call the Apex method
         return result = AddressInformation.getDirections( originAddress,  destinationAddress);

        // System.assertEquals('Mock directions', result.testGetDirections);
        System.assertEquals('10.0 mi', result.get('distance'));
        System.assertEquals('30 mins', result.get('travelTime'));
        System.assertEquals('5.00', result.get('cost'));
    }
    public class mockHttp implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"rows": [{"elements": [{"distance": {"value": 16093.4, "text": "10.0 mi"}, "duration": {"value": 1800, "text": "30 mins"}}]}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}