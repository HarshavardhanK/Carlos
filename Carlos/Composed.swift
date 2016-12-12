import Foundation
import PiedPiper

infix operator >>> { associativity left }

/**
Composes two cache closures

- parameter firstFetcher: The first cache closure
- parameter secondFetcher: The second cache closure

- returns: A new cache level that is the result of the composition of the two cache closures
*/
@available(*, deprecated: 0.5)
public func compose<A, B>(_ firstFetcher: (_ key: A) -> Future<B>, secondFetcher: (_ key: A) -> Future<B>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(firstFetcher) >>> wrapClosureIntoFetcher(secondFetcher)
}

extension CacheLevel {
  
  /**
  Composes two cache levels
  
  - parameter cache: The second cache level
  
  - returns: A new cache level that is the result of the composition of the two cache levels
  */
  public func compose<A: CacheLevel>(_ cache: A) -> BasicCache<A.KeyType, A.OutputType> where A.KeyType == KeyType, A.OutputType == OutputType {
    return BasicCache(
      getClosure: { key in
        let request = Promise<A.OutputType>()
        
        self.get(key)
          .onSuccess(request.succeed)
          .onCancel(request.cancel)
          .onFailure { error in
            request.mimic(cache.get(key).map { result in
              self.set(result, forKey: key)
              return result
            })
        }
        
        return request.future
      },
      setClosure: { (value, key) in
        let firstWrite = self.set(value, forKey: key)
        let secondWrite = cache.set(value, forKey: key)
        
        return firstWrite.flatMap { secondWrite }
      },
      clearClosure: {
        self.clear()
        cache.clear()
      },
      memoryClosure: {
        self.onMemoryWarning()
        cache.onMemoryWarning()
      }
    )
  }
  
  /**
  Composes the cache level with a cache closure
  
  - parameter fetchClosure: The cache closure
  
  - returns: A new cache level that is the result of the composition of the cache level with the cache closure
   */
  @available(*, deprecated: 0.7)
  public func compose(_ fetchClosure: (_ key: KeyType) -> Future<OutputType>) -> BasicCache<KeyType, OutputType> {
    return self.compose(wrapClosureIntoFetcher(fetchClosure))
  }
}

/**
Composes two cache levels

- parameter firstCache: The first cache level
- parameter secondCache: The second cache level

- returns: A new cache level that is the result of the composition of the two cache levels
*/
@available(*, deprecated: 0.5)
public func compose<A: CacheLevel, B: CacheLevel>(_ firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> where A.KeyType == B.KeyType, A.OutputType == B.OutputType {
  return firstCache.compose(secondCache)
}

/**
Composes a cache level with a cache closure

- parameter cache: The cache level
- parameter fetchClosure: The cache closure

- returns: A new cache level that is the result of the composition of the cache level with the cache closure
*/
@available(*, deprecated: 0.5)
public func compose<A: CacheLevel>(_ cache: A, fetchClosure: (_ key: A.KeyType) -> Future<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.compose(wrapClosureIntoFetcher(fetchClosure))
}

/**
Composes a cache closure with a cache level

- parameter fetchClosure: The cache closure
- parameter cache: The cache level

- returns: A new cache level that is the result of the composition of the cache closure with the cache level
*/
@available(*, deprecated: 0.5)
public func compose<A: CacheLevel>(_ fetchClosure: (_ key: A.KeyType) -> Future<A.OutputType>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return wrapClosureIntoFetcher(fetchClosure).compose(cache)
}

/**
Composes two cache closures

- parameter firstFetcher: The first cache closure
- parameter secondFetcher: The second cache closure

- returns: A new cache level that is the result of the composition of the two cache closures
 */
@available(*, deprecated: 0.7)
public func >>><A, B>(firstFetcher: (_ key: A) -> Future<B>, secondFetcher: (_ key: A) -> Future<B>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(firstFetcher).compose(wrapClosureIntoFetcher(secondFetcher))
}

/**
Composes two cache levels

- parameter firstCache: The first cache level
- parameter secondCache: The second cache level

- returns: A new cache level that is the result of the composition of the two cache levels
*/
public func >>><A: CacheLevel, B: CacheLevel>(firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> where A.KeyType == B.KeyType, A.OutputType == B.OutputType {
  return firstCache.compose(secondCache)
}

/**
Composes a cache level with a cache closure

- parameter cache: The cache level
- parameter fetchClosure: The cache closure

- returns: A new cache level that is the result of the composition of the cache level with the cache closure
 */
@available(*, deprecated: 0.7)
public func >>><A: CacheLevel>(cache: A, fetchClosure: (_ key: A.KeyType) -> Future<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.compose(wrapClosureIntoFetcher(fetchClosure))
}

/**
Composes a cache closure with a cache level

- parameter fetchClosure: The cache closure
- parameter cache: The cache level

- returns: A new cache level that is the result of the composition of the cache closure with the cache level
 */
@available(*, deprecated: 0.7)
public func >>><A: CacheLevel>(fetchClosure: (_ key: A.KeyType) -> Future<A.OutputType>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return wrapClosureIntoFetcher(fetchClosure).compose(cache)
}
