part of 'my_user_bloc.dart';

enum MyUserStatus { success, loading, failure }

class MyUserState extends Equatable {
  final MyUserStatus status;
  final MyUser? user;

  const MyUserState({
    this.status = MyUserStatus.loading,
    this.user,
  });

  const MyUserState.initial() : this();
  const MyUserState.loading() : this(status: MyUserStatus.loading);

  const MyUserState.success(MyUser user)
      : this(status: MyUserStatus.success, user: user);

  const MyUserState.failure() : this(status: MyUserStatus.failure);

  @override
  List<Object?> get props => [status, user];
}
