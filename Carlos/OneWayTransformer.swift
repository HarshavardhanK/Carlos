//
//  OneWayTransformer.swift
//  Carlos
//
//  Created by Vittorio Monaco on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation
import MapKit

/// Abstract an object that can transform values to another type
public protocol OneWayTransformer {
  /// The input type of the transformer
  typealias TypeIn
  
  /// The output type of the transformer
  typealias TypeOut
  
  /**
  Apply the transformation from A to B
  
  :param: val The value to transform
  
  :returns: The transformed value
  */
  func transform(val: TypeIn) -> TypeOut
}

/// Simple implementation of the TwoWayTransformer protocol
public struct OneWayTransformationBox<I, O>: OneWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
  public typealias TypeOut = O
  
  private let transformClosure: I -> O
  
  public init(transform: (I -> O)) {
    self.transformClosure = transform
  }
  
  public func transform(val: TypeIn) -> TypeOut {
    return transformClosure(val)
  }
}

extension NSDateFormatter: TwoWayTransformer {
  public typealias TypeIn = NSDate
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromDate(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn {
    return dateFromString(val)!
  }
}

extension NSNumberFormatter: TwoWayTransformer {
  public typealias TypeIn = NSNumber
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromNumber(val) ?? ""
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn {
    return numberFromString(val) ?? 0
  }
}

extension NSDateComponentsFormatter: OneWayTransformer {
  public typealias TypeIn = NSDateComponents
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromDateComponents(val) ?? ""
  }
}

extension NSByteCountFormatter: OneWayTransformer {
  public typealias TypeIn = Int64
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromByteCount(val)
  }
}

extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromDistance(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn {
    return distanceFromString(val)
  }
}