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

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        id: j['id'] as int,
        name: j['name'] as String,
        basePrice: (j['base_price'] as num).toDouble(),
        modifierGroups: (j['modifier_groups'] as List<dynamic>? ?? [])
            .map((g) => ModifierGroup.fromJson(g as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'base_price': basePrice,
        'modifier_groups': modifierGroups.map((g) => g.toJson()).toList(),
      };
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

  factory ModifierGroup.fromJson(Map<String, dynamic> j) => ModifierGroup(
        id: j['id'] as int,
        groupName: j['group_name'] as String,
        isRequired: j['is_required'] as bool? ?? false,
        maxSelection: j['max_selection'] as int? ?? 1,
        options: (j['options'] as List<dynamic>? ?? [])
            .map((o) => ModifierOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_name': groupName,
        'is_required': isRequired,
        'max_selection': maxSelection,
        'options': options.map((o) => o.toJson()).toList(),
      };
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

  factory ModifierOption.fromJson(Map<String, dynamic> j) => ModifierOption(
        id: j['id'] as int,
        name: j['name'] as String,
        extraPrice: (j['extra_price'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'extra_price': extraPrice,
      };
}
