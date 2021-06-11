#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureBodyPart(CREATURE_PART_HEAD, 22, OBJECT_SELF);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_01_");
            NWNX_Creature_SetSoundset(OBJECT_SELF, 133);
        break;
    }

    object oArmor;

    switch (d8())
    {
        case 1:
        case 2:
           oArmor = CreateItemOnObject("nw_aarcl004"); //chainmail
        break;
        case 3:
        case 4:
        case 5:
           oArmor = CreateItemOnObject("nw_aarcl010"); //breastplate
        break;
        case 6:
           oArmor = CreateItemOnObject("nw_aarcl005"); //splint mail
        break;
        case 7:
           oArmor = CreateItemOnObject("nw_aarcl011"); //banded mail
        break;
        case 8:
           oArmor = CreateItemOnObject("nw_aarcl006"); //half plate
        break;
    }

    NWNX_Creature_RunEquip(OBJECT_SELF, oArmor, INVENTORY_SLOT_CHEST);

    SetDroppableFlag(oArmor, FALSE);
    SetPickpocketableFlag(oArmor, FALSE);
}
