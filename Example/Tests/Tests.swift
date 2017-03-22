// https://github.com/Quick/Quick

import Quick
import Nimble
import XCTest
@testable import ContactCard

class ContactCardTests: XCTestCase {
    func testEmptyCard() {
        let card = ContactCard()
        
        XCTAssertTrue(card.version.value as! String == "4.0")
    }
    
    func testCardFromJSON() {
        var card = ContactCard()
        do {
            card = try cardFrom(JSONString: examplejCard)
            
            XCTAssertTrue(card.formattedName.value as! String == "Marilou Lam")
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testVendorProperty() {
        var card = ContactCard()
        let testProperty = VendorProperty(name: "x-test", valueType: PropertyValueType.text, value: "foo" as AnyObject)
        card.vendorProperties.append(testProperty)
        if let cardTestProperty = card.vendorPropertyNamed(propertyName: "x-test") {
            XCTAssertTrue(cardTestProperty.value as! String == "foo")
        }
        else {
            XCTFail("Vendor property not available")
        }
    }
}

let examplejCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"bday\",{},\"date-and-or-time\",\"1967-06-09T06:59:48-05:00\"]]]"

class ContactCardSpec: QuickSpec {
    override func spec() {
        describe("these will fail") {

            it("can do maths") {
                expect(1) == 2
            }

            it("can read") {
                expect("number") == "string"
            }

            it("will eventually fail") {
                expect("time").toEventually( equal("done") )
            }
            
            context("these will pass") {

                it("can do maths") {
                    expect(23) == 23
                }

                it("can read") {
                    expect("🐮") == "🐮"
                }

                it("will eventually pass") {
                    var time = "passing"

                    DispatchQueue.main.async {
                        time = "done"
                    }

                    waitUntil { done in
                        Thread.sleep(forTimeInterval: 0.5)
                        expect(time) == "done"

                        done()
                    }
                }
            }
        }
    }
}


