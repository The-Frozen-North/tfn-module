// -----------------------------------------------------------------------------
//    File: util_i_varlists.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for manipulating local variable lists.
// Because these lists are zero-indexed and maintain a count of their length,
// they can be used to approximate arrays.
//
// Local variable lists are specific to a variable type: string lists and int
// lists can be maintained separately even when you give them the same name.
// This is because the variables are saved in a table with VarNames in the
// format Ref:<varname><index>. Each list maintains its own count in the format
// <type>:<varname>, where <type> is one of the following:
//   FC: Float Count
//   IC: Int Count
//   LC: Location Count
//   VC: Vector Count
//   OC: Object Count
//   SC: String Count
// You should not manipulate these variables directly. Rather, use the *List*()
// functions contained in this library.
// -----------------------------------------------------------------------------
// Acknowledgements: these functions are adapted from those in Memetic AI.
// -----------------------------------------------------------------------------

#include "util_i_math"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Prefixes used to keep list variables from colliding with other locals.
const string LIST_REF            = "Ref:";
const string LIST_REF_VECTOR     = "RefV:";
const string LIST_COUNT_FLOAT    = "FC:";
const string LIST_COUNT_INT      = "IC:";
const string LIST_COUNT_LOCATION = "LC:";
const string LIST_COUNT_VECTOR   = "VC:";
const string LIST_COUNT_OBJECT   = "OC:";
const string LIST_COUNT_STRING   = "SC:";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddListFloat >---
// ---< util_i_varlists >---
// Adds fValue to a float list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListInt >---
// ---< util_i_varlists >---
// Adds nValue to an int list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListLocation >---
// ---< util_i_varlists >---
// Adds lValue to a location list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListVector >---
// ---< util_i_varlists >---
// Adds vValue to a vector list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListObject >---
// ---< util_i_varlists >---
// Adds oValue to a object list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListObject(object oTarget, object oValue, string sListName = "", int bAddUnique = FALSE);

// ---< AddListString >---
// ---< util_i_varlists >---
// Adds sValue to a string list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListString(object oTarget, string sValue, string sListName = "", int bAddUnique = FALSE);

