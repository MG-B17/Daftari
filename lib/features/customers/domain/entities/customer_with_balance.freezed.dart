// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_with_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerWithBalance {

 Customer get customer; Money get balance;
/// Create a copy of CustomerWithBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerWithBalanceCopyWith<CustomerWithBalance> get copyWith => _$CustomerWithBalanceCopyWithImpl<CustomerWithBalance>(this as CustomerWithBalance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerWithBalance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerWithBalance&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.balance, _this.balance) || other.balance == _this.balance));
}


@override
int get hashCode {
  final _this = this as CustomerWithBalance;
  return Object.hash(runtimeType,_this.customer,_this.balance);
}



}

/// @nodoc
abstract mixin class $CustomerWithBalanceCopyWith<$Res>  {
  factory $CustomerWithBalanceCopyWith(CustomerWithBalance value, $Res Function(CustomerWithBalance) _then) = _$CustomerWithBalanceCopyWithImpl;
@useResult
$Res call({
 Customer customer, Money balance
});


$CustomerCopyWith<$Res> get customer;

}
/// @nodoc
class _$CustomerWithBalanceCopyWithImpl<$Res>
    implements $CustomerWithBalanceCopyWith<$Res> {
  _$CustomerWithBalanceCopyWithImpl(this._self, this._then);

  final CustomerWithBalance _self;
  final $Res Function(CustomerWithBalance) _then;

/// Create a copy of CustomerWithBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customer = null,Object? balance = null,}) {
  return _then(CustomerWithBalance(
customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}
/// Create a copy of CustomerWithBalance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res> get customer {
  
  return $CustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerWithBalance].
extension CustomerWithBalancePatterns on CustomerWithBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerWithBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerWithBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerWithBalance value)  $default,){
final _that = this;
switch (_that) {
case _CustomerWithBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerWithBalance value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerWithBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Customer customer,  Money balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerWithBalance() when $default != null:
return $default(_that.customer,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Customer customer,  Money balance)  $default,) {final _that = this;
switch (_that) {
case _CustomerWithBalance():
return $default(_that.customer,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Customer customer,  Money balance)?  $default,) {final _that = this;
switch (_that) {
case _CustomerWithBalance() when $default != null:
return $default(_that.customer,_that.balance);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerWithBalance implements CustomerWithBalance {
  const _CustomerWithBalance({required this.customer, required this.balance});
  

@override final  Customer customer;
@override final  Money balance;

/// Create a copy of CustomerWithBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerWithBalanceCopyWith<_CustomerWithBalance> get copyWith => __$CustomerWithBalanceCopyWithImpl<_CustomerWithBalance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerWithBalance&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.balance, balance) || other.balance == balance));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customer,balance);
}



}

/// @nodoc
abstract mixin class _$CustomerWithBalanceCopyWith<$Res> implements $CustomerWithBalanceCopyWith<$Res> {
  factory _$CustomerWithBalanceCopyWith(_CustomerWithBalance value, $Res Function(_CustomerWithBalance) _then) = __$CustomerWithBalanceCopyWithImpl;
@override @useResult
$Res call({
 Customer customer, Money balance
});


@override $CustomerCopyWith<$Res> get customer;

}
/// @nodoc
class __$CustomerWithBalanceCopyWithImpl<$Res>
    implements _$CustomerWithBalanceCopyWith<$Res> {
  __$CustomerWithBalanceCopyWithImpl(this._self, this._then);

  final _CustomerWithBalance _self;
  final $Res Function(_CustomerWithBalance) _then;

/// Create a copy of CustomerWithBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customer = null,Object? balance = null,}) {
  return _then(_CustomerWithBalance(
customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

/// Create a copy of CustomerWithBalance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res> get customer {
  
  return $CustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on
