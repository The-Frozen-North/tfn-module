//void main(){}
void SKIN_SupportEquipSkin(object oSkin,int nCount=0)
{ // PURPOSE: Force equip skin
    effect eSearch = GetFirstEffect(OBJECT_SELF);
    int poly;
    while(GetIsEffectValid(eSearch))
    {
        if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
        {
            DelayCommand(3.0,SKIN_SupportEquipSkin(oSkin,nCount));
            return;
        }
        eSearch = GetNextEffect(OBJECT_SELF);
    }
    object oThere=GetItemInSlot(INVENTORY_SLOT_CARMOUR,OBJECT_SELF);
    //SendMessageToPC(GetFirstPC(),GetName(OBJECT_SELF)+":SKIN_SupportEquipSkin("+GetName(oSkin)+", nCount="+IntToString(nCount)+")");
    if (nCount>0&&GetCurrentAction()==ACTION_REST)
    {
        DelayCommand(0.2,SKIN_SupportEquipSkin(oSkin,nCount));
        return;
    }
    if (oSkin!=oThere&&!GetIsObjectValid(oThere))
    { // equip
        AssignCommand(OBJECT_SELF,ActionEquipItem(oSkin,INVENTORY_SLOT_CARMOUR));
        if (nCount<29) DelayCommand(0.2,SKIN_SupportEquipSkin(oSkin,nCount+1));
    } // equip
    else if (GetIsObjectValid(oThere)&&oSkin!=oThere)
    { // skin already present
        DestroyObject(oSkin);
    } // skin already present
} // SKIN_SupportEquipSkin()