// ---< GetListFloat >---
// ---< util_i_varlists >---
// Returns the float at nIndex in oTarget's float list sListName. If no float is
// found at that index, 0.0 is returned.
float GetListFloat(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListInt >---
// ---< util_i_varlists >---
// Returns the int at nIndex in oTarget's int list sListName. If no int is found
// at that index, 0 is returned.
int GetListInt(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListLocation >---
// ---< util_i_varlists >---
// Returns the location at nIndex in oTarget's location list sListName. If no
// location is found at that index, an invalid location is returned.
location GetListLocation(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListVector >---
// ---< util_i_varlists >---
// Returns the vector at nIndex in oTarget's vector list sListName. If no string
// is found at that index, an origin vector is returned (0, 0, 0).
vector GetListVector(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListObject >---
// ---< util_i_varlists >---
// Returns the object at nIndex in oTarget's object list sListName. If no object
// is found at that index, OBJECT_INVALID is returned.
object GetListObject(object oTarget, int nIndex = 0, string sListName = "");

// ---< GetListString >---
// ---< util_i_varlists >---
// Returns the string at nIndex in oTarget's string list sListName. If no string
// is found at that index, "" is returned.
string GetListString(object oTarget, int nIndex = 0, string sListName = "");

// ---< DeleteListFloat >---
// ---< util_i_varlists >---
// Removes the float at nIndex on oTarget's float list sListName and returns the
// number of items remaining in the list. If bMaintainOrder is TRUE, this will
// shift up all entries after nIndex in the list. If FALSE, it will replace the
// removed item with the last entry in the list. If the order of items in the
// list doesn't matter, this will save a lot of cycles.
int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListInt >---
// ---< util_i_varlists >---
// Removes the int at nIndex on oTarget's int list sListName and returns the
// number of items remaining in the list. If bMaintainOrder is TRUE, this will
// shift up all entries after nIndex in the list. If FALSE, it will replace the
// removed item with the last entry in the list. If the order of items in the
// list doesn't matter, this will save a lot of cycles.
int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListLocation >---
// ---< util_i_varlists >---
// Removes the location at nIndex on oTarget's location list sListName and
// returns the number of items remaining in the list. If bMaintainOrder is TRUE,
// this will shift up all entries after nIndex in the list. If FALSE, it will
// replace the removed item with the last entry in the list. If the order of
// items in the list doesn't matter, this will save a lot of cycles.
int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListVector >---
// ---< util_i_varlists >---
// Removes the vector at nIndex on oTarget's vector list sListName and
// returns the number of items remaining in the list. If bMaintainOrder is TRUE,
// this will shift up all entries after nIndex in the list. If FALSE, it will
// replace the removed item with the last entry in the list. If the order of
// items in the list doesn't matter, this will save a lot of cycles.
int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListObject >---
// ---< util_i_varlists >---
// Removes the object at nIndex on oTarget's object list sListName and returns
// the number of items remaining in the list. If bMaintainOrder is TRUE, this
// will shift up all entries after nIndex in the list. If FALSE, it will replace
// the removed item with the last entry in the list. If the order of items in
// the list doesn't matter, this will save a lot of cycles.
int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< DeleteListString >---
// ---< util_i_varlists >---
// Removes the string at nIndex on oTarget's string list sListName and returns
// the number of items remaining in the list. If bMaintainOrder is TRUE, this
// will shift up all entries after nIndex in the list. If FALSE, it will replace
// the removed item with the last entry in the list. If the order of items in
// the list doesn't matter, this will save a lot of cycles.
int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListFloat >---
// ---< util_i_varlists >---
// Removes a float of fValue from the float list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListInt >---
// ---< util_i_varlists >---
// Removes an int of nValue from the float list sListName on oTarget and returns
// the number of items remaining in the list. If this float was added more than
// once, only the first reference is removed. If bMaintainOrder is TRUE, this
// will his shift up all entries after nIndex in the list. If FALSE, it will
// replace the removed item with the last entry in the list. If the order of
// items in the list doesn't matter, this will save a lot of cycles.
int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListLocation >---
// ---< util_i_varlists >---
// Removes a location of lValue from the location list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListVector >---
// ---< util_i_varlists >---
// Removes a vector of vValue from the vector list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListObject >---
// ---< util_i_varlists >---
// Removes an object of oValue from the object list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListString >---
// ---< util_i_varlists >---
// Removes a string of sValue from the object list sListName on oTarget and
// returns the number of items remaining in the list. If this float was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< FindListFloat >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the float fValue in the float
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListFloat(object oTarget, float fValue, string sListName = "");

// ---< FindListInt >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the int nValue in the int list
// sListName on oTarget. If it is not in the list, returns -1.
int FindListInt(object oTarget, int nValue, string sListName = "");

// ---< FindListLocation >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the location lValue in the
// location list sListName on oTarget. If it is not in the list, returns -1.
int FindListLocation(object oTarget, location lValue, string sListName = "");

// ---< FindListVector >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the vector vValue in the
// location list sListName on oTarget. If it is not in the list, returns -1.
int FindListVector(object oTarget, vector vValue, string sListName = "");

// ---< FindListObject >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the obejct oValue in the object
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListObject(object oTarget, object oValue, string sListName = "");

// ---< FindListString >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the string sValue in the string
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListString(object oTarget, string sValue, string sListName = "");

// ---< HasListFloat >---
// ---< util_i_varlists >---
// Returns whether oTarget has a float with the value fValue in its float list
// sListName.
int HasListFloat(object oTarget, float fValue, string sListName = "");

// ---< HasListInt >---
// ---< util_i_varlists >---
// Returns whether oTarget has an int with the value nValue in its int list
// sListName.
int HasListInt(object oTarget, int nValue, string sListName = "");

// ---< HasListLocation >---
// ---< util_i_varlists >---
// Returns whether oTarget has a location with the value lValue in its locaiton
// list sListName.
int HasListLocation(object oTarget, location lValue, string sListName = "");

// ---< HasListVector >---
// ---< util_i_varlists >---
// Returns whether oTarget has a vector with the value vValue in its vector
// list sListName.
int HasListVector(object oTarget, vector vValue, string sListName = "");

// ---< HasListObject >---
// ---< util_i_varlists >---
// Returns whether oTarget has an object with the value oValue in its object
// list sListName.
int HasListObject(object oTarget, object oValue, string sListName = "");

// ---< HasListString >---
// ---< util_i_varlists >---
// Returns whether oTarget has a string with the value sValue in its string list
// sListName.
int HasListString(object oTarget, string sValue, string sListName = "");

// ---< SetListFloat >---
// ---< util_i_varlists >---
// Sets item nIndex in the float list of sListName on oTarget to fValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "");

// ---< SetListInt >---
// ---< util_i_varlists >---
// Sets item nIndex in the int list of sListName on oTarget to nValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "");

// ---< SetListLocation >---
// ---< util_i_varlists >---
// Sets item nIndex in the location list of sListName on oTarget to lValue. If
// the index is at the end of the list, it will be added. If it exceeds the
// length of the list, nothing is added.
void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "");

// ---< SetListVector >---
// ---< util_i_varlists >---
// Sets item nIndex in the vector list of sListName on oTarget to vValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "");

// ---< SetListObject >---
// ---< util_i_varlists >---
// Sets item nIndex in the object list of sListName on oTarget to oValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "");

// ---< SetListString >---
// ---< util_i_varlists >---
// Sets item nIndex in the string list of sListName on oTarget to sValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListString(object oTarget, int nIndex, string sValue, string sListName = "");

// ---< CopyListFloat >---
// ---< util_i_varlists >---
// Starting at nIndex, copies nRange items from float list sSourceName on oSource
// and adds them to list sTargetName on oTarget.  Returns the number of list items
// copied to the target list.
int CopyListFloat(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

// ---< CopyListInt >---
// ---< util_i_varlists >---
// Starting at nIndex, copies nRange items from int list sSourceName on oSource
// and adds them to list sTargetName on oTarget.  Returns the number of list items
// copied to the target list.
int CopyListInt(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

// ---< CopyListLocation >---
// ---< util_i_varlists >---
// Starting at nIndex, copies nRange items from location list sSourceName on oSource
// and adds them to list sTargetName on oTarget.  Returns the number of list items
// copied to the target list.
int CopyListLocation(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

// ---< CopyListVector >---
// ---< util_i_varlists >---
// Starting at nIndex, copies nRange items from vector list sSourceName on oSource
// and adds them to list sTargetName on oTarget.  Returns the number of list items
// copied to the target list.
int CopyListVector(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

// ---< CopyListObject >---
// ---< util_i_varlists >---
// Starting at nIndex, copies nRange items from object list sSourceName on oSource
// and adds them to list sTargetName on oTarget.  Returns the number of list items
// copied to the target list.
int CopyListObject(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

// ---< CopyListString >---
// ---< util_i_varlists >---
// Starting at nIndex, copies nRange items from string list sSourceName on oSource
// and adds them to list sTargetName on oTarget.  Returns the number of list items
// copied to the target list.
int CopyListString(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

// ---< DeleteFloatList >---
// ---< util_i_varlists >---
// Deletes the float list sListName from oTarget.
void DeleteFloatList(object oTarget, string sListName = "");

// ---< DeleteIntList >---
// ---< util_i_varlists >---
// Deletes the int list sListName from oTarget.
void DeleteIntList(object oTarget, string sListName = "");

// ---< DeleteLocationList >---
// ---< util_i_varlists >---
// Deletes the location list sListName from oTarget.
void DeleteLocationList(object oTarget, string sListName = "");

// ---< DeleteVectorList >---
// ---< util_i_varlists >---
// Deletes the vector list sListName from oTarget.
void DeleteVectorList(object oTarget, string sListName = "");

// ---< DeleteObjectList >---
// ---< util_i_varlists >---
// Deletes the object list sListName from oTarget.
void DeleteObjectList(object oTarget, string sListName = "");

// ---< DeleteStringList >---
// ---< util_i_varlists >---
// Deletes the string list sListName from oTarget.
void DeleteStringList(object oTarget, string sListName = "");

// ---< DeclareFloatList >---
// ---< util_i_varlists >---
// Creates a float list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareFloatList(object oTarget, int nCount, string sListName = "");

// ---< DeclareIntList >---
// ---< util_i_varlists >---
// Creates an int list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareIntList(object oTarget, int nCount, string sListName = "");

// ---< DeclareLocationList >---
// ---< util_i_varlists >---
// Creates a location list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareLocationList(object oTarget, int nCount, string sListName = "");

// ---< DeclareVectorList >---
// ---< util_i_varlists >---
// Creates a vector list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareVectorList(object oTarget, int nCount, string sListName = "");

// ---< DeclareObjectList >---
// ---< util_i_varlists >---
// Creates an object list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareObjectList(object oTarget, int nCount, string sListName = "");

// ---< DeclareStringList >---
// ---< util_i_varlists >---
// Creates a string list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareStringList(object oTarget, int nCount, string sListName = "");

// ---< CopyFloatList >---
// ---< util_i_varlists >---
// Copies the float list sSourceName from oSource to oTarget, renamed
// sTargetName. If bAddUnique is TRUE, will only copy items from the source list
// that are not already present in the target list.
void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CopyIntList >---
// ---< util_i_varlists >---
// Copies the int list sSourceName from oSource to oTarget, renamed sTargetName.
// If bAddUnique is TRUE, will only copy items from the source list that are not
// already present in the target list.
void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CopyLocationList >---
// ---< util_i_varlists >---
// Copies the location list sSourceName from oSource to oTarget, renamed
// sTargetName. If bAddUnique is TRUE, will only copy items from the source list
// that are not already present in the target list.
void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CopyVectorList >---
// ---< util_i_varlists >---
// Copies the vector list sSourceName from oSource to oTarget, renamed
// sTargetName. If bAddUnique is TRUE, will only copy items from the source list
// that are not already present in the target list.
void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CopyObjectList >---
// ---< util_i_varlists >---
// Copies the object list sSourceName from oSource to oTarget, renamed
// sTargetName. If bAddUnique is TRUE, will only copy items from the source list
// that are not already present in the target list.
void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CopyStringList >---
// ---< util_i_varlists >---
// Copies the string list sSourceName from oSource to oTarget, renamed
// sTargetName. If bAddUnique is TRUE, will only copy items from the source list
// that are not already present in the target list.
void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CountFloatList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's float list sListName.
int CountFloatList(object oTarget, string sListName = "");

// ---< CountIntList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's int list sListName.
int CountIntList(object oTarget, string sListName = "");

// ---< CountLocationList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's location list sListName.
int CountLocationList(object oTarget, string sListName = "");

// ---< CountVectorList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's vector list sListName.
int CountVectorList(object oTarget, string sListName = "");

// ---< CountObjectList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's object list sListName.
int CountObjectList(object oTarget, string sListName = "");

// ---< CountStringList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's string list sListName.
int CountStringList(object oTarget, string sListName = "");

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

// Internal function to convert a vector to a pseudo-location by adding an
// OBJECT_INVALID area and 0.0f facing. Vectors are stored as pseudo-locations.
location _VectorToLocation(vector vVector)
{
    return Location(OBJECT_INVALID, vVector, 0.0f);
}

int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountFloatList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = 0; i < nCount; i++)
        {
            if (GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(i)) == fValue)
                return FALSE;
        }
    }

    SetLocalFloat(oTarget, LIST_REF         + sListName + IntToString(nCount), fValue);
    SetLocalInt  (oTarget, LIST_COUNT_FLOAT + sListName, nCount + 1);
    return TRUE;
}

int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountIntList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = 0; i < nCount; i++)
        {
            if (GetLocalInt(oTarget, LIST_REF + sListName + IntToString(i)) == nValue)
                return FALSE;
        }
    }

    SetLocalInt(oTarget, LIST_REF       + sListName + IntToString(nCount), nValue);
    SetLocalInt(oTarget, LIST_COUNT_INT + sListName, nCount + 1);
    return TRUE;
}

int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountLocationList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = 0; i < nCount; i++)
        {
            if (GetLocalLocation(oTarget, LIST_REF + sListName + IntToString(i)) == lValue)
                return FALSE;
        }
    }

    SetLocalLocation(oTarget, LIST_REF            + sListName + IntToString(nCount), lValue);
    SetLocalInt     (oTarget, LIST_COUNT_LOCATION + sListName, nCount + 1);
    return TRUE;
}

