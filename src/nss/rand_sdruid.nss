#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_el_f_04_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_ELF_NPC_FEMALE);
            NWNX_Creature_SetSoundset(OBJECT_SELF, 128);
        break;
    }
}
