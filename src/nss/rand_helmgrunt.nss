#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureBodyPart(CREATURE_PART_HEAD, 5, OBJECT_SELF);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_01_");
            NWNX_Creature_SetSoundset(OBJECT_SELF, 133);
        break;
    }
    object oWeapon, oAmmo, oBackup;
    switch (d3())
    {
        case 1:
        case 2:
            oWeapon = CreateItemOnObject("nw_wswls001", OBJECT_SELF);
        break;
        case 3:
            oWeapon = CreateItemOnObject("nw_wbwxl001", OBJECT_SELF);
            oAmmo = CreateItemOnObject("nw_wambo001", OBJECT_SELF, 99);
            oBackup = CreateItemOnObject("nw_wswss001");

            SetDroppableFlag(oBackup, FALSE);
            SetPickpocketableFlag(oBackup, FALSE);
            SetDroppableFlag(oAmmo, FALSE);
            SetPickpocketableFlag(oAmmo, FALSE);

            AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_BOLTS));
            SetLocalInt(OBJECT_SELF, "range", 1);
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));

    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
