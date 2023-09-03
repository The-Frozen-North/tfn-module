// void main() {}
#include "nw_i0_spells"

void DisplaceSpell(object oCreature, int nSpell, string sSpell)
{
    if (!GetHasSpellEffect(nSpell, oCreature)) return;

    string sMessage = "*"+sSpell+" does not stack and has been displaced*";
    if (GetHasSpellEffect(nSpell, oCreature))
    {
        // do not display any message if we are replacing it with the same exact spell
        if (GetHasSpellEffect(nSpell, oCreature) != nSpell) 
        {
            FloatingTextStringOnCreature(sMessage, oCreature, FALSE);
            if (OBJECT_SELF != oCreature)
            {
                FloatingTextStringOnCreature(sMessage, OBJECT_SELF, FALSE);
            }
        }

        RemoveEffectsFromSpell(oCreature, nSpell);
    }
}

void RemoveElementalResistanceSpellEffects(object oCreature)
{
    DisplaceSpell(oCreature, SPELL_ENDURE_ELEMENTS, "Endure Elements");
    DisplaceSpell(oCreature, SPELL_RESIST_ELEMENTS, "Resist Elements");
    DisplaceSpell(oCreature, SPELL_PROTECTION_FROM_ELEMENTS, "Protection from Elements");
    DisplaceSpell(oCreature, SPELL_ENERGY_BUFFER, "Energy Buffer");
}

void RemoveDamageReductionSpellEffects(object oCreature)
{
    DisplaceSpell(oCreature, SPELL_STONESKIN, "Stoneskin");
    DisplaceSpell(oCreature, SPELL_GREATER_STONESKIN, "Greater Stoneskin");
    DisplaceSpell(oCreature, SPELL_PREMONITION, "Premonition");
}

void RemoveAnimalSpellEffects(object oCreature)
{
    DisplaceSpell(oCreature, SPELL_BULLS_STRENGTH, "Bull's Strength");
    DisplaceSpell(oCreature, SPELL_CATS_GRACE, "Cat's Grace");
    DisplaceSpell(oCreature, SPELL_ENDURANCE, "Endurance");
    DisplaceSpell(oCreature, SPELL_FOXS_CUNNING, "Fox's Cunning");
    DisplaceSpell(oCreature, SPELL_OWLS_WISDOM, "Owl's Wisdom");
    DisplaceSpell(oCreature, SPELL_EAGLE_SPLEDOR, "Eagle's Splendor");
}

void RemoveClericAttackDamageBonusSpellEffects(object oCreature)
{
   DisplaceSpell(oCreature, SPELL_DIVINE_FAVOR, "Divine Favor");
   DisplaceSpell(oCreature, SPELL_DIVINE_POWER, "Divine Power");
   DisplaceSpell(oCreature, SPELL_PRAYER, "Prayer");
   DisplaceSpell(oCreature, SPELL_BATTLETIDE, "Battletide");
}

void RemoveClericArmorClassSpellEffects(object oCreature)
{
   DisplaceSpell(oCreature, SPELL_SHIELD_OF_FAITH, "Shield of Faith");
   DisplaceSpell(oCreature, SPELL_MAGIC_VESTMENT, "Magic Vestment");
   //DisplaceSpell(oCreature, SPELL_PROTECTION_FROM_EVIL, "Protection from Evil");
   //DisplaceSpell(oCreature, SPELL_PROTECTION_FROM_GOOD, "Protection from Good");
   //DisplaceSpell(oCreature, SPELL_MAGIC_CIRCLE_AGAINST_EVIL, "Magic Circle against Evil");
   //DisplaceSpell(oCreature, SPELL_MAGIC_CIRCLE_AGAINST_GOOD, "Magic Circle against Good");
}

int GetIsProtectedFromEvil(object oCreature)
{
    if (GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL, oCreature))
    {
        return 1;
    }
    // Testing suggests this should also work, including on things just standing in the circle
    if (GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, oCreature))
    {
        return 1;
    }
    return 0;
}
