class FoodItem {
  final int id;
  final String name;
  final double basePrice;
  final List<ModifierGroup> modifierGroups;

  FoodItem({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.modifierGroups,
  });
}

class ModifierGroup {
  final int id;
  final String groupName;
  final bool isRequired;
  final int maxSelection;
  final List<ModifierOption> options;

  ModifierGroup({
    required this.id,
    required this.groupName,
    required this.isRequired,
    required this.maxSelection,
    required this.options,
  });
}

class ModifierOption {
  final int id;
  final String name;
  final double extraPrice;

  ModifierOption({
    required this.id,
    required this.name,
    required this.extraPrice,
  });
}
