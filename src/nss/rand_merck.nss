#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_01_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_HUMAN_NPC_FEMALE_05);
            NWNX_Creature_SetSoundset(OBJECT_SELF, 188);
        break;
    }
}
