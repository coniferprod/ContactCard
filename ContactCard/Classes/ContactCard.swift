/**
 * Copyright (c) 2017 Conifer Productions Oy
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Contacts
import SwiftyJSON

public typealias PropertyParameters = [String: [String]]

let emptyParameters = PropertyParameters()
let cardVersion = "4.0"
let cardIdentifier = "vcard"

public enum PropertyName: String {
    case version = "version"
    case kind = "kind"
    case formattedName = "fn"
    case name = "n"
    case nickname = "nickname"
    case title = "title"
    case organization = "org"
    case birthday = "bday"
    case telephone = "tel"
    case address = "adr"
    case email = "email"
    case URL = "url"
    case social = "x-socialprofile"  // NOTE: vendor extension, not in vCard
}

/*
 vCard 4.0 properties not currently supported:
 PHOTO
 ANNIVERSARY
 GENDER
 IMPP
 LANG
 TZ
 GEO
 ROLE
 LOGO
 MEMBER
 RELATED
 CATEGORIES
 NOTE
 PRODID
 REV
 SOUND
 UID
 CLIENTPIDMAP
 KEY
 FBURL
 CALADRURI
 CALURI
 */

public enum TypeParameterValue: String {
    case home = "home"
    case work = "work"
    case fax = "fax"
    case other = "other"
    case mobile = "cell"
    case voice = "voice"
    case pager = "pager"
    case iCloud = "x-icloud"
    case iPhone = "x-iphone"
    case twitter = "x-twitter"
    case facebook = "x-facebook"
    case linkedIn = "x-linkedin"
}

public enum PropertyValueType: String {
    case text = "text"
    case URI = "uri"
    case date = "date"
    case time = "time"
    case dateTime = "date-time"
    case dateAndOrTime = "date-and-or-time"
    case integer = "integer"
    case boolean = "boolean"
    case float = "float"
}


// NOTE: To simplify processing internally, all parameter values are arrays.
// When they are serialized, arrays of one element will be
// output as single values, and longer arrays as actual arrays.
protocol ValueProperty {
    var name: String { get }
    var parameters: PropertyParameters { get set }
    var valueType: String { get set }
    var value: AnyObject { get set }
    
    func asArray() -> [AnyObject]
}

protocol StructuredValueProperty {
    var name: String { get }
    var parameters: PropertyParameters { get set }
    var valueType: String { get set }
    var value: [String] { get set }
    
    func asArray() -> [AnyObject]
}

func unravelParameters(parameters: PropertyParameters) -> Dictionary<String, AnyObject> {
    // For each key in parameters:
    // If the array element count is 0,
    //     append empty parameter dictionary
    // If the array element count is 1,
    //     append a dictionary with the parameter name and the one string value.
    // If the array element count is more than 1,
    //     append a dictionary with the parameter name and an array of string values.
    var result = Dictionary<String, AnyObject>()
    for (parameterName, parameterValues) in parameters {
        switch parameterValues.count {
        case 0:
            result[parameterName] = Dictionary<String, AnyObject>() as AnyObject?
        case 1:
            result[parameterName] = parameterValues[0] as AnyObject?
        default:
            result[parameterName] = parameterValues as AnyObject?
        }
    }
    return result
}

public struct VersionProperty: ValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.version.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        value = cardVersion as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public struct KindProperty: ValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.kind.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        self.value = "" as AnyObject
    }
    
    mutating func setKind(value: KindPropertyValue) {
        self.value = value.rawValue as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public struct FormattedNameProperty: ValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.formattedName.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        self.value = "" as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public struct NicknameProperty: StructuredValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: [String]
    
    init(values: [String]) {
        name = PropertyName.nickname.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        value = values
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        
        if value.count == 1 {
            arr.append(value[0] as AnyObject)
        }
        else {
            arr.append(value as AnyObject)
        }
        return arr
    }
}

