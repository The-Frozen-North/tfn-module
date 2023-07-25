void main()
{
   if (IsInConversation(OBJECT_SELF)) return;
   
   if (d6() > 1) return;

   ClearAllActions();
   ActionCastSpellAtObject(SPELL_COMBUST, GetNearestObjectByTag("pyre"+IntToString(d3())), METAMAGIC_ANY, TRUE);
}
