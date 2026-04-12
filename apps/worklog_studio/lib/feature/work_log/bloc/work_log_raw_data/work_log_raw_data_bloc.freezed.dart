// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_log_raw_data_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkLogRawDataEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkLogRawDataEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkLogRawDataEvent()';
}


}

/// @nodoc
class $WorkLogRawDataEventCopyWith<$Res>  {
$WorkLogRawDataEventCopyWith(WorkLogRawDataEvent _, $Res Function(WorkLogRawDataEvent) __);
}


/// Adds pattern-matching-related methods to [WorkLogRawDataEvent].
extension WorkLogRawDataEventPatterns on WorkLogRawDataEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadWorkLogRawDataEvent value)?  load,TResult Function( _RefreshWorkLogRawDataEvent value)?  refresh,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadWorkLogRawDataEvent() when load != null:
return load(_that);case _RefreshWorkLogRawDataEvent() when refresh != null:
return refresh(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadWorkLogRawDataEvent value)  load,required TResult Function( _RefreshWorkLogRawDataEvent value)  refresh,}){
final _that = this;
switch (_that) {
case _LoadWorkLogRawDataEvent():
return load(_that);case _RefreshWorkLogRawDataEvent():
return refresh(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadWorkLogRawDataEvent value)?  load,TResult? Function( _RefreshWorkLogRawDataEvent value)?  refresh,}){
final _that = this;
switch (_that) {
case _LoadWorkLogRawDataEvent() when load != null:
return load(_that);case _RefreshWorkLogRawDataEvent() when refresh != null:
return refresh(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( Completer<void>? completer)?  refresh,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadWorkLogRawDataEvent() when load != null:
return load();case _RefreshWorkLogRawDataEvent() when refresh != null:
return refresh(_that.completer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( Completer<void>? completer)  refresh,}) {final _that = this;
switch (_that) {
case _LoadWorkLogRawDataEvent():
return load();case _RefreshWorkLogRawDataEvent():
return refresh(_that.completer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( Completer<void>? completer)?  refresh,}) {final _that = this;
switch (_that) {
case _LoadWorkLogRawDataEvent() when load != null:
return load();case _RefreshWorkLogRawDataEvent() when refresh != null:
return refresh(_that.completer);case _:
  return null;

}
}

}

/// @nodoc


class _LoadWorkLogRawDataEvent implements WorkLogRawDataEvent {
  const _LoadWorkLogRawDataEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadWorkLogRawDataEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkLogRawDataEvent.load()';
}


}




/// @nodoc


class _RefreshWorkLogRawDataEvent implements WorkLogRawDataEvent {
  const _RefreshWorkLogRawDataEvent({this.completer});
  

 final  Completer<void>? completer;

/// Create a copy of WorkLogRawDataEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshWorkLogRawDataEventCopyWith<_RefreshWorkLogRawDataEvent> get copyWith => __$RefreshWorkLogRawDataEventCopyWithImpl<_RefreshWorkLogRawDataEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshWorkLogRawDataEvent&&(identical(other.completer, completer) || other.completer == completer));
}


@override
int get hashCode => Object.hash(runtimeType,completer);

@override
String toString() {
  return 'WorkLogRawDataEvent.refresh(completer: $completer)';
}


}

/// @nodoc
abstract mixin class _$RefreshWorkLogRawDataEventCopyWith<$Res> implements $WorkLogRawDataEventCopyWith<$Res> {
  factory _$RefreshWorkLogRawDataEventCopyWith(_RefreshWorkLogRawDataEvent value, $Res Function(_RefreshWorkLogRawDataEvent) _then) = __$RefreshWorkLogRawDataEventCopyWithImpl;
@useResult
$Res call({
 Completer<void>? completer
});




}
/// @nodoc
class __$RefreshWorkLogRawDataEventCopyWithImpl<$Res>
    implements _$RefreshWorkLogRawDataEventCopyWith<$Res> {
  __$RefreshWorkLogRawDataEventCopyWithImpl(this._self, this._then);

  final _RefreshWorkLogRawDataEvent _self;
  final $Res Function(_RefreshWorkLogRawDataEvent) _then;

/// Create a copy of WorkLogRawDataEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? completer = freezed,}) {
  return _then(_RefreshWorkLogRawDataEvent(
completer: freezed == completer ? _self.completer : completer // ignore: cast_nullable_to_non_nullable
as Completer<void>?,
  ));
}


}

/// @nodoc
mixin _$WorkLogRawDataState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkLogRawDataState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkLogRawDataState()';
}


}

/// @nodoc
class $WorkLogRawDataStateCopyWith<$Res>  {
$WorkLogRawDataStateCopyWith(WorkLogRawDataState _, $Res Function(WorkLogRawDataState) __);
}