int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE)
{
    location lValue = _VectorToLocation(vValue);
    int nCount = CountVectorList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = 0; i < nCount; i++)
        {
            if (GetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(i)) == lValue)
                return FALSE;
        }
    }

    SetLocalLocation(oTarget, LIST_REF_VECTOR   + sListName + IntToString(nCount), lValue);
    SetLocalInt     (oTarget, LIST_COUNT_VECTOR + sListName, nCount + 1);
    return TRUE;
}

int AddListObject(object oTarget, object oObject, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountObjectList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = 0; i < nCount; i++)
        {
            if (GetLocalObject(oTarget, LIST_REF + sListName + IntToString(i)) == oObject)
                return FALSE;
        }
    }

    SetLocalObject(oTarget, LIST_REF          + sListName + IntToString(nCount), oObject);
    SetLocalInt   (oTarget, LIST_COUNT_OBJECT + sListName, nCount + 1);
    return TRUE;
}

int AddListString(object oTarget, string sString, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountStringList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = 0; i < nCount; i++)
        {
            if (GetLocalString(oTarget, LIST_REF + sListName + IntToString(i)) == sString)
                return FALSE;
        }
    }

    SetLocalString(oTarget, LIST_REF          + sListName + IntToString(nCount), sString);
    SetLocalInt   (oTarget, LIST_COUNT_STRING + sListName, nCount + 1);
    return TRUE;
}