public struct TitleProperty: ValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.title.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        self.value = "" as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public struct VendorProperty: ValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    public var value: AnyObject
    
    public init(name: String, valueType: PropertyValueType, value: AnyObject) {
        self.name = name
        self.parameters = emptyParameters
        self.valueType = valueType.rawValue
        self.value = value
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public enum KindPropertyValue: String {
    case individual = "individual"
    case group = "group"
    case organization = "org"
    case location = "location"
}

public enum DatePropertyValueType: String {
    case date = "date"
    case time = "time"
    case dateTime = "date-time"
    case dateAndOrTime = "date-and-or-time"
}

public struct BirthdayProperty: ValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    // A birthday always has month and day, but year is optional.
    // We don't care about the time, only the date.
    public var year: Int?
    public var month: Int
    public var day: Int
    
    init(birthday: NSDateComponents, valueType: DatePropertyValueType) {
        name = PropertyName.birthday.rawValue
        parameters = emptyParameters
        self.valueType = valueType.rawValue
        
        // Check if there is a year in the birthday
        if birthday.year != NSDateComponentUndefined {
            self.year = birthday.year
        }
        
        self.month = birthday.month
        self.day = birthday.day
        
        // For yearless birthdays the format is "--12-30",
        // otherwise "1968-12-30".
        var s = ""
        if let y = self.year {
            s += String(format: "%04d", y)
        }
        else {
            s += "-"
        }
        s += String(format: "-%02d-%02d", month, day)
        
        self.value = s as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public enum NameComponentIndex: Int {
    case family = 0
    case given
    case additional
    case prefix
    case suffix
}

public struct NameProperty: StructuredValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: [String]
    
    // Each name component can have multiple values, so we make them arrays
    var familyNames: [String]
    var givenNames: [String]
    var additionalNames: [String]
    var honorificPrefixes: [String]
    var honorificSuffixes: [String]
    
    init() {
        name = PropertyName.name.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        value = [String]()
        
        familyNames = [String]()
        givenNames = [String]()
        additionalNames = [String]()
        honorificPrefixes = [String]()
        honorificSuffixes = [String]()
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        
        // Each of the name components could be a single string or an array of strings.
        // We treat them all as arrays. They go inside an array wrapper.
        var nameComponents = [AnyObject]()
        
        // If there is more than one name component value, emit an array;
        // otherwise emit the single value. Process the components in the
        // order specified by vCard.
        
        for components in [familyNames, givenNames, additionalNames, honorificPrefixes, honorificSuffixes] {
            if components.count > 1 {
                nameComponents.append(components as AnyObject)
            }
            else if components.count == 1 {
                nameComponents.append(components[0] as AnyObject)
            }
        }
        
        arr.append(nameComponents as AnyObject)
        
        return arr
    }
}

public struct OrgProperty: StructuredValueProperty {
    var name: String
    var parameters: PropertyParameters
    var valueType: String
    var value: [String]
    
    init(values: [String]) {
        name = PropertyName.organization.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        value = values
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)

        if value.count == 1 {
            arr.append(value[0] as AnyObject)
        }
        else {
            arr.append(value as AnyObject)
        }
        return arr
    }
}

public struct TelProperty: ValueProperty {
    var name: String
    public var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.telephone.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.URI.rawValue
        self.value = "" as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        
        let telString: String = "tel:" + (value as! String)
        arr.append(telString as AnyObject)
        return arr
    }
}

public struct EmailProperty: ValueProperty {
    var name: String
    public var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.email.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        self.value = "" as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public struct AdrProperty: StructuredValueProperty {
    var name: String
    public var parameters: PropertyParameters
    var valueType: String
    var value: [String]
    
    public var street: String
    public var city: String
    public var state: String
    public var postalCode: String
    public var country: String
    public var ISOCountryCode: String
    
    init() {
        name = PropertyName.address.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        value = [String]()
        
        street = ""
        city = ""
        state = ""
        postalCode = ""
        country = ""
        ISOCountryCode = ""
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        
        /*
         The vCard address component order:
         the post office box;
         the extended address (e.g., apartment or suite number);
         the street address;
         the locality (e.g., city);
         the region (e.g., state or province);
         the postal code;
         the country name
         */
        
        // NOTE: RFC 6350 says post office box and extended address
        // SHOULD be empty
        arr.append("" as AnyObject)  // post office box
        arr.append("" as AnyObject)  // extended address
        arr.append(street as AnyObject)
        arr.append(city as AnyObject)
        arr.append(postalCode as AnyObject)
        arr.append(country as AnyObject)
        return arr
    }
}

public struct URLProperty: ValueProperty {
    var name: String
    public var parameters: PropertyParameters
    var valueType: String
    var value: AnyObject
    
    init() {
        name = PropertyName.URL.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.URI.rawValue
        value = "" as AnyObject
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        arr.append(value)
        return arr
    }
}

public struct SocialProfileProperty: StructuredValueProperty {
    var name: String
    public var parameters: PropertyParameters
    var valueType: String
    var value: [String]
    
    public var service: String
    public var urlString: String
    public var userIdentifier: String
    public var username: String
    
    init() {
        name = PropertyName.social.rawValue
        parameters = emptyParameters
        valueType = PropertyValueType.text.rawValue
        value = [String]()
        
        service = ""
        urlString = ""
        userIdentifier = ""
        username = ""
    }
    
    func asArray() -> [AnyObject] {
        var arr = [AnyObject]()
        arr.append(name as AnyObject)
        arr.append(unravelParameters(parameters: self.parameters) as AnyObject)
        arr.append(valueType as AnyObject)
        let values = [service, urlString, userIdentifier, username]
        arr.append(values as AnyObject)
        return arr
    }
}

public struct ContactCard {
    public var version: VersionProperty
    public var kind: KindProperty?
    public var name: NameProperty?
    public var formattedName: FormattedNameProperty
    public var nickname: NicknameProperty?
    public var bday: BirthdayProperty?
    public var org: OrgProperty?
    public var title: TitleProperty?
    public var phoneNumbers: [TelProperty]?
    public var emailAddresses: [EmailProperty]?
    public var postalAddresses: [AdrProperty]?
    public var urlAddresses: [URLProperty]?
    public var socialProfiles: [SocialProfileProperty]?
    public var vendorProperties: [VendorProperty]
    
