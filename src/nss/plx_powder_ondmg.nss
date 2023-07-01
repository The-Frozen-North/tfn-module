// simple script to instantly blow up if any fire damage taken

void main()
{
    object oDamager = GetLastDamager();

// no fire damage, do nothing
    if (GetDamageDealtByType(DAMAGE_TYPE_FIRE) <= 0)
        return;

    int bTagForCredit = FALSE;

// if not a PC, attempt to get the master
    if (!GetIsPC(oDamager))
    {
        oDamager = GetMaster(oDamager);
    }

// because the damager can be itself, set a var if the fire damage came from a PC
    if (GetIsPC(oDamager))
    {
        SetLocalInt(OBJECT_SELF, "fire_pc_tagged", 1);
    }

// blow itself up
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(10, DAMAGE_TYPE_FIRE), OBJECT_SELF);
}
