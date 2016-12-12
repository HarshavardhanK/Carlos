import Foundation
import PiedPiper

extension Future {
  
  /**
  Mutates a Future from a type A to a type B through a OneWayTransformer

  - parameter origin: The original Future
  - parameter transformer: The OneWayTransformer from A to B

  - returns: A new Future<B>
  */
  internal func mutate<A: OneWayTransformer>(_ transformer: A) -> Future<A.TypeOut> where A.TypeIn == T {
    return flatMap(transformer.transform)
  }

  /**
  Mutates a Future from a type A to a type B through a OneWayTransformer

  - parameter origin: The original Future
  - parameter transformerClosure: The transformation closure from A to B

  - returns: A new Future<B>
   */
  @available(*, deprecated: 0.7)
  internal func mutate<A>(_ transformerClosure: (T) -> Future<A>) -> Future<A> {
    return self.mutate(wrapClosureIntoOneWayTransformer(transformerClosure))
  }
}

extension CacheLevel {
  
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the value the cache returns when succeeding
  Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types
  
  - parameter transformer: The transformation you want to apply
  
  - returns: A new cache result of the transformation of the original cache
  */
  public func transformValues<A: TwoWayTransformer>(_ transformer: A) -> BasicCache<KeyType, A.TypeOut> where OutputType == A.TypeIn {
    return BasicCache(
      getClosure: { key in
        return self.get(key).mutate(transformer)
      },
      setClosure: { (value, key) in
        return transformer.inverseTransform(value).flatMap { transformedValue in
          self.set(transformedValue, forKey: key)
        }
      },
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache result of the transformation of the original cache
*/
@available(*, deprecated: 0.5)
public func transformValues<A: CacheLevel, B: TwoWayTransformer>(_ cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> where A.OutputType == B.TypeIn {
  return cache.transformValues(transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache result of the transformation of the original cache
*/
public func =>><A: CacheLevel, B: TwoWayTransformer>(cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> where A.OutputType == B.TypeIn {
  return cache.transformValues(transformer)
}
