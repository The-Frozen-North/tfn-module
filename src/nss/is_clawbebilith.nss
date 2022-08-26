#include "nwnx_creature"

void main()
{
	object oTarget = GetSpellTargetObject();
    
    if (Random(100) < 40)
    {
        effect ePoison = EffectPoison(POISON_BEBILITH_VENOM);
        ePoison = ExtraordinaryEffect(ePoison);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, oTarget);
    }
    
	object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
    int nType = GetBaseItemType(oShield);
    // we actually have a shield here
    if (nType != BASE_ITEM_LARGESHIELD && nType != BASE_ITEM_SMALLSHIELD && nType != BASE_ITEM_TOWERSHIELD)
    {
        oShield = OBJECT_INVALID;
    }
    object oTargetItem;
    if (GetIsObjectValid(oShield) && GetIsObjectValid(oArmor))
    {
        if (d4() == 1)
        {
            oTargetItem = oShield;
        }
        else
        {
            oTargetItem = oArmor;
        }
    }
    else if (GetIsObjectValid(oShield))
    {
        oTargetItem = oShield;
    }
    else if (GetIsObjectValid(oArmor))
    {
        oTargetItem = oArmor;
    }
    else
    {
        return;
    }
    int nDC = 25 - GetItemACValue(oTargetItem);
    if (nDC > 0)
    {
        if (!GetIsSkillSuccessful(oTarget, SKILL_DISCIPLINE, nDC))
        {
            if (oTargetItem == oArmor)
            {
                FloatingTextStrRefOnCreature(84426, oTarget,FALSE); // * Your armor was torn away! *
            }
            else
            {
                FloatingTextStrRefOnCreature(84429, oTarget,FALSE); // * Your shield was torn away! *
            }
            NWNX_Creature_RunUnequip(oTarget, oTargetItem);
        }
    }
    
}