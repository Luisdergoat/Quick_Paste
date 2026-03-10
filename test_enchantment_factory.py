import unittest
from enchantment_factory import enchantment_factory


class TestEnchantmentFactory(unittest.TestCase):

    def test_returns_callable(self):
        flaming = enchantment_factory("Flaming")
        self.assertTrue(callable(flaming))

    def test_flaming_sword(self):
        flaming = enchantment_factory("Flaming")
        self.assertEqual(flaming("Sword"), "Flaming Sword")

    def test_frozen_axe(self):
        frozen = enchantment_factory("Frozen")
        self.assertEqual(frozen("Axe"), "Frozen Axe")

    def test_electric_shield(self):
        electric = enchantment_factory("Electric")
        self.assertEqual(electric("Shield"), "Electric Shield")

    def test_different_factories_are_independent(self):
        flaming = enchantment_factory("Flaming")
        frozen = enchantment_factory("Frozen")
        self.assertEqual(flaming("Bow"), "Flaming Bow")
        self.assertEqual(frozen("Bow"), "Frozen Bow")

    def test_same_factory_multiple_items(self):
        enchant = enchantment_factory("Cursed")
        self.assertEqual(enchant("Ring"), "Cursed Ring")
        self.assertEqual(enchant("Dagger"), "Cursed Dagger")
        self.assertEqual(enchant("Armor"), "Cursed Armor")


if __name__ == "__main__":
    unittest.main()
