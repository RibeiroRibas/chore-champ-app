import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TodayAssigneeListMode { all, mine, member }

class TodayChoresAssigneeListFilter {
  const TodayChoresAssigneeListFilter._(this.mode, [this._memberUserId]);

  const TodayChoresAssigneeListFilter.all()
      : this._(TodayAssigneeListMode.all);
  const TodayChoresAssigneeListFilter.mine()
      : this._(TodayAssigneeListMode.mine);
  const TodayChoresAssigneeListFilter.member(String userId)
      : this._(TodayAssigneeListMode.member, userId);

  final TodayAssigneeListMode mode;
  final String? _memberUserId;

  int? toAssignedToUserIdQueryParam(String currentMemberId) {
    switch (mode) {
      case TodayAssigneeListMode.all:
        return null;
      case TodayAssigneeListMode.mine:
        return int.parse(currentMemberId);
      case TodayAssigneeListMode.member:
        return int.parse(_memberUserId!);
    }
  }

  bool get isAll => mode == TodayAssigneeListMode.all;
  bool get isMine => mode == TodayAssigneeListMode.mine;
  bool isMember(String userId) =>
      mode == TodayAssigneeListMode.member && _memberUserId == userId;

  /// Id do membro quando o filtro é por pessoa; caso contrário `null`.
  String? get memberUserIdIfSelected =>
      mode == TodayAssigneeListMode.member ? _memberUserId : null;

  @override
  bool operator ==(Object other) =>
      other is TodayChoresAssigneeListFilter &&
      other.mode == mode &&
      other._memberUserId == _memberUserId;

  @override
  int get hashCode => Object.hash(mode, _memberUserId);
}

class TodayChoresAssigneeFilterNotifier
    extends Notifier<TodayChoresAssigneeListFilter> {
  @override
  TodayChoresAssigneeListFilter build() =>
      const TodayChoresAssigneeListFilter.mine();

  void setAll() => state = const TodayChoresAssigneeListFilter.all();
  void setMine() => state = const TodayChoresAssigneeListFilter.mine();
  void setMember(String userId) =>
      state = TodayChoresAssigneeListFilter.member(userId);
}

final todayChoresAssigneeFilterProvider = NotifierProvider<
    TodayChoresAssigneeFilterNotifier,
    TodayChoresAssigneeListFilter>(TodayChoresAssigneeFilterNotifier.new);
