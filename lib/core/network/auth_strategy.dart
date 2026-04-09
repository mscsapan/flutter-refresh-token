/// Defines how the auth token is attached to an outgoing request.
enum AuthStrategy {
  /// Default: `Authorization: Bearer <token>` header.
  header,

  /// Token sent as a query parameter: `?token=<token>`.
  queryParam,

  /// No token attached (public endpoints, refresh endpoint).
  none,
}