    public init() {
        // Set the mandatory properties
        version = VersionProperty()
        formattedName = FormattedNameProperty()
        vendorProperties = [VendorProperty]()
    }
    
    public func asJSON() -> String {
        var repr = [AnyObject]()
        repr.append(cardIdentifier as AnyObject)
        
        var properties = [AnyObject]()
        properties.append(self.version.asArray() as AnyObject)
        
        properties.append(self.formattedName.asArray() as AnyObject)
        
        if let kind = self.kind {
            properties.append(kind.asArray() as AnyObject)
        }
        
        if let name = self.name {
            properties.append(name.asArray() as AnyObject)
        }
        
        if let nickname = self.nickname {
            properties.append(nickname.asArray() as AnyObject)
        }
        
        if let bday = self.bday {
            properties.append(bday.asArray() as AnyObject)
        }
        
        if let org = self.org {
            properties.append(org.asArray() as AnyObject)
        }
        
        if let title = self.title {
            properties.append(title.asArray() as AnyObject)
        }
        
        if let phoneNumbers = self.phoneNumbers {
            for phoneNumber in phoneNumbers {
                properties.append(phoneNumber.asArray() as AnyObject)
            }
        }
        
        if let emailAddresses = self.emailAddresses {
            for email in emailAddresses {
                properties.append(email.asArray() as AnyObject)
            }
        }
        
        if let postalAddresses = self.postalAddresses {
            for address in postalAddresses {
                properties.append(address.asArray() as AnyObject)
            }
        }
        
        if let urlAddresses = self.urlAddresses {
            for url in urlAddresses {
                properties.append(url.asArray() as AnyObject)
            }
        }
        
        if let socialProfiles = self.socialProfiles {
            for socialProfile in socialProfiles {
                properties.append(socialProfile.asArray() as AnyObject)
            }
        }
        
        // Check if there are any vendor properties
        for vendorProperty in vendorProperties {
            properties.append(vendorProperty.asArray() as AnyObject)
        }
        
        repr.append(properties as AnyObject)
        
        do {
            let anyObj = try JSONSerialization.data(withJSONObject: repr, options: [])
            let anyObjAsString = String(data: anyObj, encoding: String.Encoding.utf8)
            return anyObjAsString!
        }
        catch let error as NSError {
            print("JSON generation error: \(error)")
        }
        
        return "{}"
    }
    
    //
    // Convert to vCard 3.0. Does not take into account special cases like
    // quotes and line folding. Maybe look for a library to do this properly?
    // Although vCard is not the primary output format, but it needs to be 
    // supported for wider compatibility.
    //
    public func asvCard() -> String {
        var lines = [String]()
        
        lines.append("BEGIN:VCARD")
        lines.append("VERSION:3.0")
        
        lines.append("FN:" + self.formattedName.name)
        
        lines.append("END:VCARD")
        
        // Concatenate all the lines into one string, with CR LF separators
        let cardString = ""
        return cardString
    }
    
    // If there is more than one vendor property with the same name,
    // this function takes the first and discards the rest.
    // Returns nil if there is not even one property with the given name.
    public func vendorPropertyNamed(propertyName: String) -> VendorProperty? {
        for property in vendorProperties {
            if property.name == propertyName {
                return property
            }
        }
        
        return nil
    }
}

public func contactFrom(card: ContactCard) -> CNMutableContact {
    let contact = CNMutableContact()
    
    // The version property is not needed here.
    // The FN property is discarded since the name components are
    // stored separately in CN(Mutable)Contact.
    
    if let nameProperty = card.name {
        if nameProperty.givenNames.count != 0 {
            contact.givenName = nameProperty.givenNames[0]
        }
        
        if nameProperty.familyNames.count != 0 {
            contact.familyName = nameProperty.familyNames[0]
        }
        
        if nameProperty.additionalNames.count != 0 {
            contact.middleName = nameProperty.additionalNames[0]
        }
        
        if nameProperty.honorificPrefixes.count != 0 {
            contact.namePrefix = nameProperty.honorificPrefixes[0]
        }
        
        if nameProperty.honorificSuffixes.count != 0 {
            contact.nameSuffix = nameProperty.honorificSuffixes[0]
        }
    }
    
    // Handle the kind property, if any, and set the contact type accordingly
    if let kindProperty = card.kind {
        let value = kindProperty.value as! String
        if value == KindPropertyValue.organization.rawValue {
            contact.contactType = CNContactType.organization
        }
        else if value == KindPropertyValue.individual.rawValue {
            contact.contactType = CNContactType.person
        }
    }
    
    if let cardPhoneNumbers = card.phoneNumbers {
        var contactPhoneNumbers = [CNLabeledValue<CNPhoneNumber>]()
        for phoneNumberProperty in cardPhoneNumbers {
            let parameters = phoneNumberProperty.parameters
            let typeParameterValues = parameters["type"]!
            var label: String?
            
            if typeParameterValues.contains("fax") {
                if typeParameterValues.contains("home") {
                    label = CNLabelPhoneNumberHomeFax
                }
                else if typeParameterValues.contains("work") {
                    label = CNLabelPhoneNumberWorkFax
                }
                else if typeParameterValues.contains("other") {
                    label = CNLabelPhoneNumberOtherFax
                }
            }
            else if typeParameterValues.contains("pager") {
                label = CNLabelPhoneNumberPager
            }
            else {  // must be a phone of some sort
                if typeParameterValues.contains("home") {
                    label = CNLabelHome
                }
                if typeParameterValues.contains("work") {
                    label = CNLabelWork
                }
                if typeParameterValues.contains("work") {
                    label = CNLabelOther
                }
                if typeParameterValues.contains("cell") {
                    label = CNLabelPhoneNumberMobile
                }
                if typeParameterValues.contains("x-iphone") {
                    label = CNLabelPhoneNumberiPhone
                }
            }
            
            var phoneNumberValue = phoneNumberProperty.value
            if phoneNumberValue.hasPrefix("tel:") {
                let phoneNumberString = phoneNumberValue as! String
                phoneNumberValue = String(phoneNumberString.characters.dropFirst("tel:".characters.count)) as AnyObject
            }
            let phoneNumber = CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: phoneNumberValue as! String))
            
            contactPhoneNumbers.append(phoneNumber)
        }
        
