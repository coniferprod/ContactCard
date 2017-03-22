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
            card = try cardFrom(JSONString: sampleCards["alice"]!)
            
            XCTAssertTrue(card.formattedName.value as! String == "Alice Gregory")

            if let name = card.name {
                XCTAssertTrue(name.familyNames.count == 1)
                XCTAssertTrue(name.givenNames.count == 1)
                XCTAssertTrue(name.additionalNames.count == 0)
                XCTAssertTrue(name.honorificPrefixes.count == 0)
                XCTAssertTrue(name.honorificSuffixes.count == 0)
            }
            else {
                XCTFail("No name property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testNameProperty_firstAndLastName() {
        let jsonWithFirstAndLast = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Firstname Lastname\"],[\"n\",{},\"text\",[\"Lastname\",\"Firstname\",\"\",\"\",\"\"]]]]"

        var card = ContactCard()
        do {
            card = try cardFrom(JSONString: jsonWithFirstAndLast)
            
            if let name = card.name {
                XCTAssertTrue(name.familyNames.count == 1)
                XCTAssertTrue(name.givenNames.count == 1)
                XCTAssertTrue(name.additionalNames.count == 0)
                XCTAssertTrue(name.honorificPrefixes.count == 0)
                XCTAssertTrue(name.honorificSuffixes.count == 0)
            }
            else {
                XCTFail("No name property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }

    func testNameProperty_twoMiddleNames() {
        let jsonWithFirstAndLast = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Firstname Lastname\"],[\"n\",{},\"text\",[\"Lastname\",\"Firstname\",[\"Middle1\",\"Middle2\"],\"\",\"\"]]]]"
        
        var card = ContactCard()
        do {
            card = try cardFrom(JSONString: jsonWithFirstAndLast)
            
            if let name = card.name {
                XCTAssertTrue(name.familyNames.count == 1)
                XCTAssertTrue(name.givenNames.count == 1)
                XCTAssertTrue(name.additionalNames.count == 2)
                XCTAssertTrue(name.honorificPrefixes.count == 0)
                XCTAssertTrue(name.honorificSuffixes.count == 0)
            }
            else {
                XCTFail("No name property found")
            }
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

let sampleCards : [String: String] = [
"alice": "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Gregory\",\"Alice\",\"\",\"\",\"\"]],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"bday\",{},\"date\",\"--10-08\"],[\"adr\",{\"type\":\"home\"},\"text\",[\"\",\"\",\"1351 Edwards Rd\",\"Pompano Beach\",\"Maryland\",\"50980\",\"US\"]],[\"email\",{\"type\":\"home\"},\"text\",\"alice.gregory@example.com\"],[\"tel\",{\"type\":[\"home\",\"voice\"]},\"uri\",\"tel:(108)-346-6480\"],[\"tel\",{\"type\":[\"home\",\"cell\",\"voice\",\"text\"]},\"uri\",\"tel:(670)-328-1662\"],[\"x-introni2\",{},\"text\",[\"work\",\"meeting\"]]]]",
                     
"marilou": "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"bday\",{},\"date-and-or-time\",\"1967-06-09T06:59:48-05:00\"]]]" ]

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


