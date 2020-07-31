#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureBodyPart(CREATURE_PART_HEAD, 2, OBJECT_SELF);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_21_");
            NWNX_Creature_SetSoundset(OBJECT_SELF, 151);
        break;
    }
}
