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
    
    //
    // The N property
    // Value type: A single structured text value. Each component can have multiple values.
    // The structured value has (in this order):
    // - Family Name(s), 
    // - Given Name(s)
    // - Additional Name(s)
    // - Honorifix Prefix(es)
    // - Honorific Suffix(es)
    //
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

    func testNameProperty_oneOfEach() {
        // N:Public;John;Quinlan;Mr.;Esq.
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Public\",\"John\",\"Quinlan\",\"Mr.\",\"Esq.\"]]]]"
        var card = ContactCard()
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let name = card.name {
                XCTAssertTrue(name.familyNames.count == 1 && name.familyNames[0] == "Public")
                XCTAssertTrue(name.givenNames.count == 1 && name.givenNames[0] == "John")
                XCTAssertTrue(name.additionalNames.count == 1 && name.additionalNames[0] == "Quinlan")
                XCTAssertTrue(name.honorificPrefixes.count == 1 && name.honorificPrefixes[0] == "Mr.")
                XCTAssertTrue(name.honorificSuffixes.count == 1 && name.honorificSuffixes[0] == "Esq.")
            }
            else {
                XCTFail("No name property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testNameProperty_manyOfSome() {
        // N:Stevenson;John;Philip,Paul;Dr.;Jr.,M.D.,A.C.P.
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Stevenson\",\"John\",[\"Philip\",\"Paul\"],\"Dr.\",[\"Jr.\",\"M.D.\",\"A.C.P.\"]]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let name = card?.name {
                XCTAssertTrue(name.familyNames.count == 1 && name.familyNames[0] == "Stevenson")
                XCTAssertTrue(name.givenNames.count == 1 && name.givenNames[0] == "John")
                XCTAssertTrue(name.additionalNames.count == 2 && name.additionalNames[0] == "Philip" && name.additionalNames[1] == "Paul")
                XCTAssertTrue(name.honorificPrefixes.count == 1 && name.honorificPrefixes[0] == "Dr.")
                XCTAssertTrue(name.honorificSuffixes.count == 3 && name.honorificSuffixes[0] == "Jr." && name.honorificSuffixes[1] == "M.D." && name.honorificSuffixes[2] == "A.C.P.")
            }
            else {
                XCTFail("No name property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    // FN (mandatory)
    func testFormattedNameProperty() {
        var card = ContactCard()
        do {
            card = try cardFrom(JSONString: sampleCards["alice"]!)
            
            let property = card.formattedName
            XCTAssertTrue(property.valueType == PropertyValueType.text.rawValue)
            XCTAssertTrue(property.value as! String == "Alice Gregory")
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testNicknameProperty_one() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Beam\",\"Jim\",\"\",\"\",\"\"]],[\"nickname\",{},\"text\",\"Jim\"]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let property = card?.nickname {
                XCTAssertTrue(property.valueType == PropertyValueType.text.rawValue)
                XCTAssertTrue(property.value.count == 1 && property.value[0] == "Jim")
            }
            else {
                XCTFail("No nickname property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testNicknameProperty_many() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Beam\",\"Jim\",\"\",\"\",\"\"]],[\"nickname\",{},\"text\",[\"Jim\",\"Jimmie\"]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let property = card?.nickname {
                XCTAssertTrue(property.valueType == PropertyValueType.text.rawValue)
                XCTAssertTrue(property.value.count == 2 && property.value[0] == "Jim" && property.value[1] == "Jimmie")
            }
            else {
                XCTFail("No nickname property found")
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

// jCard specification: https://tools.ietf.org/html/rfc7095
// vCard 4.0 specification: https://tools.ietf.org/html/rfc6350

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


