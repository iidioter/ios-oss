import Argo
import Curry
import Runes

public struct Comment {
  public private(set) var author: User
  public private(set) var body: String
  public private(set) var createdAt: TimeInterval
  public private(set) var deletedAt: TimeInterval?
  public private(set) var id: Int
}

extension Comment: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Comment> {
    let create = curry(Comment.init)
    let tmp = create
      <^> json <| "author"
      <*> json <| "body"
      <*> json <| "created_at"
    return tmp
      <*> (json <|? "deleted_at" >>- decodePositiveTimeInterval)
      <*> json <| "id"
  }
}

extension Comment: Equatable {
}
public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}

// Decode a time interval so that non-positive values are coalesced to `nil`. We do this because the API
// sends back `0` when the comment hasn't been deleted, and we'd rather handle that value as `nil`.
private func decodePositiveTimeInterval(_ interval: TimeInterval?) -> Decoded<TimeInterval?> {
  if let interval = interval, interval > 0.0 {
    return .success(interval)
  }
  return .success(nil)
}
