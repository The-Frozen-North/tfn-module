#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_azergirl_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_AZER_FEMALE);
            NWNX_Creature_SetSoundset(OBJECT_SELF, 112);
        break;
    }
}
