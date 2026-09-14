/// Request/response keys for auth endpoints and user payloads.
class AuthKeys {
  const AuthKeys._();

  static const email = 'email';
  static const user = 'user';
  static const token = 'token';
  static const signinKey = 'signin_key';
  static const password = 'password';
  static const passwordConfirmation = 'password_confirmation';
  static const confirmationCode = 'confirmation_code';
  static const challengeToken = 'challenge_token';
  static const username = 'username';
  static const name = 'name';

  // ===== Peek / sign-in response =====
  static const userExists = 'user_exists';
  static const confirmed = 'confirmed';
  static const otpSent = 'otp_sent';
  static const remainingAttempts = 'remaining_attempts';
  static const cooldownRemaining = 'cooldown_remaining';
  static const passwordRequired = 'password_required';

  // ===== User model =====
  static const provider = 'provider';
  static const avatarUrl = 'avatar_url';
  static const photo = 'photo';
  static const iam = 'iam';
  static const isAdmin = 'is_admin';
  static const isSuperAdmin = 'is_super_admin';
  static const roles = 'roles';
  static const adminRoles = 'admin_roles';
  static const nonAdminRoles = 'non_admin_roles';
  static const permissions = 'permissions';
  static const adminPermissions = 'admin_permissions';
  static const nonAdminPermissions = 'non_admin_permissions';
  static const attributes = 'attributes';
  static const resourceType = 'type';
  static const roleResourceType = 'role';
  static const permissionResourceType = 'permission';
  static const action = 'action';
  static const resource = 'resource';
  static const description = 'description';
  static const system = 'system';
}
