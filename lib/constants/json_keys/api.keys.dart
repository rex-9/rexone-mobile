/// Centralized JSON keys for API envelope, pagination, and JSONAPI structure.
/// Shared across all modules and used in both requests and responses.
class ApiKeys {
  const ApiKeys._();

  // ===== API Envelope =====
  static const status = 'status';
  static const code = 'code';
  static const data = 'data';
  static const success = 'success';
  static const error = 'error';
  static const message = 'message';
  static const meta = 'meta';
  static const pagination = 'pagination';

  // ===== Pagination Meta =====
  static const page = 'page';
  static const currentPage = 'current_page';
  static const totalPages = 'total_pages';
  static const totalCount = 'total_count';
  static const limit = 'limit';
  static const nextPage = 'next_page';
  static const prevPage = 'prev_page';

  // ===== JSONAPI Structure =====
  static const id = 'id';
  static const attributes = 'attributes';

  // ===== Common Payload Fields =====
  static const timestamp = 'timestamp';
  static const currentRoute = 'current_route';
}