float GetListFloat(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountFloatList(oTarget, sListName);
    if (nIndex >= nCount) return 0.0;
    return GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex));
}

int GetListInt(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountIntList(oTarget, sListName);
    if (nIndex >= nCount) return 0;
    return GetLocalInt(oTarget, LIST_REF + sListName + IntToString(nIndex));
}

location GetListLocation(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountLocationList(oTarget, sListName);
    if (nIndex >= nCount) return Location(OBJECT_INVALID, Vector(), 0.0);
    return GetLocalLocation(oTarget, LIST_REF + sListName + IntToString(nIndex));
}

vector GetListVector(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountVectorList(oTarget, sListName);
    if (nIndex >= nCount) return Vector();
    return GetPositionFromLocation(GetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(nIndex)));
}

object GetListObject(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountObjectList(oTarget, sListName);
    if (nIndex >= nCount) return OBJECT_INVALID;
    return GetLocalObject(oTarget, LIST_REF + sListName + IntToString(nIndex));
}

string GetListString(object oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountStringList(oTarget, sListName);
    if (nIndex >= nCount) return "";
    return GetLocalString(oTarget, LIST_REF + sListName + IntToString(nIndex));
}

int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountFloatList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    float fRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            fRef = GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex + 1));
                   SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex), fRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        fRef = GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nCount - 1));
               SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex), fRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalFloat(oTarget, LIST_REF         + sListName + IntToString(--nCount));
    SetLocalInt     (oTarget, LIST_COUNT_FLOAT + sListName, nCount);

    return nCount;
}

