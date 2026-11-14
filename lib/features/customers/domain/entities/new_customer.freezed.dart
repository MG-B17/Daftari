// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewCustomer {

 String get name; String? get phone; String? get note;
/// Create a copy of NewCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewCustomerCopyWith<NewCustomer> get copyWith => _$NewCustomerCopyWithImpl<NewCustomer>(this as NewCustomer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NewCustomer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewCustomer&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as NewCustomer;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.note);
}



}

/// @nodoc
abstract mixin class $NewCustomerCopyWith<$Res>  {
  factory $NewCustomerCopyWith(NewCustomer value, $Res Function(NewCustomer) _then) = _$NewCustomerCopyWithImpl;
@useResult
$Res call({
 String name, String? phone, String? note
});




}
/// @nodoc
class _$NewCustomerCopyWithImpl<$Res>
    implements $NewCustomerCopyWith<$Res> {
  _$NewCustomerCopyWithImpl(this._self, this._then);

  final NewCustomer _self;
  final $Res Function(NewCustomer) _then;

/// Create a copy of NewCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = freezed,Object? note = freezed,}) {
  return _then(NewCustomer(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewCustomer].
extension NewCustomerPatterns on NewCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewCustomer value)  $default,){
final _that = this;
switch (_that) {
case _NewCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _NewCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? phone,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewCustomer() when $default != null:
return $default(_that.name,_that.phone,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? phone,  String? note)  $default,) {final _that = this;
switch (_that) {
case _NewCustomer():
return $default(_that.name,_that.phone,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? phone,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _NewCustomer() when $default != null:
return $default(_that.name,_that.phone,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _NewCustomer implements NewCustomer {
  const _NewCustomer({required this.name, this.phone, this.note});
  

@override final  String name;
@override final  String? phone;
@override final  String? note;

/// Create a copy of NewCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewCustomerCopyWith<_NewCustomer> get copyWith => __$NewCustomerCopyWithImpl<_NewCustomer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewCustomer&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,note);
}



}

/// @nodoc
abstract mixin class _$NewCustomerCopyWith<$Res> implements $NewCustomerCopyWith<$Res> {
  factory _$NewCustomerCopyWith(_NewCustomer value, $Res Function(_NewCustomer) _then) = __$NewCustomerCopyWithImpl;
@override @useResult
$Res call({
 String name, String? phone, String? note
});




}
/// @nodoc
class __$NewCustomerCopyWithImpl<$Res>
    implements _$NewCustomerCopyWith<$Res> {
  __$NewCustomerCopyWithImpl(this._self, this._then);

  final _NewCustomer _self;
  final $Res Function(_NewCustomer) _then;

/// Create a copy of NewCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = freezed,Object? note = freezed,}) {
  return _then(_NewCustomer(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
