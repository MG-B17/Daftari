// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerQuery {

 String get searchText; CustomerFilter get filter; CustomerSort get sort;
/// Create a copy of CustomerQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerQueryCopyWith<CustomerQuery> get copyWith => _$CustomerQueryCopyWithImpl<CustomerQuery>(this as CustomerQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerQuery&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.filter, _this.filter) || other.filter == _this.filter)&&(identical(other.sort, _this.sort) || other.sort == _this.sort));
}


@override
int get hashCode {
  final _this = this as CustomerQuery;
  return Object.hash(runtimeType,_this.searchText,_this.filter,_this.sort);
}



}

/// @nodoc
abstract mixin class $CustomerQueryCopyWith<$Res>  {
  factory $CustomerQueryCopyWith(CustomerQuery value, $Res Function(CustomerQuery) _then) = _$CustomerQueryCopyWithImpl;
@useResult
$Res call({
 String searchText, CustomerFilter filter, CustomerSort sort
});




}
/// @nodoc
class _$CustomerQueryCopyWithImpl<$Res>
    implements $CustomerQueryCopyWith<$Res> {
  _$CustomerQueryCopyWithImpl(this._self, this._then);

  final CustomerQuery _self;
  final $Res Function(CustomerQuery) _then;

/// Create a copy of CustomerQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchText = null,Object? filter = null,Object? sort = null,}) {
  return _then(CustomerQuery(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CustomerFilter,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CustomerSort,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerQuery].
extension CustomerQueryPatterns on CustomerQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerQuery value)  $default,){
final _that = this;
switch (_that) {
case _CustomerQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerQuery value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchText,  CustomerFilter filter,  CustomerSort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerQuery() when $default != null:
return $default(_that.searchText,_that.filter,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchText,  CustomerFilter filter,  CustomerSort sort)  $default,) {final _that = this;
switch (_that) {
case _CustomerQuery():
return $default(_that.searchText,_that.filter,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchText,  CustomerFilter filter,  CustomerSort sort)?  $default,) {final _that = this;
switch (_that) {
case _CustomerQuery() when $default != null:
return $default(_that.searchText,_that.filter,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerQuery implements CustomerQuery {
  const _CustomerQuery({required this.searchText, required this.filter, required this.sort});
  

@override final  String searchText;
@override final  CustomerFilter filter;
@override final  CustomerSort sort;

/// Create a copy of CustomerQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerQueryCopyWith<_CustomerQuery> get copyWith => __$CustomerQueryCopyWithImpl<_CustomerQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerQuery&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText,filter,sort);
}



}

/// @nodoc
abstract mixin class _$CustomerQueryCopyWith<$Res> implements $CustomerQueryCopyWith<$Res> {
  factory _$CustomerQueryCopyWith(_CustomerQuery value, $Res Function(_CustomerQuery) _then) = __$CustomerQueryCopyWithImpl;
@override @useResult
$Res call({
 String searchText, CustomerFilter filter, CustomerSort sort
});




}
/// @nodoc
class __$CustomerQueryCopyWithImpl<$Res>
    implements _$CustomerQueryCopyWith<$Res> {
  __$CustomerQueryCopyWithImpl(this._self, this._then);

  final _CustomerQuery _self;
  final $Res Function(_CustomerQuery) _then;

/// Create a copy of CustomerQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? filter = null,Object? sort = null,}) {
  return _then(_CustomerQuery(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CustomerFilter,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CustomerSort,
  ));
}


}

// dart format on