        contact.phoneNumbers = contactPhoneNumbers
    }
    
    if let cardPostalAddresses = card.postalAddresses {
        //print("ContactCard postal addresses: \(cardPostalAddresses.count)")
        
        var contactPostalAddresses = [CNLabeledValue<CNPostalAddress>]()
        for addressProperty in cardPostalAddresses {
            let address = CNMutablePostalAddress()
            address.street = addressProperty.street
            address.city = addressProperty.city
            address.state = addressProperty.state
            address.postalCode = addressProperty.postalCode
            address.country = addressProperty.country
            
            let parameters = addressProperty.parameters
            let typeParameterValues = parameters["type"]
            var label: String?
            for t in typeParameterValues! {
                switch t {
                case "work":
                    label = CNLabelWork
                case "home":
                    label = CNLabelHome
                case "other":
                    label = CNLabelOther
                default:
                    label = nil
                }
            }
            
            contactPostalAddresses.append(CNLabeledValue(label: label, value: address))
        }
        
        contact.postalAddresses = contactPostalAddresses
    }
    
    if let cardEmailAddresses = card.emailAddresses {
        //print("ContactCard email addresses: \(cardEmailAddresses.count)")
        
        var contactEmailAddresses = [CNLabeledValue<NSString>]()
        for emailProperty in cardEmailAddresses {
            let email = emailProperty.value
            var label: String?
            for t in emailProperty.parameters["type"]! {
                switch t {
                case "work":
                    label = CNLabelWork
                case "home":
                    label = CNLabelHome
                case "other":
                    label = CNLabelOther
                default:
                    label = nil
                }
            }
            
            contactEmailAddresses.append(CNLabeledValue(label: label, value: email as! NSString))
        }
        
        contact.emailAddresses = contactEmailAddresses
    }
    
    if let cardURLs = card.urlAddresses {
        //print("Contact Card URL addresses: \(cardURLs.count)")
        
        var contactURLs = [CNLabeledValue<NSString>]()
        
        var label: String?
        
        for URLProperty in cardURLs {
            let parameters = URLProperty.parameters
            if let typeParameterValues = parameters["type"] {
                for t in typeParameterValues {
                    switch t {
                    case "work":
                        label = CNLabelWork
                    case "home":
                        label = CNLabelHome
                    case "other":
                        label = CNLabelOther
                    default:
                        label = nil
                    }
                }
            }
            
            let URL = URLProperty.value
            contactURLs.append(CNLabeledValue(label: label, value: URL as! NSString))
        }
        
        contact.urlAddresses = contactURLs
    }
    
    if let bday = card.bday {
        let birthday = NSDateComponents()
        birthday.day = bday.day
        birthday.month = bday.month
        if let year = bday.year {
            birthday.year = year
        }
        print("setting birthday for contact, components = \(birthday)")
        contact.birthday = birthday as DateComponents
    }
    
    if let title = card.title {
        contact.jobTitle = title.value as! String
    }
    
    if let org = card.org {
        let parts = org.value
        contact.organizationName = parts[0]
        if parts.count > 1 {
            contact.departmentName = parts[1]
        }
    }
    
    if let nickname = card.nickname {
        contact.nickname = nickname.value[0]
    }
    
    if let cardSocialProfiles = card.socialProfiles {
        //print("ContactCard social profiles: \(cardSocialProfiles.count)")
        
        var contactSocialProfiles = [CNLabeledValue<CNSocialProfile>]()
        for socialProfileProperty in cardSocialProfiles {
            let parameters = socialProfileProperty.parameters
            //print("socialProfileProperty.parameters = \(parameters)")
            
            let service = socialProfileProperty.service
            let urlString = socialProfileProperty.urlString
            let userIdentifier = socialProfileProperty.userIdentifier
            let username = socialProfileProperty.username
            
            let socialProfile = CNSocialProfile(urlString: urlString, username: username, userIdentifier: userIdentifier, service: service)
            
            var serviceLabel: String?
            let typeParameter = parameters["type"]!.first!
            switch typeParameter {
            case TypeParameterValue.twitter.rawValue:
                serviceLabel = CNSocialProfileServiceTwitter
            case TypeParameterValue.facebook.rawValue:
                serviceLabel = CNSocialProfileServiceFacebook
            case TypeParameterValue.linkedIn.rawValue:
                serviceLabel = CNSocialProfileServiceLinkedIn
            default:
                serviceLabel = nil
            }
            
            contactSocialProfiles.append(CNLabeledValue(label: serviceLabel, value: socialProfile))
        }
        
        contact.socialProfiles = contactSocialProfiles
    }

    // Vendor properties will not contribute to the contact, at least not at this time.
    
    return contact
}