/// Adds pattern-matching-related methods to [WorkLogRawDataState].
extension WorkLogRawDataStatePatterns on WorkLogRawDataState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _IdleWorkLogRawDataState value)?  idle,TResult Function( _LoadingWorkLogRawDataState value)?  progress,TResult Function( _SuccessWorkLogRawDataState value)?  success,TResult Function( _ErrorWorkLogRawDataState value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdleWorkLogRawDataState() when idle != null:
return idle(_that);case _LoadingWorkLogRawDataState() when progress != null:
return progress(_that);case _SuccessWorkLogRawDataState() when success != null:
return success(_that);case _ErrorWorkLogRawDataState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _IdleWorkLogRawDataState value)  idle,required TResult Function( _LoadingWorkLogRawDataState value)  progress,required TResult Function( _SuccessWorkLogRawDataState value)  success,required TResult Function( _ErrorWorkLogRawDataState value)  error,}){
final _that = this;
switch (_that) {
case _IdleWorkLogRawDataState():
return idle(_that);case _LoadingWorkLogRawDataState():
return progress(_that);case _SuccessWorkLogRawDataState():
return success(_that);case _ErrorWorkLogRawDataState():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _IdleWorkLogRawDataState value)?  idle,TResult? Function( _LoadingWorkLogRawDataState value)?  progress,TResult? Function( _SuccessWorkLogRawDataState value)?  success,TResult? Function( _ErrorWorkLogRawDataState value)?  error,}){
final _that = this;
switch (_that) {
case _IdleWorkLogRawDataState() when idle != null:
return idle(_that);case _LoadingWorkLogRawDataState() when progress != null:
return progress(_that);case _SuccessWorkLogRawDataState() when success != null:
return success(_that);case _ErrorWorkLogRawDataState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  progress,TResult Function()?  success,TResult Function( IErrorHandler errorHandler)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdleWorkLogRawDataState() when idle != null:
return idle();case _LoadingWorkLogRawDataState() when progress != null:
return progress();case _SuccessWorkLogRawDataState() when success != null:
return success();case _ErrorWorkLogRawDataState() when error != null:
return error(_that.errorHandler);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  progress,required TResult Function()  success,required TResult Function( IErrorHandler errorHandler)  error,}) {final _that = this;
switch (_that) {
case _IdleWorkLogRawDataState():
return idle();case _LoadingWorkLogRawDataState():
return progress();case _SuccessWorkLogRawDataState():
return success();case _ErrorWorkLogRawDataState():
return error(_that.errorHandler);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  progress,TResult? Function()?  success,TResult? Function( IErrorHandler errorHandler)?  error,}) {final _that = this;
switch (_that) {
case _IdleWorkLogRawDataState() when idle != null:
return idle();case _LoadingWorkLogRawDataState() when progress != null:
return progress();case _SuccessWorkLogRawDataState() when success != null:
return success();case _ErrorWorkLogRawDataState() when error != null:
return error(_that.errorHandler);case _:
  return null;

}
}

}

/// @nodoc


class _IdleWorkLogRawDataState extends WorkLogRawDataState {
  const _IdleWorkLogRawDataState(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdleWorkLogRawDataState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkLogRawDataState.idle()';
}


}




/// @nodoc


class _LoadingWorkLogRawDataState extends WorkLogRawDataState {
  const _LoadingWorkLogRawDataState(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadingWorkLogRawDataState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkLogRawDataState.progress()';
}


}




/// @nodoc


class _SuccessWorkLogRawDataState extends WorkLogRawDataState {
  const _SuccessWorkLogRawDataState(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuccessWorkLogRawDataState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkLogRawDataState.success()';
}


}




/// @nodoc


class _ErrorWorkLogRawDataState extends WorkLogRawDataState {
  const _ErrorWorkLogRawDataState({required this.errorHandler}): super._();
  

 final  IErrorHandler errorHandler;

/// Create a copy of WorkLogRawDataState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorWorkLogRawDataStateCopyWith<_ErrorWorkLogRawDataState> get copyWith => __$ErrorWorkLogRawDataStateCopyWithImpl<_ErrorWorkLogRawDataState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ErrorWorkLogRawDataState&&(identical(other.errorHandler, errorHandler) || other.errorHandler == errorHandler));
}


@override
int get hashCode => Object.hash(runtimeType,errorHandler);

@override
String toString() {
  return 'WorkLogRawDataState.error(errorHandler: $errorHandler)';
}


}

/// @nodoc
abstract mixin class _$ErrorWorkLogRawDataStateCopyWith<$Res> implements $WorkLogRawDataStateCopyWith<$Res> {
  factory _$ErrorWorkLogRawDataStateCopyWith(_ErrorWorkLogRawDataState value, $Res Function(_ErrorWorkLogRawDataState) _then) = __$ErrorWorkLogRawDataStateCopyWithImpl;
@useResult
$Res call({
 IErrorHandler errorHandler
});




}
/// @nodoc
class __$ErrorWorkLogRawDataStateCopyWithImpl<$Res>
    implements _$ErrorWorkLogRawDataStateCopyWith<$Res> {
  __$ErrorWorkLogRawDataStateCopyWithImpl(this._self, this._then);

  final _ErrorWorkLogRawDataState _self;
  final $Res Function(_ErrorWorkLogRawDataState) _then;

/// Create a copy of WorkLogRawDataState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorHandler = null,}) {
  return _then(_ErrorWorkLogRawDataState(
errorHandler: null == errorHandler ? _self.errorHandler : errorHandler // ignore: cast_nullable_to_non_nullable
as IErrorHandler,
  ));
}


}

// dart format on
