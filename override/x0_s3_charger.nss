//::///////////////////////////////////////////////
//:: Name
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

    Generic recharging item.


        Target 1:
            Tries to charge an item however it requires an item in the off-hand. Whatever is there, is destroyed.

       Each use of the item restores 1 charge.
       Will kill the user if they are wounded.


       Test cases:
        - user fully healed
        - user damaged
        - user damage, 10 hitpoints will kill
        - on an item with full charges
        - on an item with no charges
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: March 20, 2003
//:://////////////////////////////////////////////

void main()
{
    object oItem = GetSpellTargetObject();
    object oCaster = OBJECT_SELF;
    object oCharger = GetSpellCastItem();
    int nId = GetSpellId();

    if (GetIsObjectValid(oItem))
    {
        if (GetObjectType(oItem) == OBJECT_TYPE_ITEM)
        {
            // * charge
            if (nId == 509)
            {
                int nCharges = GetItemCharges(oItem);
                // * if item has some charges, then allow renewal
                if (nCharges > 0)
                {
                    int nMaxCharges = GetLocalInt(oItem,"ELECTRIFIER_CHARGE_MAX");
                    if(nMaxCharges < 0 || (GetBaseItemType(oItem) == BASE_ITEM_ENCHANTED_WAND && nMaxCharges == 0))
                    {
                        //item does not allow recharging
                        FloatingTextStrRefOnCreature(105305,oCaster,FALSE);
                        return;
                    }
                    int nCost = GetLocalInt(oItem,"ELECTRIFIER_CHARGE_COST");
                    if(!nCost) nCost = 1000;
                    int nValue = GetLocalInt(oCharger, "X0_L_CHARGES_ELECTRIFIER");
                    int nNewCharges = nValue/nCost;
                    if (nNewCharges >= 1)
                    {
                        if(!nMaxCharges) nMaxCharges = 50;
                        if(nMaxCharges > nCharges)
                        {
                            nMaxCharges-= nCharges;
                            if(nMaxCharges < nNewCharges)
                            {
                                nNewCharges = nMaxCharges;
                            }
                            // * null the cost stored on item
                            SetLocalInt(oCharger, "X0_L_CHARGES_ELECTRIFIER", nValue-nNewCharges*nCost);
                            SetItemCharges(oItem, nCharges + nNewCharges);
                            FloatingTextStrRefOnCreature(40055,oCaster,FALSE);
                        }
                        else
                        {
                            FloatingTextStrRefOnCreature(105305,oCaster,FALSE);
                        }
                    }
                    else
                        FloatingTextStrRefOnCreature(40056,oCaster,FALSE);
                }
            }
            else
            if (nId == 510 && GetPlotFlag(oItem) == FALSE && !GetItemCursedFlag(oItem)) // decharge
            {
                int nValue = GetGoldPieceValue(oItem);
                FloatingTextStrRefOnCreature(40057,oCaster,FALSE);
                int nPreviousValue = GetLocalInt(oCharger, "X0_L_CHARGES_ELECTRIFIER");
                SetLocalInt(oCharger, "X0_L_CHARGES_ELECTRIFIER", nPreviousValue + nValue);
                effect eVis = EffectVisualEffect(VFX_IMP_DISPEL);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
                //SpeakString(IntToString(nPreviousValue + nValue));
                DestroyObject(oItem);
            }
        }
        else
        {
            FloatingTextStrRefOnCreature(83384,oCaster,FALSE);
        }
    }
    else
    {
        FloatingTextStrRefOnCreature(83384,oCaster,FALSE);
    }
}
