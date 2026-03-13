//::///////////////////////////////////////////////
//:: Amulet of Mighty Fists +3
//:: jy_itnk_amf3
//:: 
//:://////////////////////////////////////////////
/*
	Amulet of Might Fists +3
	Magic Item
	(Dungeon Master's Guide v.3.5, p. 246)

	Price: 54,000 gp
	Body Slot: Throat
	Caster Level: 5th
	Aura: Faint; (DC 18) Evocation
	Activation: —
	Weight: — lb.

	This amulet grants an enhancement bonus of +3 
	on attack and damage rolls with unarmed attacks 
	and natural weapons.

	Prerequisites: Craft Wondrous Item , Magic Fang, 
	Greater creator’s caster level must be at least 
	3x the amulet’s bonus.

	Cost to Create: 27,000 gp, 2,160 XP, 54 day(s). 

*/
//:://////////////////////////////////////////////
//:: Modified By: Jaysyn
//:: Modified On: 2025-05-25 20:23:47
//:://////////////////////////////////////////////

#include "x2_inc_switches"
#include "inc_eventhook"
#include "prc_inc_combat"

const string AMULET_RES     = "jy_itnk_amf3";
const string AMULET_EFFECT  = "AMULET_MIGHTY_FISTS+3";
const string SCRIPT_NAME    = "jy_itnk_amf3";

// check if PC is wearing the amulet
int WearingAmulet(object oPC)
{
    object oNeck = GetItemInSlot(INVENTORY_SLOT_NECK, oPC);
    return (GetIsObjectValid(oNeck) &&
            (GetResRef(oNeck) == AMULET_RES || GetTag(oNeck) == AMULET_RES));
}

// remove any lingering effect
void RemoveAmuletEffect(object oPC)
{
    effect e = GetFirstEffect(oPC);
    while (GetIsEffectValid(e))
    {
        if (GetEffectTag(e) == AMULET_EFFECT)
            RemoveEffect(oPC, e);
        e = GetNextEffect(oPC);
    }
}

// apply new effect
void ApplyAmuletEffect(object oPC)
{
    RemoveAmuletEffect(oPC);

    effect eMightyR = EffectAttackIncrease(3, ATTACK_BONUS_ONHAND);
    effect eMightyL = EffectAttackIncrease(3, ATTACK_BONUS_OFFHAND);
    effect eDmg     = EffectDamageIncrease(DAMAGE_BONUS_3, DAMAGE_TYPE_MAGICAL);

    effect eLink = EffectLinkEffects(EffectLinkEffects(eMightyR, eMightyL), eDmg);
    eLink = TagEffect(eLink, AMULET_EFFECT);
    eLink = ExtraordinaryEffect(eLink);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GOOD_HELP), oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oPC);
}

void main()
{
    int nEvent = GetUserDefinedItemEventNumber();
    object oPC;
    object oItem;

    // Debug message
    if(DEBUG) DoDebug("jy_itnk_amf3 >> Event: " + IntToString(nEvent));
    
    switch (nEvent)
    {
        // Item equipped (any item)
        case X2_ITEM_EVENT_EQUIP:
            oPC = GetPCItemLastEquippedBy();
            oItem = GetPCItemLastEquipped();
            
            if(DEBUG) DoDebug("jy_itnk_amf3 >> Equipped: " + GetName(oItem));
            
            // If this is our amulet being equipped
            if (GetResRef(oItem) == AMULET_RES || GetTag(oItem) == AMULET_RES)
            {
                // Register for equipment change events
                AddEventScript(oPC, EVENT_ONPLAYEREQUIPITEM, SCRIPT_NAME, TRUE, FALSE);
                AddEventScript(oPC, EVENT_ONPLAYERUNEQUIPITEM, SCRIPT_NAME, TRUE, FALSE);
                
                // Apply effect if unarmed
                if (GetIsUnarmed(oPC))
                    ApplyAmuletEffect(oPC);
            }
            // If a weapon is equipped while wearing the amulet, remove the effect
            else if (WearingAmulet(oPC) && !GetIsUnarmed(oPC))
            {
                if(DEBUG) DoDebug("jy_itnk_amf3 >> Removing effect due to weapon equip");
                RemoveAmuletEffect(oPC);
            }
            break;
            
        // Item unequipped (any item)
        case X2_ITEM_EVENT_UNEQUIP:
            oPC = GetPCItemLastUnequippedBy();
            oItem = GetPCItemLastUnequipped();
            
            if(DEBUG) DoDebug("jy_itnk_amf3 >> Unequipped: " + GetName(oItem));
            
            // If this is our amulet being unequipped
            if (GetResRef(oItem) == AMULET_RES || GetTag(oItem) == AMULET_RES)
            {
                // Remove effect immediately when amulet is unequipped
                RemoveAmuletEffect(oPC);
                
                // Unregister events
                RemoveEventScript(oPC, EVENT_ONPLAYEREQUIPITEM, SCRIPT_NAME, TRUE, FALSE);
                RemoveEventScript(oPC, EVENT_ONPLAYERUNEQUIPITEM, SCRIPT_NAME, TRUE, FALSE);
            }
            // If a weapon is unequipped while wearing the amulet, and PC is now unarmed,
            // apply the effect
            else if (WearingAmulet(oPC) && GetIsUnarmed(oPC))
            {
                if(DEBUG) DoDebug("jy_itnk_amf3 >> Adding effect due to weapon unequip");
                ApplyAmuletEffect(oPC);
            }
            break;
            
        // Handle PRC eventhooks
        case EVENT_ONPLAYEREQUIPITEM:
            oPC = GetPCItemLastEquippedBy();
            oItem = GetPCItemLastEquipped();
            
            // If not wearing the amulet, do nothing
            if (!WearingAmulet(oPC)) 
                return;
                
            // If a weapon was equipped, remove the amulet effect
            if (!GetIsUnarmed(oPC))
            {
               if(DEBUG) DoDebug("jy_itnk_amf3 >> PRC Eventhook: Removing effect due to weapon equip");
                RemoveAmuletEffect(oPC);
            }
            break;

        case EVENT_ONPLAYERUNEQUIPITEM:
            oPC = GetPCItemLastUnequippedBy();
            oItem = GetPCItemLastUnequipped();
            
            // If not wearing the amulet, do nothing
            if (!WearingAmulet(oPC)) 
                return;
                
            // If they're now unarmed after unequipping something, apply the effect
            if (GetIsUnarmed(oPC))
            {
                if(DEBUG) DoDebug("jy_itnk_amf3 >> PRC Eventhook: Adding effect due to weapon unequip");
                ApplyAmuletEffect(oPC);
            }
            break;
    }
}