// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewTransaction {

 String get customerId; TransactionType get type; Money get amount; DateTime get occurredAt; String? get note;
/// Create a copy of NewTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewTransactionCopyWith<NewTransaction> get copyWith => _$NewTransactionCopyWithImpl<NewTransaction>(this as NewTransaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NewTransaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewTransaction&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as NewTransaction;
  return Object.hash(runtimeType,_this.customerId,_this.type,_this.amount,_this.occurredAt,_this.note);
}



}

/// @nodoc
abstract mixin class $NewTransactionCopyWith<$Res>  {
  factory $NewTransactionCopyWith(NewTransaction value, $Res Function(NewTransaction) _then) = _$NewTransactionCopyWithImpl;
@useResult
$Res call({
 String customerId, TransactionType type, Money amount, DateTime occurredAt, String? note
});




}
/// @nodoc
class _$NewTransactionCopyWithImpl<$Res>
    implements $NewTransactionCopyWith<$Res> {
  _$NewTransactionCopyWithImpl(this._self, this._then);

  final NewTransaction _self;
  final $Res Function(NewTransaction) _then;

/// Create a copy of NewTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? type = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,}) {
  return _then(NewTransaction(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewTransaction].
extension NewTransactionPatterns on NewTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewTransaction value)  $default,){
final _that = this;
switch (_that) {
case _NewTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _NewTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customerId,  TransactionType type,  Money amount,  DateTime occurredAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewTransaction() when $default != null:
return $default(_that.customerId,_that.type,_that.amount,_that.occurredAt,_that.note);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customerId,  TransactionType type,  Money amount,  DateTime occurredAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _NewTransaction():
return $default(_that.customerId,_that.type,_that.amount,_that.occurredAt,_that.note);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customerId,  TransactionType type,  Money amount,  DateTime occurredAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _NewTransaction() when $default != null:
return $default(_that.customerId,_that.type,_that.amount,_that.occurredAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _NewTransaction implements NewTransaction {
  const _NewTransaction({required this.customerId, required this.type, required this.amount, required this.occurredAt, this.note});
  

@override final  String customerId;
@override final  TransactionType type;
@override final  Money amount;
@override final  DateTime occurredAt;
@override final  String? note;

/// Create a copy of NewTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewTransactionCopyWith<_NewTransaction> get copyWith => __$NewTransactionCopyWithImpl<_NewTransaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewTransaction&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerId,type,amount,occurredAt,note);
}



}

/// @nodoc
abstract mixin class _$NewTransactionCopyWith<$Res> implements $NewTransactionCopyWith<$Res> {
  factory _$NewTransactionCopyWith(_NewTransaction value, $Res Function(_NewTransaction) _then) = __$NewTransactionCopyWithImpl;
@override @useResult
$Res call({
 String customerId, TransactionType type, Money amount, DateTime occurredAt, String? note
});




}
/// @nodoc
class __$NewTransactionCopyWithImpl<$Res>
    implements _$NewTransactionCopyWith<$Res> {
  __$NewTransactionCopyWithImpl(this._self, this._then);

  final _NewTransaction _self;
  final $Res Function(_NewTransaction) _then;

/// Create a copy of NewTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? type = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,}) {
  return _then(_NewTransaction(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