public func cardFrom(contact: CNContact) -> ContactCard {
    // Show some statistics about the contact:
    print("Phone numbers: \(contact.phoneNumbers.count)")
    print("E-mail addresses: \(contact.emailAddresses.count)")
    print("Postal addresses: \(contact.postalAddresses.count)")
    print("URLs: \(contact.urlAddresses.count)")
    print("Social profiles: \(contact.socialProfiles.count)")
    
    var card = ContactCard()
    
    var kind = KindProperty()
    switch contact.contactType {
    case .organization:
        kind.setKind(value: .organization)
    case .person:
        kind.setKind(value: .individual)
    }
    
    card.kind = kind
    
    if let birthday = contact.birthday {
        card.bday = BirthdayProperty(birthday: birthday as NSDateComponents, valueType: .date)
    }
    
    var name = NameProperty()
    name.givenNames = [contact.givenName]
    name.familyNames = [contact.familyName]
    name.additionalNames = [contact.middleName]
    name.honorificPrefixes = [contact.namePrefix]
    name.honorificSuffixes = [contact.nameSuffix]
    card.name = name
    
    if contact.organizationName != "" {
        var values = [contact.organizationName]
        if contact.departmentName != "" {
            values.append(contact.departmentName)
        }
        card.org = OrgProperty(values: values)
    }
    else {
        print("No organization")
    }
    
    var title = TitleProperty()
    if contact.jobTitle != "" {
        title.value = contact.jobTitle as AnyObject
        card.title = title
    }
    else {
        print("No job title")
    }
    
    if contact.phoneNumbers.count != 0 {
        var phoneNumbers = [TelProperty]()
        for phoneNumber in contact.phoneNumbers {
            var tel = TelProperty()
            let digits = (phoneNumber.value ).value(forKey: "digits") as! String
            //print("tel = '\(digits)', label = '\(phoneNumber.label)'")
            
            var typeParameterValues = [TypeParameterValue]()
            let label = phoneNumber.label
            
            let faxLabelSet: Set<String> = [CNLabelPhoneNumberHomeFax, CNLabelPhoneNumberWorkFax, CNLabelPhoneNumberOtherFax]
            if faxLabelSet.contains(label!) { // it is a fax machine
                typeParameterValues.append(.fax)
                if label == CNLabelPhoneNumberHomeFax {
                    typeParameterValues.append(.home)
                }
                if label == CNLabelPhoneNumberWorkFax {
                    typeParameterValues.append(.work)
                }
                if label == CNLabelPhoneNumberOtherFax {
                    typeParameterValues.append(.other)
                }
            }
            else if label == CNLabelPhoneNumberPager {
                typeParameterValues.append(.pager)
            }
            else {  // must be a phone of some sort
                if label == CNLabelHome {
                    typeParameterValues.append(.home)
                }
                if label == CNLabelWork {
                    typeParameterValues.append(.work)
                }
                if label == CNLabelOther {
                    typeParameterValues.append(.other)
                }
                if label == CNLabelPhoneNumberMobile {
                    typeParameterValues.append(.mobile)
                }
                typeParameterValues.append(.voice)
            }
            
            if label == CNLabelPhoneNumberiPhone {
                typeParameterValues.append(.iPhone)
            }
            
            var stringTypeParameters = PropertyParameters()
            if typeParameterValues.count != 0 {
                stringTypeParameters["type"] = typeParameterValues.map({ $0.rawValue })
            }
            //var stringTypeParameters = ["type": typeParameterValues.map({ $0.rawValue })]
            
            if label == CNLabelPhoneNumberMain {  // main number
                stringTypeParameters["pref"] = ["1"]
            }
            
            //print(stringTypeParameters)
            tel.parameters = stringTypeParameters
            
            tel.value = digits as AnyObject
            phoneNumbers.append(tel)
        }
        card.phoneNumbers = phoneNumbers
    }
    
    if contact.emailAddresses.count != 0 {
        var emailAddresses = [EmailProperty]()
        for emailAddress in contact.emailAddresses {
            var email = EmailProperty()
            
            let label = emailAddress.label
            var typeParameterValues = [TypeParameterValue]()
            if label == CNLabelHome {
                typeParameterValues.append(.home)
            }
            if label == CNLabelWork {
                typeParameterValues.append(.work)
            }
            if label == CNLabelOther {
                typeParameterValues.append(.other)
            }
            if label == CNLabelEmailiCloud {
                typeParameterValues.append(.iCloud)
            }
            
            var stringTypeParameters = PropertyParameters()
            if typeParameterValues.count != 0 {
                stringTypeParameters["type"] = typeParameterValues.map({ $0.rawValue })
            }
            //let stringTypeParameters = ["type": typeParameterValues.map({ $0.rawValue })]
            
            // TODO: What about the 'pref' parameter?
            
            email.parameters = stringTypeParameters
            
            email.value = emailAddress.value as String as AnyObject
            emailAddresses.append(email)
        }
        
        card.emailAddresses = emailAddresses
    }
    
    if contact.postalAddresses.count != 0 {
        var postalAddresses = [AdrProperty]()
        for postalAddress in contact.postalAddresses {
            var adr = AdrProperty()
            
            let label = postalAddress.label
            var typeParameterValues = [TypeParameterValue]()
            if label == CNLabelHome {
                typeParameterValues.append(.home)
            }
            if label == CNLabelWork {
                typeParameterValues.append(.work)
            }
            if label == CNLabelOther {
                typeParameterValues.append(.other)
            }
            
            var stringTypeParameters = PropertyParameters()
            if typeParameterValues.count != 0 {
                stringTypeParameters["type"] = typeParameterValues.map({ $0.rawValue })
            }
            adr.parameters = stringTypeParameters
            //adr.parameters = ["type": typeParameterValues.map({ $0.rawValue })]
            
            let address = postalAddress.value
            adr.street = address.street
            adr.city = address.city
            adr.state = address.state
            adr.postalCode = address.postalCode
            adr.country = address.country
            postalAddresses.append(adr)
        }
        
        card.postalAddresses = postalAddresses
    }
    
    if contact.urlAddresses.count != 0 {
        var urlAddresses = [URLProperty]()
        for urlAddress in contact.urlAddresses {
            var url = URLProperty()
            
            let label = urlAddress.label
            var typeParameterValues = [TypeParameterValue]()
            if label == CNLabelHome {
                typeParameterValues.append(.home)
            }
            if label == CNLabelWork {
                typeParameterValues.append(.work)
            }
            if label == CNLabelOther {
                typeParameterValues.append(.other)
            }
            
            var stringTypeParameters = PropertyParameters()
            if typeParameterValues.count != 0 {
                stringTypeParameters["type"] = typeParameterValues.map({ $0.rawValue })
            }
            url.parameters = stringTypeParameters
            //url.parameters = ["type": typeParameterValues.map({ $0.rawValue })]
            
            url.value = urlAddress.value as String as String as AnyObject  // TODO: WTF?
            urlAddresses.append(url)
        }
        
        card.urlAddresses = urlAddresses
    }
    
    if contact.socialProfiles.count != 0 {
        var profiles = [SocialProfileProperty]()
        for socialProfile in contact.socialProfiles {
            var social = SocialProfileProperty()
            
            // From the Contacts framework documentation:
            // "Labels are not used for CNSocialProfile and CNInstantMessageAddress properties."
            
            //let label = socialProfile.label
            let value = socialProfile.value
            
            // These are the only relevant properties for CNSocialProfile:
            social.service = value.service
            social.urlString = value.urlString
            social.userIdentifier = value.userIdentifier
            social.username = value.username
            
            print("Social profile: service = '\(value.service)', urlString = '\(value.urlString)', userIdentifier = '\(value.userIdentifier)', username = '\(value.username)'")
            
            var serviceType = ""
                switch value.service {
                case CNSocialProfileServiceFacebook:
                    serviceType = "facebook"
                case CNSocialProfileServiceFlickr:
                    serviceType = "flickr"
                case CNSocialProfileServiceGameCenter:
                    serviceType = "gamecenter"
                case CNSocialProfileServiceLinkedIn:
                    serviceType = "linkedin"
                case CNSocialProfileServiceMySpace:
                    serviceType = "myspace"
                case CNSocialProfileServiceSinaWeibo:
                    serviceType = "sinaweibo"
                case CNSocialProfileServiceTencentWeibo:
                    serviceType = "tencentweibo"
                case CNSocialProfileServiceTwitter:
                    serviceType = "twitter"
                case CNSocialProfileServiceYelp:
                    serviceType = "yelp"
                default:
                    serviceType = "unknownsocialprofile"
                }
            
            // The final jCard form of the social profile will be like this:
            // ["x-socialprofile", {"type": "x-twitter"}, "text", ["Twitter", "url", "", "username"]]
            social.parameters = ["type": ["x-" + serviceType]]
            profiles.append(social)
        }
        
        card.socialProfiles = profiles
    }
    
    if let fullName = CNContactFormatter.string(from: contact, style: .fullName) {
        card.formattedName.value = fullName as AnyObject
    }
    else {
        print("Full name not available")
        // The FN property is mandatory in vCard, so put at least something there
        card.formattedName.value = "?" as AnyObject
    }
    
    if contact.nickname != "" {
        let nickname = NicknameProperty(values: [contact.nickname])
        card.nickname = nickname
    }
    else {
        print("No nickname found")
    }
    
    // None of the contact fields contribute to any vendor properties,
    // at least at this time.
    
    return card
}

