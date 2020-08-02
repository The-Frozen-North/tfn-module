#include "inc_treasure"
#include "inc_debug"

void CreateTrap(string sResRef, object oContainer)
{
    object oItem = CreateItemOnObject(sResRef, oContainer);
    SetIdentified(oItem, TRUE);
    SetLocalInt(oItem, "identified", 1);
}

// ------------------------------------------
// Traps
// ------------------------------------------

void main()
{
    CreateTrap("nw_it_trap034", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap014", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap022", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap018", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap030", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap026", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap006", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap042", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap038", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap002", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap010", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap036", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap016", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap024", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap020", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap032", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap028", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap008", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap044", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap040", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap004", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap012", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap033", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap013", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap021", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap017", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap029", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap025", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap005", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap041", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap037", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap001", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap009", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap035", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap015", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap023", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap019", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap031", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap027", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap007", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap043", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap039", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap003", GetObjectByTag(TREASURE_DISTRIBUTION));
    CreateTrap("nw_it_trap011", GetObjectByTag(TREASURE_DISTRIBUTION));

    SendDebugMessage("Treasure traps generated", TRUE);
    DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("gtreas_weapons", OBJECT_SELF));
}
