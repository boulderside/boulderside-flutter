enum ProjectSortType {
  latestCreated('LATEST_CREATED'),
  latestUpdated('LATEST_UPDATED');

  const ProjectSortType(this.value);

  final String value;

  @override
  String toString() => value;
}
