//:://////////////////////////////////////////////
//:: Rejuvenation stones
//:: Created By: Jaysyn
//:: Created On: 2025-11-15 15:53:21
//:://////////////////////////////////////////////
//:: hp_rejuvstone.nss
//:://////////////////////////////////////////////
//:: Original By: Jason Stephenson
//:: Created On: August 3, 2004
//:://////////////////////////////////////////////
#include "psi_inc_ppoints"
#include "x2_inc_switches"

int GetTagBasedItemEventNumber()
{
    int nEvent = GetLocalInt(OBJECT_SELF, "X2_L_LAST_ITEM_EVENT");
    return (nEvent ? nEvent : GetLocalInt(GetModule(), "X2_L_LAST_ITEM_EVENT"));
}
void SetTagBasedScriptExitBehavior(int nEndContinue)
{
    if (nEndContinue == X2_EXECUTE_SCRIPT_END)
    {
        DeleteLocalInt(OBJECT_SELF, "X2_L_LAST_ITEM_EVENT");
        DeleteLocalInt(GetModule(), "X2_L_LAST_ITEM_EVENT");
    }
    SetExecutedScriptReturnValue(nEndContinue);
}
void main()
{
    // Get which event was fired.
    int nEvent = GetTagBasedItemEventNumber();

    // We usually want to get both the PC and the item.
    object oPC;
    object oItem;

    // Our unique power was activated.
    if (nEvent == X2_ITEM_EVENT_ACTIVATE)
    {
        oPC 			= GetItemActivator();
        oItem 			= GetItemActivated();
		
		string sResref	= GetResRef(oItem);
		
		int nMaxPP 		= GetMaximumPowerPoints(oPC);
		int nCurrentPP	= GetCurrentPowerPoints(oPC);
		int bIsPsionic	= GetIsPsionicCharacter(oPC);
		
		effect eSave;
		effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
		effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);		
		
		if(bIsPsionic)
		{
			int nHealPP;

			if 		(sResref == "hp_rejuvstone001") {nHealPP = d3(1)+2;}
			else if	(sResref == "hp_rejuvstone002") {nHealPP = d4(1)+2;}
			else if	(sResref == "hp_rejuvstone003") {nHealPP = d6(1)+2;}	
			else if	(sResref == "hp_rejuvstone004") {nHealPP = d8(1)+2;}	
			else if	(sResref == "hp_rejuvstone005") {nHealPP = d10(1)+2;}		
		
			if(nHealPP + nCurrentPP > nMaxPP)
				nHealPP = nMaxPP - nCurrentPP;
			
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
			
			GainPowerPoints(oPC, nHealPP, FALSE, TRUE);
		}			
		else
		{
			effect eEffect = GetFirstEffect(oPC);
			while(GetIsEffectValid(eEffect))
			{
				if(GetEffectTag(eEffect) == "MENTAL_REJUVENATION")
					RemoveEffect(oPC, eEffect);
			
				eEffect = GetNextEffect(oPC);
			
			}
			int nBonus = 2; //Saving throw bonus to be applied
		
			//Set the bonus save effect
			eSave 			= EffectSavingThrowIncrease(SAVING_THROW_WILL, nBonus);
			
			effect eLink 	= EffectLinkEffects(eSave, eDur);
			eLink 			= UnyieldingEffect(eLink);
			eLink			= TagEffect(eLink, "MENTAL_REJUVENATION");

			//Apply the bonus effect and VFX impact
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, TurnsToSeconds(2));
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);	
		}
		
    // We set the return value, and then fall through the end of the
    // script. This assumes that we've done all we need to do here and
    // don't need any of the standard module scripts to do any more
    // processing.
    SetTagBasedScriptExitBehavior(X2_EXECUTE_SCRIPT_END);
	}
}
