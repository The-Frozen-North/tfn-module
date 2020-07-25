//:://////////////////////////////////////////////////
//:: 70_npc_ondeath
/*

This script runs only on monster that died during possession of Dungeon Master.

Until now, no script ran, so no loot appeared or in case of custom XP scripts,
even no XP were given to killer.

This script fixes this. I also added special variable (string) named DEATH_SCRIPT
for special cases like Balor or Stink Beetle which uses different OnDeath script.

Default monsters now have this variable, but if you will want to make your own
monster with special OnDeath script, add the name of that script into mentioned
variable in order to make it work even when possessed by DMs.

*/
//:://////////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 12/11/2010
//:://////////////////////////////////////////////////


void main()
{
string script = GetLocalString(OBJECT_SELF,"DEATH_SCRIPT");
 if(script == "")
 {
 script = "nw_c2_default7";
 }
ExecuteScript(script,OBJECT_SELF);
}
