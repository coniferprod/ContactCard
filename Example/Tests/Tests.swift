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

    func test_vCard_commaInFormattedNameIsEscaped() {
        // FN:Mr. John Q. Public\, Esq.
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Mr. John Q. Public, Esq.\"]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            let vCardString = card!.asvCard()
            print(vCardString)
            XCTAssertTrue(vCardString.contains("FN:Mr. John Q. Public\\, Esq."))
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }

    func testNameProperty_vCard_commasInValueListAreEscaped() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"John Stevenson, den; or maybe not\"],[\"n\",{},\"text\",[\"Stevenson, den; or maybe not\",\"John\",[\"Philip\",\"Paul\"],\"Dr.\",[\"Jr.\",\"M.D.\",\"A.C.P.\"]]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            let vCardString = card!.asvCard()
            print(vCardString)
            XCTAssertTrue(vCardString.contains("N:Stevenson\\, den\\; or maybe not;John;Philip,Paul;Dr.;Jr.,M.D.,A.C.P."))
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

    // Currently only the date type is supported
    func testBirthdayProperty_date() {
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: sampleCards["alice"]!)
            
            if let property = card?.bday {
                XCTAssertTrue(property.valueType == PropertyValueType.date.rawValue)
                XCTAssertNil(property.year)
                XCTAssert(property.month == 10)
                XCTAssert(property.day == 8)
            }
            else {
                XCTFail("No bday property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testBirthdayProperty_notDate() {
        do {
            _ = try cardFrom(JSONString: sampleCards["marilou"]!)
            XCTFail()
        }
        catch JCardError.InvalidValueType {
            print("Correctly throwing JCardError.InvalidValueType because bday value type is not 'date'")
        }
        catch {
            XCTFail("Error parsing jCard")
        }
    }
    
/*
 ADR (address)
 The structured type value consists of a sequence of
 address components. The component values MUST be specified in
 their corresponding position. The structured type value
 corresponds, in sequence, to
 - the post office box;
 - the extended address (e.g., apartment or suite number);
 - the street address;
 - the locality (e.g., city);
 - the region (e.g., state or province);
 - the postal code;
 - the country name
*/
    func testAddressProperty() {
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: sampleCards["alice"]!)
            
            if let addresses = card?.postalAddresses {
                // There should be one postal address for Alice
                if addresses.count == 0 {
                    XCTFail("No postal addresses found")
                }
                else {
                    let address = addresses[0]  // this is an AdrProperty
                    XCTAssertTrue(address.street == "1351 Edwards Rd")
                    XCTAssertTrue(address.city == "Pompano Beach")
                    XCTAssertTrue(address.state == "Maryland")
                    XCTAssertTrue(address.postalCode == "50980")
                    XCTAssertTrue(address.country == "US")
                }
            }
            else {
                XCTFail("No adr properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
 
    func testAddressProperty_allEmpty() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"adr\",{\"type\":\"home\"},\"text\",[\"\",\"\",\"\",\"\",\"\",\"\",\"\"]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let addresses = card?.postalAddresses {
                // There should be one postal address for Alice
                if addresses.count == 0 {
                    XCTFail("No postal addresses found")
                }
                else {
                    let address = addresses[0]  // this is an AdrProperty
                    XCTAssertTrue(address.street == "")
                    XCTAssertTrue(address.city == "")
                    XCTAssertTrue(address.state == "")
                    XCTAssertTrue(address.postalCode == "")
                    XCTAssertTrue(address.country == "")
                }
            }
            else {
                XCTFail("No adr properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testAddressProperty_noType() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"adr\",{},\"text\",[\"\",\"\",\"1351 Edwards Rd\",\"Pompano Beach\",\"Maryland\",\"50980\",\"US\"]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let addresses = card?.postalAddresses {
                // There should be one postal address for Alice
                if addresses.count == 0 {
                    XCTFail("No postal addresses found")
                }
                else {
                    let address = addresses[0]  // this is an AdrProperty
                    
                    // There should be no type parameters
                    XCTAssertTrue(address.parameters["type"] == nil)
                    
                    XCTAssertTrue(address.street == "1351 Edwards Rd")
                    XCTAssertTrue(address.city == "Pompano Beach")
                    XCTAssertTrue(address.state == "Maryland")
                    XCTAssertTrue(address.postalCode == "50980")
                    XCTAssertTrue(address.country == "US")
                }
            }
            else {
                XCTFail("No ADR properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    /*
    func testAddressProperty_label() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"adr\",{\"type\":\"home\",\"label\":\"Alice Gregory\\n1351 Edwards Rd\\nPompano Beach, MD 50980\"},\"text\",[\"\",\"\",\"1351 Edwards Rd\",\"Pompano Beach\",\"Maryland\",\"50980\",\"US\"]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let addresses = card?.postalAddresses {
                // There should be one postal address for Alice
                if addresses.count == 0 {
                    XCTFail("No postal addresses found")
                }
                else {
                    let address = addresses[0]  // this is an AdrProperty
                    XCTAssertNotNil(address.parameters["label"])
                    let label = address.parameters["label"]?[0]
                    XCTAssertTrue(label == "Alice Gregory\n1351 Edwards Rd\nPompano Beach, MD 50980")
                }
            }
            else {
                XCTFail("No adr properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    */
    
    /*
 TEL
 Value type:  By default, it is a single free-form text value (for
 backward compatibility with vCard 3), but it SHOULD be reset to a
 URI value.  It is expected that the URI scheme will be "tel", as
 specified in [RFC3966].
 */
    func testTelProperty_manyParameterValues() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Gregory\",\"Alice\",\"\",\"\",\"\"]],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"bday\",{},\"date\",\"--10-08\"],[\"adr\",{\"type\":\"home\"},\"text\",[\"\",\"\",\"1351 Edwards Rd\",\"Pompano Beach\",\"Maryland\",\"50980\",\"US\"]],[\"email\",{\"type\":\"home\"},\"text\",\"alice.gregory@example.com\"],[\"tel\",{\"type\":[\"home\",\"cell\",\"voice\",\"text\"]},\"uri\",\"tel:(670)-328-1662\"]]]"

        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let numbers = card?.phoneNumbers {
                // There should be one phone number for Alice, and home/cell+voice+text
                if numbers.count != 1 {
                    XCTFail("Expected one TEL property")
                }
                else {
                    let phone = numbers[0]  // this is a TelProperty
                    XCTAssertTrue(phone.valueType == PropertyValueType.URI.rawValue)
                    
                    if let typeParameter = phone.parameters["type"] {
                        XCTAssertTrue(typeParameter.count == 4)
                        XCTAssertTrue(typeParameter[0] == "home" && typeParameter[1] == "cell" && typeParameter[2] == "voice" && typeParameter[3] == "text")
                    }
                    else {
                        XCTFail("No type parameter found in TEL property")
                    }
                    
                    let value = phone.value as! String
                    XCTAssertTrue(value == "tel:(670)-328-1662")
                }
            }
            else {
                XCTFail("No TEL properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testTelProperty_oneParameterValue() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Gregory\",\"Alice\",\"\",\"\",\"\"]],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"bday\",{},\"date\",\"--10-08\"],[\"adr\",{\"type\":\"home\"},\"text\",[\"\",\"\",\"1351 Edwards Rd\",\"Pompano Beach\",\"Maryland\",\"50980\",\"US\"]],[\"email\",{\"type\":\"home\"},\"text\",\"alice.gregory@example.com\"],[\"tel\",{\"type\":\"home\"},\"uri\",\"tel:(670)-328-1662\"]]]"
        
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let numbers = card?.phoneNumbers {
                // There should be one phone number for Alice, and home/cell+voice+text
                if numbers.count != 1 {
                    XCTFail("Expected one TEL property")
                }
                else {
                    let phone = numbers[0]  // this is a TelProperty
                    XCTAssertTrue(phone.valueType == PropertyValueType.URI.rawValue)
                    
                    if let typeParameter = phone.parameters["type"] {
                        XCTAssertTrue(typeParameter.count == 1)
                        XCTAssertTrue(typeParameter[0] == "home")
                    }
                    else {
                        XCTFail("No type parameter found in TEL property")
                    }
                    
                    let value = phone.value as! String
                    XCTAssertTrue(value == "tel:(670)-328-1662")
                }
            }
            else {
                XCTFail("No TEL properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }

    func testTelProperty_noTypeParameters() {
        // The 'tel' property has an empty type parameter section
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Gregory\",\"Alice\",\"\",\"\",\"\"]],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"bday\",{},\"date\",\"--10-08\"],[\"adr\",{\"type\":\"home\"},\"text\",[\"\",\"\",\"1351 Edwards Rd\",\"Pompano Beach\",\"Maryland\",\"50980\",\"US\"]],[\"email\",{\"type\":\"home\"},\"text\",\"alice.gregory@example.com\"],[\"tel\",{},\"uri\",\"tel:(670)-328-1662\"]]]"
        
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let numbers = card?.phoneNumbers {
                // There should be one phone number for Alice, with no type
                if numbers.count != 1 {
                    XCTFail("Expected one TEL property")
                }
                else {
                    let phone = numbers[0]  // this is a TelProperty
                    XCTAssertTrue(phone.valueType == PropertyValueType.URI.rawValue)
                    
                    XCTAssert(phone.parameters["type"] == nil)
                    
                    let value = phone.value as! String
                    XCTAssertTrue(value == "tel:(670)-328-1662")
                }
            }
            else {
                XCTFail("No TEL properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }

    }
        
    func testEmailProperty() {
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: sampleCards["alice"]!)
            
            if let emails = card?.emailAddresses {
                // There should be one e-mail address for Alice
                if emails.count != 1 {
                    XCTFail("Expected one e-mail address")
                }
                else {
                    let email = emails[0]
                    let value = email.value as! String
                    XCTAssertTrue(value == "alice.gregory@example.com")
                }
            }
            else {
                XCTFail("No EMAIL properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testEmalProperty_noTypeParameters() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"n\",{},\"text\",[\"Gregory\",\"Alice\",\"\",\"\",\"\"]],[\"fn\",{},\"text\",\"Alice Gregory\"],[\"email\",{},\"text\",\"alice.gregory@example.com\"]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)

            if let emails = card?.emailAddresses {
                // There should be one e-mail address for Alice
                if emails.count != 1 {
                    XCTFail("Expected one e-mail address")
                }
                else {
                    let email = emails[0]
                    
                    let typeParams = email.parameters["type"]
                    XCTAssertTrue(typeParams == nil)
                    
                    let value = email.value as! String
                    XCTAssertTrue(value == "alice.gregory@example.com")
                }
            }
            else {
                XCTFail("No EMAIL properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }

    }
    
    func testUrlProperty() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"url\",{\"type\": \"home\"},\"uri\",\"http://www.example.com\"]]]"
        
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let urls = card?.urlAddresses {
                // There should be one URL of type 'home'
                if urls.count != 1 {
                    XCTFail("Expected one URL property")
                }
                else {
                    let url = urls[0]
                    XCTAssertTrue(url.valueType == PropertyValueType.URI.rawValue)
                    
                    if let typeParams = url.parameters["type"] {
                        XCTAssert(typeParams.count == 1)
                        XCTAssert(typeParams[0] == "home")
                    }
                    
                    let value = url.value as! String
                    XCTAssertTrue(value == "http://www.example.com")
                }
            }
            else {
                XCTFail("No URL properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testTitleProperty() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"title\",{},\"text\",\"Organist\"],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"url\",{\"type\":\"home\"},\"uri\",\"http://www.example.com\"]]]"
        
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let title = card?.title {
                XCTAssertTrue(title.valueType == PropertyValueType.text.rawValue)
                    
                // TODO: Test the parameters
                let typeParameters = title.parameters["type"]
                    
                let value = title.value as! String
                XCTAssertTrue(value == "Organist")
            }
            else {
                XCTFail("No TITLE properties found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testOrgProperty_one() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"title\",{},\"text\",\"Organist\"],[\"org\",{},\"text\",\"Acme, Inc.\"],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"url\",{\"type\":\"home\"},\"uri\",\"http://www.example.com\"]]]"

        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let property = card?.org {
                XCTAssertTrue(property.valueType == PropertyValueType.text.rawValue)
                XCTAssertTrue(property.value.count == 1 && property.value[0] == "Acme, Inc.")
            }
            else {
                XCTFail("No ORG property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }
    
    func testOrgProperty_many() {
        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"title\",{},\"text\",\"Organist\"],[\"org\",{},\"text\",[\"Acme, Inc.\",\"Music Dept.\"]],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"url\",{\"type\":\"home\"},\"uri\",\"http://www.example.com\"]]]"

        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let property = card?.org {
                XCTAssertTrue(property.valueType == PropertyValueType.text.rawValue)
                XCTAssertTrue(property.value.count == 2 && property.value[0] == "Acme, Inc." && property.value[1] == "Music Dept.")
            }
            else {
                XCTFail("No ORG property found")
            }
        }
        catch _ {
            XCTFail("Error parsing jCard")
        }
    }

    func testSocialProfileProperty() {
        // The final jCard form of the social profile will be like this:
        // ["x-socialprofile", {"type": "x-twitter"}, "text", ["Twitter", "url", "", "username"]]

        let jCard = "[\"vcard\",[[\"version\",{},\"text\",\"4.0\"],[\"fn\",{},\"text\",\"Marilou Lam\"],[\"n\",{},\"text\",[\"Lam\",\"Marilou\",\"\",\"\",\"Ms\"]],[\"adr\",{},\"text\",[\"\",\"\",\"3892 Duke St\",\"Oakville\",\"NJ\",\"79279\",\"U.S.A.\"]],[\"email\",{},\"text\",\"marilou.lam@example.com\"],[\"x-socialprofile\",{\"type\":\"x-twitter\"},\"text\",[\"Twitter\",\"https://twitter.com/twitter\",\"\",\"twitter\"]]]]"
        var card: ContactCard?
        do {
            card = try cardFrom(JSONString: jCard)
            
            if let profiles = card?.socialProfiles {
                if profiles.count != 1 {
                    XCTFail("Expected one x-socialprofile property")
                }
                else {
                    let profile = profiles[0]
                    XCTAssertTrue(profile.valueType == PropertyValueType.text.rawValue)
                    
                    // TODO: Test the parameters
                    let typeParam = profile.parameters["type"]
                    
                    XCTAssertTrue(profile.service == "Twitter")
                    XCTAssertTrue(profile.urlString == "https://twitter.com/twitter")
                    XCTAssertTrue(profile.userIdentifier == "")
                    XCTAssertTrue(profile.username == "twitter")
                }
            }
            else {
                XCTFail("No x-socialprofile properties found")
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
// vCard 3.0 specification: https://www.ietf.org/rfc/rfc2426.txt
