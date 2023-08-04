part of game;

final _provinceSearch = RM.injectTextEditing();

class _CampaignProvincesView extends ReactiveStatelessWidget {
  const _CampaignProvincesView({
    required this.gameRef,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame gameRef;

  @override
  Widget build(final BuildContext context) {
    final runtimeData = gameRef.campaignRuntimeData;
    final provinces = runtimeData.provinces.values.toList();
    if (provinces.isEmpty) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: _provinceSearch.controller),
        OnBuilder(
          builder: () {
            final filteredProvinces = provinces
                .where(
                  (final province) => province.name
                      .toLowerCase()
                      .contains(_provinceSearch.text.toLowerCase()),
                )
                .toList();
            return Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemBuilder: (final context, final index) {
                  final province = filteredProvinces[index];
                  return ListTile(
                    key: Key(province.id),
                    title: Text(
                      '${province.name}. '
                      'Armies ids: ${province.armies.keys.map((final e) => e.armyId)}',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        gameRef.mapCamera.toProvince(province);
                      },
                      icon: const Icon(
                        Icons.location_on_sharp,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                itemCount: filteredProvinces.length,
              ),
            );
          },
          listenTo: _provinceSearch,
        ),
      ],
    );
  }
}
