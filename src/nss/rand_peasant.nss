#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureAppearanceType(OBJECT_SELF, 222);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_18_");
            NWNX_Creature_SetSoundset(OBJECT_SELF, 151);
        break;
    }
}