enum PropertyIndex: Int {
    case name
    case parameters
    case valueType
    case value
}

enum JCardError: Error {
    case InvalidFormat
    case InvalidValueType
}

// Expects that the value string is exactly 7 (yearless dates)
// or 10 (full dates) characters in length
func parseBirthday(value: String) -> NSDateComponents {
    let components = NSDateComponents()
    if value.hasPrefix("--") { // it's a yearless date
        components.year = NSDateComponentUndefined
        
        let monthAndDay = String(value.characters.dropFirst(2)) // take all after the "--"
        
        let month = String(monthAndDay.characters.dropLast(3))  // take just the initial "mm"
        components.month = Int(month)!
        
        let day = String(monthAndDay.characters.dropFirst(3)) // take all after the "mm-"
        components.day = Int(day)!
    }
    else {  // it has year, month and date
        let year = String(value.characters.prefix(4))
        components.year = Int(year)!
        
        let monthAndDay = String(value.characters.dropFirst(4)) // take all after the "yyyy"
        
        let month = String(monthAndDay.characters.prefix(2))
        components.month = Int(month)!
        
        let day = String(monthAndDay.characters.suffix(2))
        components.day = Int(day)!
    }
    
    return components
}

//
// Extract the parameters of a property into a dictionary
// where key is parameter name and value is array of parameter values.
//
func extractParameters(JSONParameters: JSON) -> PropertyParameters {
    var parameters = PropertyParameters()
    
    for (name, value) in JSONParameters {
        var values = [String]()
        
        switch value.type {
        case .string:
            if value.string! != "" {
                values.append(value.string!)
            }
        case .array:
            for v in value.array! {
                values.append(v.string!)
            }
        default:
            print("Parameter value type = \(value.type), should never happen")
        }
        
        parameters[name] = values
    }
    
    return parameters
}

