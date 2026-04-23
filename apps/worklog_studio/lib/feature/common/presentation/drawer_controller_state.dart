enum DrawerState { closed, create, edit }

class DrawerControllerState<T> {
  final DrawerState state;
  final T? entity;

  const DrawerControllerState._({
    required this.state,
    this.entity,
  }) : assert(
         (state == DrawerState.edit && entity != null) ||
         (state == DrawerState.create && entity == null) ||
         (state == DrawerState.closed && entity == null),
         'Invalid state combination: $state with entity $entity',
       );

  factory DrawerControllerState.create() => const DrawerControllerState._(state: DrawerState.create);
  factory DrawerControllerState.edit(T entity) => DrawerControllerState._(state: DrawerState.edit, entity: entity);
  factory DrawerControllerState.closed() => const DrawerControllerState._(state: DrawerState.closed);

  bool get isOpen => state != DrawerState.closed;
}