int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountIntList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    int nRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            nRef = GetLocalInt(oTarget, LIST_REF + sListName + IntToString(nIndex + 1));
                   SetLocalInt(oTarget, LIST_REF + sListName + IntToString(nIndex), nRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        nRef = GetLocalInt(oTarget, LIST_REF + sListName + IntToString(nCount - 1));
               SetLocalInt(oTarget, LIST_REF + sListName + IntToString(nIndex), nRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalInt(oTarget, LIST_REF       + sListName + IntToString(--nCount));
    SetLocalInt   (oTarget, LIST_COUNT_INT + sListName, nCount);

    return nCount;
}

int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountLocationList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    location lRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            lRef = GetLocalLocation(oTarget, LIST_REF + sListName + IntToString(nIndex + 1));
                   SetLocalLocation(oTarget, LIST_REF + sListName + IntToString(nIndex), lRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        lRef = GetLocalLocation(oTarget, LIST_REF + sListName + IntToString(nCount - 1));
               SetLocalLocation(oTarget, LIST_REF + sListName + IntToString(nIndex), lRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalLocation(oTarget, LIST_REF            + sListName + IntToString(--nCount));
    SetLocalInt        (oTarget, LIST_COUNT_LOCATION + sListName, nCount);

    return nCount;
}

int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountVectorList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    location lRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            lRef = GetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(nIndex + 1));
                   SetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(nIndex), lRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        lRef = GetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(nCount - 1));
               SetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(nIndex), lRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalLocation(oTarget, LIST_REF_VECTOR   + sListName + IntToString(--nCount));
    SetLocalInt        (oTarget, LIST_COUNT_VECTOR + sListName, nCount);

    return nCount;
}