public func cardFrom(JSONString: String) throws -> ContactCard {
    //print("cardFromJSON: jsonString = \(jsonString)")
    
    var card = ContactCard()
    
    guard let dataFromString = JSONString.data(using: String.Encoding.utf8, allowLossyConversion: false)
    else {
        return card
    }
    
    let j = JSON(data: dataFromString)
    let signature = j[0].string
    
    guard signature == cardIdentifier
    else {
        throw JCardError.InvalidFormat
    }
    
    // Set up arrays of addresses, phone numbers etc.
    // If they are empty after JSON parsing,
    // then there is nothing to add.
    var addresses = [AdrProperty]()
    var phoneNumbers = [TelProperty]()
    var emails = [EmailProperty]()
    var urls = [URLProperty]()
    var socialProfiles = [SocialProfileProperty]()
    
    let properties = j[1]
    for (_, property) in properties {
        let propertyName = property[PropertyIndex.name.rawValue].stringValue
        print(propertyName)
        
        switch propertyName {
        case PropertyName.version.rawValue:
            let versionProperty = VersionProperty()
            card.version = versionProperty
            
        case PropertyName.formattedName.rawValue:
            var fnProperty = FormattedNameProperty()
            fnProperty.value = property[PropertyIndex.value.rawValue].stringValue as AnyObject
            card.formattedName = fnProperty
            
        case PropertyName.name.rawValue:
            var nameProperty = NameProperty()
            // No need to set empty parameters
            let nameComponents = property[PropertyIndex.value.rawValue]  // an array of components
            // There should be exactly five name components.
            // Any of the components could itself be an array.
            if nameComponents.count != 5 {
                print("ERROR: name property has \(nameComponents.count) components, not 5 - NOT OK")
            }
            else {
                for (index, component) in nameComponents {
                    print("\(index): \(component)")
                    var componentList = [String]()
                    
                    switch component.type {
                    case .string:
                        if component.string! != "" {
                            componentList.append(component.string!)
                        }
                    case .array:
                        for c in component.array! {
                            componentList.append(c.string!)
                        }
                    default:
                        print("Component type = \(component.type), should never happen")
                    }

                    let typeOfIndex = type(of: index)
                    print("\(index) of type \(typeOfIndex), componentList = \(componentList)")
                    switch Int(index)! {
                    case 0:
                        nameProperty.familyNames = componentList
                    case 1:
                        nameProperty.givenNames = componentList
                    case 2:
                        nameProperty.additionalNames = componentList
                    case 3:
                        nameProperty.honorificPrefixes = componentList
                    case 4:
                        nameProperty.honorificSuffixes = componentList
                    default:
                        break
                    }
                }
            }
            
            card.name = nameProperty
            //print("nameProperty = \(nameProperty.asArray())")
            
        case PropertyName.nickname.rawValue:
            let nicknames = property[PropertyIndex.value.rawValue]
            var values = [String]()
            if nicknames.type == .string {
                values.append(nicknames.string!)
            }
            else if nicknames.type == .array {
                for n in nicknames.array! {
                    values.append(n.string!)
                }
            }
            card.nickname = NicknameProperty(values: values)
            
        case PropertyName.birthday.rawValue:
            // Because the iOS contacts only store the date (and not the time)
            // in the Birthday field, a typical client app generates jCards with the bday
            // property type set as "date" - with or without a year present.
            // So for the time being, let's only parse the "date" type for bday.
            let birthdayValue = property[PropertyIndex.value.rawValue].stringValue
            let birthdayValueType = property[PropertyIndex.valueType.rawValue].stringValue
            print("bday value = \(birthdayValue), value type = \(birthdayValueType)")
            
            guard birthdayValueType == PropertyValueType.date.rawValue
            else {
                print("ERROR: only birthdays with the value type of 'date' are accepted")
                throw JCardError.InvalidValueType
            }

            let birthdayComponents = parseBirthday(value: birthdayValue)
            let birthdayProperty = BirthdayProperty(birthday: birthdayComponents, valueType: DatePropertyValueType.date)
            card.bday = birthdayProperty
            
        case PropertyName.address.rawValue:  // postal address
            var addressProperty = AdrProperty()
            
            addressProperty.parameters = extractParameters(JSONParameters: property[PropertyIndex.parameters.rawValue])
            
            let addressComponents = property[PropertyIndex.value.rawValue]  // an array of components
            if addressComponents.count != 7 {
                print("ERROR: address property has \(addressComponents.count) components, not 7 - NOT OK")
            }
            else {
                addressProperty.street = addressComponents[2].stringValue
                addressProperty.city = addressComponents[3].stringValue
                addressProperty.state = addressComponents[4].stringValue
                addressProperty.postalCode = addressComponents[5].stringValue
                addressProperty.country = addressComponents[6].stringValue
            }
            
            addresses.append(addressProperty)
            
            card.postalAddresses = addresses
            //print("addressProperty = \(addressProperty.asArray())")
            
        case PropertyName.telephone.rawValue:
            var telProperty = TelProperty()
            telProperty.parameters = extractParameters(JSONParameters: property[PropertyIndex.parameters.rawValue])
            let value = property[PropertyIndex.value.rawValue].stringValue
            telProperty.value = value as AnyObject
            phoneNumbers.append(telProperty)
            
        case PropertyName.email.rawValue:
            var emailProperty = EmailProperty()
            emailProperty.parameters = extractParameters(JSONParameters: property[PropertyIndex.parameters.rawValue])
            let value = property[PropertyIndex.value.rawValue].stringValue
            emailProperty.value = value as AnyObject
            emails.append(emailProperty)
            
        case PropertyName.title.rawValue:
            var titleProperty = TitleProperty()
            titleProperty.value = property[PropertyIndex.value.rawValue].stringValue as AnyObject
            card.title = titleProperty
            
        case PropertyName.URL.rawValue:
            var urlProperty = URLProperty()
            urlProperty.parameters = extractParameters(JSONParameters: property[PropertyIndex.parameters.rawValue])
            urlProperty.value = property[PropertyIndex.value.rawValue].stringValue as AnyObject
            urls.append(urlProperty)
            
        case PropertyName.organization.rawValue:
            let orgValues = property[PropertyIndex.value.rawValue]
            var values = [String]()
            if orgValues.type == .string {
                values.append(orgValues.string!)
            }
            else if orgValues.type == .array {
                for o in orgValues.array! {
                    values.append(o.string!)
                }
            }
            card.org = OrgProperty(values: values)
            
        case PropertyName.social.rawValue:
            var socialProfileProperty = SocialProfileProperty()
            socialProfileProperty.parameters = extractParameters(JSONParameters: property[PropertyIndex.parameters.rawValue])
            
            let profileComponents = property[PropertyIndex.value.rawValue]  // an array of components
            guard profileComponents.count == 4
            else {
                print("ERROR: the x-social-profile property should have 4 components, not \(profileComponents.count)")
                throw JCardError.InvalidFormat
            }
            socialProfileProperty.service = profileComponents[0].stringValue
            socialProfileProperty.urlString = profileComponents[1].stringValue
            socialProfileProperty.userIdentifier = profileComponents[2].stringValue
            socialProfileProperty.username = profileComponents[3].stringValue

            socialProfileProperty.value = [profileComponents[0].stringValue, profileComponents[1].stringValue, profileComponents[2].stringValue, profileComponents[3].stringValue]

            socialProfiles.append(socialProfileProperty)
            print(socialProfileProperty)
            
        default:
            break
        }
    }
    
    if addresses.count != 0 {
        card.postalAddresses = addresses
    }
    
    if phoneNumbers.count != 0 {
        card.phoneNumbers = phoneNumbers
    }
    
    if emails.count != 0 {
        card.emailAddresses = emails
    }
    
    if urls.count != 0 {
        card.urlAddresses = urls
    }
    
    if socialProfiles.count != 0 {
        card.socialProfiles = socialProfiles
    }
    
    return card
}
