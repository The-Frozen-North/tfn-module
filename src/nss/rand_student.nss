#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureBodyPart(CREATURE_PART_HEAD, 12, OBJECT_SELF);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_05_");
            NWNX_Creature_SetSoundset(OBJECT_SELF, 166);
        break;
    }
}
