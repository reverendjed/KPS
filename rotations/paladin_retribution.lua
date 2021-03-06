--[[[
@module Paladin Retribution Rotation
@author htordeux
@version 8.0.1
]]--
local spells = kps.spells.paladin
local env = kps.env.paladin


kps.runAtEnd(function()
   kps.gui.addCustomToggle("PALADIN","RETRIBUTION", "addControl", "Interface\\Icons\\spell_holy_sealofmight", "addControl")
end)

kps.rotations.register("PALADIN","RETRIBUTION",
{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat and mouseover.distanceMax <= 10' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat and mouseover.distanceMax <= 10' , "/target mouseover" },
    {{"macro"}, 'not focus.exists and mouseover.isAttackable and mouseover.inCombat and not mouseover.isUnit("target")' , "/focus mouseover" },
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },

    -- "Shield of Vengeance" -- Creates a barrier of holy light that absorbs (30 / 100 * Total health) damage for 15 sec.
    {spells.shieldOfVengeance, 'player.incomingDamage > 0 and target.distanceMax <= 10'},
    {spells.greaterBlessingOfKings, 'not player.isInGroup and not player.hasBuff(spells.greaterBlessingOfKings) and player.incomingDamage > 0' , "player" },

    {spells.blessingOfFreedom , 'player.isRoot' },
    {spells.everyManForHimself, 'player.isStun' },
    -- "Pierre de soins" 5512
    --{{"macro"}, 'player.useItem(5512) and player.hp <= 0.65' ,"/use item:5512" },
    -- "Potion de soins abyssale" 169451
    --{{"macro"}, 'player.useItem(169451) and player.hp <= 0.40' ,"/use item:169451" },
    
    -- "Divine Shield" -- Immune to all attacks and harmful effects. 8 seconds remaining
    {spells.divineShield, 'player.hp < 0.30' , "player" },
    
    -- "Lay on Hands" -- Heals a friendly target for an amount equal to your maximum health.
    {spells.layOnHands, 'player.hp < 0.30', "player" },
    {spells.layOnHands, 'heal.lowestTankInRaid.hp < 0.30', kps.heal.lowestTankInRaid },

    -- "Blessing of Protection" -- Places a blessing on a party or raid member, protecting them from all physical attacks for 10 sec.
    {spells.blessingOfProtection, 'player.hp < 0.30' , "player" },
    {spells.blessingOfProtection, 'heal.lowestInRaid.hp < 0.30 and not heal.lowestInRaid.isRaidTank' , kps.heal.lowestInRaid },  

    {spells.flashOfLight, 'player.hasTalent(6,1) and player.hp < 0.70 and player.buffStacks(spells.selflessHealer) >= 3', "player" },
    {spells.wordOfGlory , 'player.hasTalent(6,3) and player.hp < 0.65'}, 

    {{"nested"}, 'kps.addControl',{
		-- "Main d’entrave" -- Movement speed reduced by 70%. 10 seconds remaining
    	{spells.handOfHindrance, 'mouseover.isAttackable and mouseover.distanceMax <= 10 and mouseover.isMoving and not mouseover.isControlled' , "mouseover" },
    	{spells.handOfHindrance, 'target.isAttackable and target.distanceMax <= 10 and target.isMoving and not target.isControlled' , "target" },
    	{spells.hammerOfJustice, 'mouseover.isAttackable and mouseover.distanceMax <= 10 and mouseover.isMoving and not mouseover.isControlled' , "mouseover" },
    	{spells.hammerOfJustice, 'target.isAttackable and target.distanceMax <= 10 and target.isMoving and not target.isControlled' , "target" },
    }},
    {{"nested"}, 'kps.interrupt',{
        {spells.blindingLight, 'player.hasTalent(3,3) and target.distanceMax <= 10 and target.isCasting ' , "target" },
        {spells.hammerOfJustice, 'target.distanceMax <= 10 and target.isCasting and target.isInterruptable' , "target" },
        {spells.hammerOfJustice, 'focus.distanceMax <= 10 and focus.isCasting and focus.isInterruptable' , "focus" },
        -- " Réprimandes" "Rebuke" -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
        {spells.rebuke, 'target.isCasting and target.isInterruptable and target.castTimeLeft < 2' , "target" },
        {spells.rebuke, 'focus.isCasting and focus.isInterruptable and focus.castTimeLeft < 2' , "focus" },
    }},

    {{"nested"},'kps.cooldowns', {
        {spells.cleanseToxins, 'heal.isPoisonDispellable' , kps.heal.isPoisonDispellable },
        {spells.cleanseToxins, 'heal.isDiseaseDispellable' , kps.heal.isDiseaseDispellable },
    }},

    -- TRINKETS -- SLOT 0 /use 13
    --{{"macro"}, 'player.useTrinket(0) and player.timeInCombat > 5' , "/use 13" },
    -- TRINKETS -- SLOT 1 /use 14
    {{"macro"}, 'player.useTrinket(1) and player.buffDuration(spells.avengingWrath) > 20 and kps.timeInCombat > 30' , "/use 14" },
    {{"macro"}, 'player.useTrinket(1) and player.buffDuration(spells.crusade) > 20 and kps.timeInCombat > 30' , "/use 14" },

    -- AZERITE
    -- "Guardian of Azeroth" -- invoque un gardien d’Azeroth pendant 30 sec. 3 min cooldown.
    --{spells.azerite.guardianOfAzeroth, 'target.isAttackable' , "target" },
    {spells.azerite.concentratedFlame, 'target.isAttackable' , "target" },
    --{spells.azerite.theUnboundForce, 'target.isAttackable and target.distanceMax <= 30' , "target" },
    --{spells.azerite.memoryOfLucidDreams, 'target.isAttackable and player.myBuffDuration(spells.avengingWrath) > 15' , "target" },
    --{spells.azerite.memoryOfLucidDreams, 'target.isAttackable and player.myBuffDuration(spells.crusade) > 15' , "target" },
    
    {{"nested"},'kps.cooldowns and player.holyPower < 3', {
        {spells.judgment, 'target.distanceMax <= 30' , "target"  }, -- Generates 1 Holy Power. 10 sec cd 
        {spells.bladeOfJustice, 'target.distanceMax <= 10' , "target"  }, -- Generates 2 Holy Power. 10 sec cd
        {spells.crusaderStrike, 'spells.crusaderStrike.charges == 2 and target.distanceMax <= 10' , "target"  }, -- Generates 1 Holy Power
    }},

    {spells.inquisition, 'player.hasTalent(7,3) and player.myBuffDuration(spells.inquisition) < 15 and player.holyPower >= 2' , "target" },
    {{"nested"},'kps.cooldowns and player.holyPower >= 3', {
        {spells.avengingWrath, 'not player.hasBuff(spells.avengingWrath) and target.isAttackable and player.hasTalent(7,3) and player.myBuffDuration(spells.inquisition) > 25 and target.distanceMax <= 10' },
        {spells.avengingWrath, 'not player.hasBuff(spells.avengingWrath) and target.isAttackable and player.hasTalent(7,1) and target.distanceMax <= 10' },
        {spells.crusade, 'target.isAttackable and player.hasTalent(7,2) and target.distanceMax <= 10' },
    }},

    {spells.wakeOfAshes, 'not player.hasTalent(7,2) and spells.avengingWrath.cooldown > 30 and target.distanceMax <= 10 and player.holyPower < 2' , "target" },
    {spells.wakeOfAshes, 'player.hasTalent(7,2) and spells.crusade.cooldown > 30 and target.distanceMax <= 10 and player.holyPower < 2' , "target" },
    {spells.consecration, 'player.hasTalent(4,2) and not player.isMoving and not target.isMoving and target.distanceMax <= 5 and player.holyPower < 5' }, -- Generates 1 Holy Power.
    {{"nested"},'kps.multiTarget and target.isAttackable', {
        {spells.executionSentence, 'player.hasTalent(1,3) and target.distanceMax <= 20' , "target" },
        {spells.divineStorm, 'true' , "target"  },
        {spells.wakeOfAshes, 'target.distanceMax <= 10' , "target" },
    }},
    {spells.hammerOfWrath, 'player.hasTalent(2,3)' , "target" }, -- Generates 1 Holy Power.
    {spells.templarsVerdict, 'player.hasBuff(spells.righteousVerdict)' , "target" , "templarsVerdict_righteousVerdict" },
    {spells.templarsVerdict, 'target.hasMyDebuff(spells.judgment)' , "target" , "templarsVerdict_judgment" },
    {spells.executionSentence, 'player.hasTalent(1,3) and player.hasTalent(7,2) and target.distanceMax <= 20 and spells.crusade.cooldown > 20 ' , "target" , "executionSentence" },
    {spells.executionSentence, 'player.hasTalent(1,3) and not player.hasTalent(7,2) and target.distanceMax <= 20 and spells.avengingWrath.cooldown > 20 ' , "target" , "executionSentence" },
    {spells.divineStorm, 'player.hasBuff(spells.empyreanPower)' , "target" , "divineStorm_empyreanPower" },
    {spells.divineStorm, 'player.plateCount >= 3' , "target" , "divineStorm_plateCount" },
    {spells.templarsVerdict, 'true' , "target" , "templarsVerdict" },

    {spells.judgment, 'target.distanceMax <= 30' , "target" }, 
    {spells.bladeOfJustice, 'target.distanceMax <= 10' , "target" },  
    {spells.crusaderStrike, 'target.distanceMax <= 10' , "target" }, 

    -- "Empyrean Power" 286393 -- buff -- Your next Divine Storm is free and deals 0 additional damage.
    -- "Blade of Wrath" 281178 -- buff -- Your next Blade of Justice deals 25% increased damage.
    {{"macro"}, 'true' , "/startattack" },

}
,"paladin_retribution_bfa")
