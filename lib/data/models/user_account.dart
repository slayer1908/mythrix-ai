/// Minimal user/account model. Backed by the backend identity record.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.role = WorkspaceRole.owner,
    this.workspaceName = 'My Workspace',
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final WorkspaceRole role;
  final String workspaceName;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  UserAccount copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    WorkspaceRole? role,
    String? workspaceName,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      workspaceName: workspaceName ?? this.workspaceName,
    );
  }
}

enum WorkspaceRole { owner, admin, editor, analyst, viewer }

extension WorkspaceRoleX on WorkspaceRole {
  String get displayName {
    switch (this) {
      case WorkspaceRole.owner:
        return 'Owner';
      case WorkspaceRole.admin:
        return 'Admin';
      case WorkspaceRole.editor:
        return 'Editor';
      case WorkspaceRole.analyst:
        return 'Analyst';
      case WorkspaceRole.viewer:
        return 'Viewer';
    }
  }
}