int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountObjectList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    object oRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            oRef = GetLocalObject(oTarget, LIST_REF + sListName + IntToString(nIndex + 1));
                   SetLocalObject(oTarget, LIST_REF + sListName + IntToString(nIndex), oRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        oRef = GetLocalObject(oTarget, LIST_REF + sListName + IntToString(nCount - 1));
               SetLocalObject(oTarget, LIST_REF + sListName + IntToString(nIndex), oRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalObject(oTarget, LIST_REF   + sListName + IntToString(--nCount));
    SetLocalInt      (oTarget, LIST_COUNT_OBJECT + sListName, nCount);

    return nCount;
}

int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountStringList(oTarget, sListName);

    // Sanity check
    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    string sRef;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            sRef = GetLocalString(oTarget, LIST_REF + sListName + IntToString(nIndex + 1));
                   SetLocalString(oTarget, LIST_REF + sListName + IntToString(nIndex), sRef);
        }
    }
    else
    {
        // Replace this item with the last one in the list
        sRef = GetLocalString(oTarget, LIST_REF + sListName + IntToString(nCount - 1));
               SetLocalString(oTarget, LIST_REF + sListName + IntToString(nIndex), sRef);
    }

    // Delete the last item in the list and set the new count
    DeleteLocalString(oTarget, LIST_REF          + sListName + IntToString(--nCount));
    SetLocalInt      (oTarget, LIST_COUNT_STRING + sListName, nCount);

    return nCount;
}

int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListFloat(oTarget, fValue, sListName);
    return DeleteListFloat(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListInt(oTarget, nValue, sListName);
    return DeleteListInt(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListLocation(oTarget, lValue, sListName);
    return DeleteListLocation(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListVector(oTarget, vValue, sListName);
    return DeleteListVector(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListObject(oTarget, oValue, sListName);
    return DeleteListObject(oTarget, nIndex, sListName, bMaintainOrder);
}

int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListString(oTarget, sValue, sListName);
    return DeleteListString(oTarget, nIndex, sListName, bMaintainOrder);
}

int FindListFloat(object oTarget, float fValue, string sListName = "")
{
    int i, nCount = CountFloatList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(i)) == fValue)
            return i;

    return -1;
}

int FindListInt(object oTarget, int nValue, string sListName = "")
{
    int i, nCount = CountIntList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalInt(oTarget, LIST_REF + sListName + IntToString(i)) == nValue)
            return i;

    return -1;
}

int FindListLocation(object oTarget, location lValue, string sListName = "")
{
    int i, nCount = CountLocationList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalLocation(oTarget, LIST_REF + sListName + IntToString(i)) == lValue)
            return i;

    return -1;
}

int FindListVector(object oTarget, vector vValue, string sListName = "")
{
    location lValue = _VectorToLocation(vValue);
    int i, nCount = CountVectorList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(i)) == lValue)
            return i;

    return -1;
}

int FindListObject(object oTarget, object oValue, string sListName = "")
{
    int i, nCount = CountObjectList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalObject(oTarget, LIST_REF + sListName + IntToString(i)) == oValue)
            return i;

    return -1;
}

int FindListString(object oTarget, string sValue, string sListName = "")
{
    int i, nCount = CountStringList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
        if (GetLocalString(oTarget, LIST_REF + sListName + IntToString(i)) == sValue)
            return i;

    return -1;
}

int HasListFloat(object oTarget, float fValue, string sListName = "")
{
    if (FindListFloat(oTarget, fValue, sListName) != -1) return TRUE;
    else                                                 return FALSE;
}

