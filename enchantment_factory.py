def enchantment_factory(enchantment_type):
    """Create a function that applies a specific enchantment to an item.

    Args:
        enchantment_type: The type of enchantment to apply (e.g., "Flaming").

    Returns:
        A function that takes an item name and returns the enchanted description
        in the format "enchantment_type item_name" (e.g., "Flaming Sword").
    """
    def enchant(item_name):
        return f"{enchantment_type} {item_name}"
    return enchant
