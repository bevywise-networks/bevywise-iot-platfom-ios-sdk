import XCTest
import BevywiseIotPlatformSDK

class Tests: XCTestCase, LoginResultDelegate, SignupDelegate, DeviceAuthKeyDelegate {
    func onAuthKeyGenerated(authKeyData: [String : Any?]?) {
        print("Authkey success")
    }
    
    func onSignupSuccess(token: String, refreshToken: String, expiresIn: Int) {
        print("Signup success")
    }
    
    func onLoginSuccess(token: String, refreshToken: String, expiresIn: Int) {
        print("Login success")
    }
    
    var bevywisePlatformConnector: BevywisePlatformConnector?
    
    override func setUp() {
        super.setUp()
        bevywisePlatformConnector = BevywisePlatformConnector.shared
        bevywisePlatformConnector?.platformConfigutation = PlatformConfiguration(url: "http://192.168.1.10:9486", username: "demo@bevywise.com", password: "pwd123", clientId: "Xq5Pff7FqHTLPNkkoEKQuCH8VjnPOe6dtGCUY64O", clientSecret: "WWqBIPN2ohhng7Srnpsvs1qIpioEgcL0P4m0qGDBPhyktw8Of1YZUQ1Yi8JGQPaqVHnpCie9pdBEEhLopBbtOzJcTv7flJWR4bfVFSMzLPYZUQgte9q0vGM9vhtFbLf8")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        //bevywisePlatformConnector?.login(delegate: self, onFailed: nil)
        //bevywisePlatformConnector?.signup(delegate: self, username: "princsddsenew2", password: "princdfsde", onFailed: nil)
        bevywisePlatformConnector?.getDeviceAuthKey(delegate: self, permission: DevicePermission.READ, keyDescription: "nothing", token: "6yASZ3cjr8xzLuzRPo2rTRqkodmS8F", onFailed: nil)
        wait(for: [XCTestExpectation(description: "Nothing")], timeout: 10)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