int HasListInt(object oTarget, int nValue, string sListName = "")
{
    if (FindListInt(oTarget, nValue, sListName) != -1) return TRUE;
    else                                               return FALSE;
}

int HasListLocation(object oTarget, location lValue, string sListName = "")
{
    if (FindListLocation(oTarget, lValue, sListName) != -1) return TRUE;
    else                                                    return FALSE;
}

int HasListVector(object oTarget, vector vValue, string sListName = "")
{
    if (FindListVector(oTarget, vValue, sListName) != -1) return TRUE;
    else                                                  return FALSE;
}

int HasListObject(object oTarget, object oValue, string sListName = "")
{
    if (FindListObject(oTarget, oValue, sListName) != -1) return TRUE;
    else                                                  return FALSE;
}

int HasListString(object oTarget, string sValue, string sListName = "")
{
    if (FindListString(oTarget, sValue, sListName) != -1) return TRUE;
    else                                                  return FALSE;
}

void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "")
{
    int nCount = CountFloatList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListFloat(oTarget, fValue, sListName);
    else
        SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex), fValue);
}

void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "")
{
    int nCount = CountIntList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListInt(oTarget, nValue, sListName);
    else
        SetLocalInt(oTarget, LIST_REF + sListName + IntToString(nIndex), nValue);
}

void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "")
{
    int nCount = CountLocationList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListLocation(oTarget, lValue, sListName);
    else
        SetLocalLocation(oTarget, LIST_REF + sListName + IntToString(nIndex), lValue);
}

void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "")
{
    location lValue = _VectorToLocation(vValue);
    int nCount = CountVectorList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListVector(oTarget, vValue, sListName);
    else
        SetLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(nIndex), lValue);

}

void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "")
{
    int nCount = CountObjectList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListObject(oTarget, oValue, sListName);
    else
        SetLocalObject(oTarget, LIST_REF + sListName + IntToString(nIndex), oValue);
}

void SetListString(object oTarget, int nIndex, string sValue, string sListName = "")
{
    int nCount = CountStringList(oTarget, sListName);

    if (nIndex > nCount) return;

    if (nIndex == nCount)
        AddListString(oTarget, sValue, sListName);
    else
        SetLocalString(oTarget, LIST_REF + sListName + IntToString(nIndex), sValue);
}

int CopyListFloat(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    float fValue;
    int  i, nCopied, nCount = CountFloatList(oSource, sSourceName);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return FALSE;

    if (nRange > nCount - nIndex)
        nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        fValue = GetListFloat(oSource, nIndex + i, sSourceName);
        if (AddListFloat(oTarget, fValue, sTargetName, bAddUnique))
            nCopied++;
    }

    return nCopied;
}

int CopyListInt(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    int nValue;
    int  i, nCopied, nCount = CountIntList(oSource, sSourceName);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return FALSE;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        nValue = GetListInt(oSource, nIndex + i, sSourceName);
        if (AddListInt(oTarget, nValue, sTargetName, bAddUnique))
            nCopied++;
    }

    return nCopied;
}

int CopyListLocation(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    location lValue;
    int  i, nCopied, nCount = CountLocationList(oSource, sSourceName);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return FALSE;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        lValue = GetListLocation(oSource, nIndex + i, sSourceName);
        if (AddListLocation(oTarget, lValue, sTargetName, bAddUnique))
            nCopied++;
    }

    return nCopied;
}

int CopyListVector(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    vector vValue;
    int  i, nCopied, nCount = CountVectorList(oSource, sSourceName);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return FALSE;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        vValue = GetListVector(oSource, nIndex + i, sSourceName);
        if (AddListVector(oTarget, vValue, sTargetName, bAddUnique))
            nCopied++;
    }

    return nCopied;
}

int CopyListObject(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    object oValue;
    int  i, nCopied, nCount = CountObjectList(oSource, sSourceName);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return FALSE;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        oValue = GetListObject(oSource, nIndex + i, sSourceName);
        if (AddListObject(oTarget, oValue, sTargetName, bAddUnique))
            nCopied++;
    }

    return nCopied;
}

int CopyListString(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    string sValue;
    int  i, nCopied, nCount = CountStringList(oSource, sSourceName);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return FALSE;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        sValue = GetListString(oSource, nIndex + i, sSourceName);
        if (AddListString(oTarget, sValue, sTargetName, bAddUnique))
            nCopied++;
    }

    return nCopied;
}

