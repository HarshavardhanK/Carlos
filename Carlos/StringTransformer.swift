import Foundation
import PiedPiper

/**
This class takes care of transforming NSData instances into String values.
*/
open class StringTransformer: TwoWayTransformer {
  public enum Error: Error {
    case invalidData
    case dataConversionToStringFailed
  }
  
  public typealias TypeIn = Data
  public typealias TypeOut = String
  
  fileprivate let encoding: String.Encoding
  
  /**
  Initializes a new instance of StringTransformer
  
  - parameter encoding: The encoding the transformer will use when serializing and deserializing NSData instances. By default it's NSUTF8StringEncoding
  */
  public init(encoding: String.Encoding = String.Encoding.utf8) {
    self.encoding = encoding
  }
  
  /**
  Serializes a NSData instance into a String with the configured encoding
  
  - parameter val: The NSData instance to serialize
  
  - returns: A Future containing the serialized String with the given encoding if the input is valid
  */
  open func transform(_ val: TypeIn) -> Future<TypeOut> {
    return Future(value: NSString(data: val, encoding: encoding) as? String, error: Error.invalidData)
  }
  
  /**
  Deserializes a String into a NSData instance
  
  - parameter val: The String to deserialize
  
  - returns: A Future<NSData> instance containing the bytes representation of the given string
  */
  open func inverseTransform(_ val: TypeOut) -> Future<TypeIn> {
    return Future(value: val.data(using: encoding, allowLossyConversion: false), error: Error.dataConversionToStringFailed)
  }
}