void DeleteFloatList(object oTarget, string sListName = "")
{
    int i, nCount = CountFloatList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalFloat(oTarget, LIST_REF + sListName + IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_FLOAT + sListName);
}

void DeleteIntList(object oTarget, string sListName = "")
{
    int i, nCount = CountIntList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalInt(oTarget, LIST_REF + sListName + IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_INT + sListName);
}

void DeleteLocationList(object oTarget, string sListName = "")
{
    int i, nCount = CountLocationList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalLocation(oTarget, LIST_REF + sListName + IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_LOCATION + sListName);
}

void DeleteVectorList(object oTarget, string sListName = "")
{
    int i, nCount = CountVectorList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalLocation(oTarget, LIST_REF_VECTOR + sListName + IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_VECTOR + sListName);
}

void DeleteObjectList(object oTarget, string sListName = "")
{
    int i, nCount = CountObjectList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalObject(oTarget, LIST_REF + sListName + IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_OBJECT + sListName);
}

void DeleteStringList(object oTarget, string sListName = "")
{
    int i, nCount = CountStringList(oTarget, sListName);
    for (i = 0; i < nCount; i++)
        DeleteLocalString(oTarget, LIST_REF + sListName + IntToString(i));

    DeleteLocalInt(oTarget, LIST_COUNT_STRING + sListName);
}

void DeclareFloatList(object oTarget, int nCount, string sListName = "")
{
    DeleteFloatList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_FLOAT + sListName, nCount);
}

void DeclareIntList(object oTarget, int nCount, string sListName = "")
{
    DeleteIntList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_INT + sListName, nCount);
}

void DeclareLocationList(object oTarget, int nCount, string sListName = "")
{
    DeleteLocationList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_LOCATION + sListName, nCount);
}

void DeclareVectorList(object oTarget, int nCount, string sListName = "")
{
    DeleteVectorList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_VECTOR + sListName, nCount);
}

void DeclareObjectList(object oTarget, int nCount, string sListName = "")
{
    DeleteObjectList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_OBJECT + sListName, nCount);
}

void DeclareStringList(object oTarget, int nCount, string sListName = "")
{
    DeleteStringList(oTarget, sListName);
    SetLocalInt(oTarget, LIST_COUNT_STRING + sListName, nCount);
}

// WARNING!! Extremely long list management can cause TMI; this list code
// is expensive. It is NOT recommended that you create long lists.
void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    float fValue;
    int  i, nCount = CountFloatList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        fValue = GetListFloat(oSource, i, sSourceName);
        AddListFloat(oTarget, fValue, sTargetName, bAddUnique);
    }
}

void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    int nValue;
    int  i, nCount = CountIntList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        nValue = GetListInt(oSource, i, sSourceName);
        AddListInt(oTarget, nValue, sTargetName, bAddUnique);
    }
}

void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    location lValue;
    int  i, nCount = CountLocationList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        lValue = GetListLocation(oSource, i, sSourceName);
        AddListLocation(oTarget, lValue, sTargetName, bAddUnique);
    }
}

void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    vector vValue;
    int  i, nCount = CountVectorList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        vValue = GetListVector(oSource, i, sSourceName);
        AddListVector(oTarget, vValue, sTargetName, bAddUnique);
    }
}

void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    object oValue;
    int  i, nCount = CountObjectList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        oValue = GetListObject(oSource, i, sSourceName);
        AddListObject(oTarget, oValue, sTargetName, bAddUnique);
    }
}

void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    string sValue;
    int  i, nCount = CountStringList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        sValue = GetListString(oSource, i, sSourceName);
        AddListString(oTarget, sValue, sTargetName, bAddUnique);
    }
}

int CountFloatList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_FLOAT + sListName);
}

int CountIntList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_INT + sListName);
}

int CountLocationList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_LOCATION + sListName);
}

int CountVectorList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_VECTOR + sListName);
}

int CountObjectList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_OBJECT + sListName);
}

int CountStringList(object oTarget, string sListName = "")
{
    return GetLocalInt(oTarget, LIST_COUNT_STRING + sListName);
}
