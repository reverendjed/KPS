--[[[
@module Priest Holy Rotation
@author htordeux
@version 9.0.2
]]--

local spells = kps.spells.priest
local env = kps.env.priest

local HolyWordSanctify = spells.holyWordSanctify.name
local SpiritOfRedemption = spells.spiritOfRedemption.name
local MassDispel = spells.massDispel.name
local AngelicFeather = spells.angelicFeather.name
local DoorOfShadows = spells.doorOfShadows.name

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","HOLY", "concentration", "Interface\\Icons\\ability_priest_flashoflight", "concentration")
end)


-- kps.defensive to avoid overheal
kps.rotations.register("PRIEST","HOLY",{

    {spells.powerWordFortitude, 'not player.isInGroup and not player.hasBuff(spells.powerWordFortitude)', "player" },

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },

    env.holyWordSanctifyMessage,

    -- ShouldInterruptCasting
    {{"macro"}, 'spells.heal.shouldInterrupt(0.90, kps.defensive)' , "/stopcasting" },
    {{"macro"}, 'spells.flashHeal.shouldInterrupt(0.80, kps.defensive and not player.hasBuff(spells.flashConcentration))' , "/stopcasting" },
    {{"macro"}, 'spells.prayerOfHealing.shouldInterrupt(heal.countLossInRange(0.85), kps.defensive)' , "/stopcasting" },

    --{{"macro"}, 'player.hasBuff(spells.spiritOfRedemption) and heal.lowestInRaid.hp == 0' , "/cancelaura "..SpiritOfRedemption },
    {{"nested"}, 'player.hasBuff(spells.spiritOfRedemption)' ,{
        {spells.holyWordSerenity, 'true' , kps.heal.lowestInRaid},
        {spells.prayerOfMending, 'true' , kps.heal.lowestInRaid},
        {spells.circleOfHealing, 'true' , kps.heal.lowestInRaid},
        {spells.halo, 'true' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'true' , kps.heal.lowestInRaid},
    }},
    -- "Guardian Spirit" 47788
    {spells.guardianSpirit, 'player.hp < 0.35' , kps.heal.lowestTankInRaid},
    {spells.guardianSpirit, 'heal.lowestTankInRaid.hp < 0.35' , kps.heal.lowestTankInRaid},
    {spells.guardianSpirit, 'mouseover.isHealable and mouseover.hp < 0.35' , "mouseover" },
    {spells.guardianSpirit, 'heal.lowestInRaid.hp < 0.35' , kps.heal.lowestInRaid},
    -- "Holy Word: Serenity"
    {spells.holyWordSerenity, 'mouseover.isHealable and mouseover.hp < 0.40' , "mouseover" },
    {spells.holyWordSerenity, 'player.hp < 0.55' , "player"},
    {spells.holyWordSerenity, 'heal.lowestTankInRaid.hp < 0.55' , kps.heal.lowestTankInRaid},
    {spells.holyWordSerenity, 'heal.lowestInRaid.hp < 0.40' , kps.heal.lowestInRaid },
	-- "Surge of Light"
    {{"nested"},'player.hasBuff(spells.surgeOfLight)', {
		{spells.flashHeal, 'IsEquippedItem(173249) and not player.hasBuff(spells.flashConcentration)' , kps.heal.lowestInRaid , "flashHeal_Concentration_buff"  },
		{spells.flashHeal, 'player.hasBuff(spells.flashConcentration) and player.buffDuration(spells.flashConcentration) < 5' , kps.heal.lowestInRaid , "flashHeal_Concentration_duration" },
    	{spells.flashHeal, 'player.buffStacks(spells.surgeOfLight) == 2 and player.hasBuff(spells.flashConcentration) and player.buffStacks(spells.flashConcentration) < 5' , kps.heal.lowestInRaid , "flashHeal_Concentration_stacks"  },
        {spells.flashHeal, 'player.buffStacks(spells.surgeOfLight) == 2 and player.buffDuration(spells.flashConcentration) < 10' , kps.heal.lowestInRaid  },
    }},
    {spells.flashHeal, 'not player.isMoving and IsEquippedItem(173249) and not player.hasBuff(spells.flashConcentration) and heal.lowestInRaid.hp < 0.80 and not spells.flashHeal.lastCasted(5)' , kps.heal.lowestInRaid , "flashHeal_Concentration_buff" },    
	{spells.flashHeal, 'not player.isMoving and player.hasBuff(spells.flashConcentration) and player.buffDuration(spells.flashConcentration) < 5 and not spells.flashHeal.lastCasted(5)' , kps.heal.lowestInRaid , "flashHeal_Concentration_duration" }, 
	{spells.flashHeal, 'not player.isMoving and player.hasBuff(spells.flashConcentration) and player.buffStacks(spells.flashConcentration) < 5 and heal.lowestInRaid.hp < 0.65' , kps.heal.lowestInRaid , "flashHeal_Concentration_stacks" }, 

    -- "Dissipation de masse"
    {{"macro"}, 'keys.ctrl and spells.massDispel.cooldown == 0', "/cast [@cursor] "..MassDispel },
    -- "Holy Word: Sanctify"
    {{"macro"}, 'keys.shift and spells.holyWordSanctify.cooldown == 0', "/cast [@cursor] "..HolyWordSanctify },
    {{"macro"}, 'heal.countLossInDistance(0.85) > 2 and spells.holyWordSanctify.cooldown == 0' , "/cast [@player] "..HolyWordSanctify },
    {{"macro"}, 'not player.isInRaid and heal.countLossInDistance(0.85) > 1 and spells.holyWordSanctify.cooldown == 0' , "/cast [@player] "..HolyWordSanctify },
    -- "Door of Shadows" 
    {{"macro"}, 'not player.isMoving and spells.doorOfShadows.cooldown == 0 and keys.alt', "/cast [@cursor] "..DoorOfShadows},
    -- "Leap of Faith"
    --{spells.leapOfFaith, 'keys.alt and mouseover.isHealable', "mouseover" },
    -- "Fade" 586 "Disparition"
    {spells.fade, 'player.isTarget and player.isInGroup' },
    {spells.desperatePrayer, 'player.hp < 0.65' , "player" },
    -- "Pierre de soins" 5512
    --{{"macro"}, 'player.hp < 0.65 and player.useItem(5512)' , "/use item:5512" },
    -- "Angelic Feather"
    {{"macro"},'player.hasTalent(2,3) and not player.isSwimming and player.isMovingSince(1.6) and not player.hasBuff(spells.angelicFeather)' , "/cast [@player] "..AngelicFeather },
    -- "Levitate" 1706
    {spells.levitate, 'player.IsFallingSince(1.4) and not player.hasBuff(spells.levitate)' , "player" },

    -- "Dispel" "Purifier" 527
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'mouseover.isHealable and mouseover.isDispellable("Magic")' , "mouseover" },
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.isMagicDispellable' , kps.heal.isMagicDispellable },
    }},
    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    {{"nested"}, 'kps.interrupt' ,{
        {spells.holyWordChastise, 'player.hasTalent(4,2) and target.isInterruptable and target.isCasting' , "target" },
        {spells.holyWordChastise, 'player.hasTalent(4,2) and mouseover.isInterruptable and mouseover.isCasting' , "mouseover" },
        {spells.shiningForce, 'player.hasTalent(4,3) and player.isTarget and target.distance <= 10 and target.isCasting' , "player" },
        {spells.psychicScream, 'kps.groupSize() == 1 and player.hasTalent(4,3) and spells.shiningForce.cooldown > 0 and player.isTarget and target.distance <= 10 and target.isCasting' , "player" },
        {spells.psychicScream, 'kps.groupSize() == 1 and not player.hasTalent(4,3) and player.isTarget and target.distance <= 10 and target.isCasting' , "player" },
        -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
        {spells.dispelMagic, 'target.isAttackable and target.isBuffDispellable and not spells.dispelMagic.lastCasted(9)' , "target" },
        {spells.dispelMagic, 'mouseover.isAttackable and mouseover.isBuffDispellable and not spells.dispelMagic.lastCasted(9)' , "mouseover" },
    }},

    -- "Prayer of Mending"
    {spells.prayerOfMending, 'player.isPVP' , "player" },
    {spells.prayerOfMending, 'not heal.lowestTankInRaid.hasBuff(spells.prayerOfMending)' , kps.heal.lowestTankInRaid },
    {spells.prayerOfMending, 'true' , kps.heal.hasNotBuffMending },
    
    -- PVP
    {{"nested"}, 'player.hp < 0.65' ,{
        {spells.holyWard, 'player.isPVP' , "player" },
        {spells.powerWordShield, 'not player.hasDebuff(spells.weakenedSoul)' , "player" },
        {spells.heal, 'not player.isMoving and player.hp < 0.65 and player.hasBuff(spells.flashConcentration)' , "player" , "heal_player_Concentration" },
        {spells.flashHeal, 'not player.isMoving and player.hp < 0.65 and not spells.flashHeal.isRecastAt("player")' , "player" , "flashHeal_player" },
        {spells.flashHeal, 'not player.isMoving and player.hp < 0.40' , "player" , "flashHeal_player" },
        {spells.renew, 'not player.hasBuff(spells.renew)' , "player" },
    }},

    -- "Apotheosis" 200183 increasing the effects of Serendipity by 200% and reducing the cost of your Holy Words by 100% -- "Apotheosis" for PARTY
    {{"nested"}, 'not player.isMoving and player.hasBuff(spells.apotheosis)',{
        {spells.heal, 'player.hasBuff(spells.flashConcentration) and heal.lowestInRaid.hpIncoming < 0.80 ' , kps.heal.lowestInRaid , "heal_lowest_apotheosis" },
        {spells.flashHeal, 'heal.lowestTankInRaid.hp < 0.55' , kps.heal.lowestTankInRaid , "flashHeal_tank_apotheosis" },
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid , "flashHeal_lowest_apotheosis" },
    	{spells.prayerOfHealing, 'heal.countLossInRange(0.85) > 2' , kps.heal.lowestInRaid , "POH_apotheosis" },
    }},
    {spells.apotheosis, 'player.hasTalent(7,2) and heal.lowestTankInRaid.hp < 0.55 and spells.holyWordSerenity.cooldown > 2' },
    {spells.apotheosis, 'player.hasTalent(7,2) and heal.lowestInRaid.hp < 0.55 and heal.countLossInRange(0.80) > 2' },
    {spells.apotheosis, 'player.hasTalent(7,2) and heal.countLossInRange(0.65) > 2' },

    {spells.powerInfusion, 'heal.lowestTankInRaid.hp < 0.40 and spells.holyWordSerenity.cooldown > 2' },
    {spells.powerInfusion, 'heal.lowestInRaid.hp < 0.55 and heal.countLossInRange(0.80) > 4' },
    {spells.powerInfusion, 'not player.isInRaid and heal.lowestInRaid.hp < 0.55 and heal.countLossInRange(0.85) > 2' },
    {spells.powerInfusion, 'heal.countLossInRange(0.65) > 3' },

    -- MOUSEOVER
    {spells.heal, 'not player.isMoving and mouseover.isHealable and mouseover.hp < 0.80 and player.hasBuff(spells.flashConcentration)' , "mouseover" , "heal_mouseover" },
    {spells.flashHeal, 'not player.isMoving and mouseover.isHealable and mouseover.hp < 0.40' , "mouseover" , "flashHeal_mouseover" },
    {spells.prayerOfHealing, 'not player.isMoving and mouseover.isHealable and mouseover.hp < 0.80 and heal.countLossInRange(0.80) > 3 and spells.holyWordSanctify.cooldown > 30' , "mouseover" , "prayerOfHealing_mouseover" },
    {spells.prayerOfHealing, 'not player.isInRaid and not player.isMoving and mouseover.isHealable and mouseover.hp < 0.80 and heal.countLossInRange(0.80) > 2 and spells.holyWordSanctify.cooldown > 30' , "mouseover" , "prayerOfHealing_mouseover" },

    {spells.circleOfHealing, 'heal.lowestInRaid.hp < 0.85' , kps.heal.lowestInRaid },
    {spells.halo, 'player.isInRaid and not player.isMoving and player.hasTalent(6,3) and heal.countLossInRange(0.85) > 2' },
    {spells.mindgames, 'not player.isMoving and heal.lowestInRaid.hp < 0.85' , env.damageTarget },
    {spells.divineStar, 'player.hasTalent(6,2) and target.distance <= 30 and target.isAttackable' },

    -- TRINKETS -- SLOT 0 /use 13
    --{{"macro"}, 'player.useTrinket(0) and heal.countLossInRange(0.85) > 2' , "/use 13" },
    {{"macro"}, 'player.useTrinket(0) and not player.isMoving' , "/use [@player] 13" },
    -- TRINKETS -- SLOT 1 /use 14
    --{{"macro"}, 'player.useTrinket(1) and targettarget.isHealable' , "/use [@targettarget] 14" },
    --{{"macro"}, 'player.useTrinket(1) and player.hp < 0.65' , "/use [@player] 14" },
    {{"macro"}, 'player.useTrinket(1) and not player.isMoving' , "/use 14" },

    -- "Prayer of Healing" LASTCAST
    {{"nested"}, 'not player.isMoving and spells.prayerOfHealing.lastCasted(4) and player.hasBuff(spells.flashConcentration)' ,{
    	{spells.heal, 'player.hp < 0.65' , "player" , "heal_POH_Concentration" },
        {spells.heal, 'heal.lowestInRaid.hp < 0.65 and heal.lowestInRaid.hp < heal.lowestTankInRaid.hp' , kps.heal.lowestInRaid , "heal_POH_Concentration" },
        {spells.heal, 'heal.lowestTankInRaid.hp < 0.65' , kps.heal.lowestTankInRaid , "heal_POH_Concentration" },
    }},
    {{"nested"}, 'not player.isMoving and spells.prayerOfHealing.lastCasted(4)' ,{
        {spells.flashHeal, 'player.hp < 0.55' , "player" , "flashHeal_POH" },
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.40 and heal.lowestInRaid.hp < heal.lowestTankInRaid.hp' , kps.heal.lowestInRaid , "flashHeal_POH" },
        {spells.flashHeal, 'heal.lowestTankInRaid.hp < 0.55' , kps.heal.lowestTankInRaid , "flashHeal_POH" },
    }},
    -- "Prayer of Mending" LASTCAST
    {{"nested"}, 'not player.isMoving and spells.prayerOfMending.lastCasted(4) and player.hasBuff(spells.flashConcentration)' ,{
        {spells.heal, 'player.hp < 0.65' , "player" , "heal_POM_Concentration" },
        {spells.heal, 'heal.lowestInRaid.hp < 0.65 and heal.lowestInRaid.hp < heal.lowestTankInRaid.hp' , kps.heal.lowestInRaid , "heal_POM_Concentration" },
        {spells.heal, 'heal.lowestTankInRaid.hp < 0.65' , kps.heal.lowestTankInRaid , "heal_POM_Concentration" },
    }},
    {{"nested"}, 'not player.isMoving and spells.prayerOfMending.lastCasted(4)' ,{
        {spells.flashHeal, 'player.hp < 0.55' , "player" ,"flashHeal_POM" },
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.40 and heal.lowestInRaid.hp < heal.lowestTankInRaid.hp' , kps.heal.lowestInRaid ,"flashHeal_POM" },
        {spells.flashHeal, 'heal.lowestTankInRaid.hp < 0.55' , kps.heal.lowestTankInRaid ,"flashHeal_POM" },
    }},
    -- "Flash Concentration" -- Reduces the cast time of your Heal by 0.2 sec and increases its healing by 3%. 15 seconds remaining -- IsEquippedItem(173249)
    {spells.heal, 'not player.isMoving and heal.priestConcentration.hp < 0.65 and not spells.heal.isRecastAt(heal.priestConcentration.unit) and player.hasBuff(spells.flashConcentration)' , kps.heal.priestConcentration , "heal_priestConcentration" },
    {spells.heal, 'not player.isMoving and heal.lowestInRaid.hpIncoming  < 0.65 and heal.lowestInRaid.hpIncoming  < heal.lowestTankInRaid.hpIncoming and player.hasBuff(spells.flashConcentration)' , kps.heal.lowestInRaid , "heal_lowest_Concentration" },
    {spells.heal, 'not player.isMoving and player.hp < 0.65 and player.hpIncoming < heal.lowestTankInRaid.hpIncoming and player.hasBuff(spells.flashConcentration)' , "player" , "heal_player_Concentration"  },
    {spells.heal, 'not player.isMoving and heal.lowestTankInRaid.hpIncoming  < 0.65 and player.hasBuff(spells.flashConcentration)' , kps.heal.lowestTankInRaid , "heal_tank_Concentration"  },
    -- "Prayer of Healing"
    {spells.prayerOfHealing, 'not player.isMoving and heal.countLossInRange(0.80) > 3 and spells.holyWordSanctify.cooldown > 30' , kps.heal.lowestTankInRaid , "POH" },
    {spells.prayerOfHealing, 'not player.isInRaid and not player.isMoving and heal.countLossInRange(0.80) > 2 and spells.holyWordSanctify.cooldown > 30' , kps.heal.lowestInRaid , "POH" },

    {{"nested"}, 'player.isMoving' ,{
        {spells.renew, 'heal.lowestTankInRaid.hpIncoming < 0.85 and not heal.lowestTankInRaid.hasBuff(spells.renew)' , kps.heal.lowestTankInRaid },
        {spells.renew, 'player.hpIncoming < 0.85 and not player.hasBuff(spells.renew)' , "player" },
        {spells.powerWordShield, 'player.hp < 0.65 and not player.hasDebuff(spells.weakenedSoul)' , "player" },
        {spells.powerWordShield, 'heal.lowestInRaid.hp < 0.40 and not heal.lowestInRaid.hasDebuff(spells.weakenedSoul)' , kps.heal.lowestInRaid },
        {spells.renew, 'heal.lowestInRaid.hpIncoming < 0.65 and not heal.lowestInRaid.hasBuff(spells.renew)' , kps.heal.lowestInRaid },
        {spells.renew, 'not player.isInRaid and heal.lowestInRaid.hpIncoming < 0.85 and not heal.lowestInRaid.hasBuff(spells.renew)' , kps.heal.lowestInRaid },
    }},

    -- DAMAGE
    {spells.shadowWordDeath, 'target.isAttackable and target.hp < 0.20 and player.hp > 0.65' , "target" , "shadowWordDeath" },
    {spells.shadowWordDeath, 'mouseover.inCombat and mouseover.isAttackable and mouseover.hp < 0.20 and player.hp > 0.65' , "mouseover" , "shadowWordDeath" },
    {spells.shadowWordPain, 'target.isAttackable and target.myDebuffDuration(spells.shadowWordPain) < 4.8 and not spells.shadowWordPain.isRecastAt("target") and heal.lowestInRaid.hp > 0.80' , "target" },
    {spells.shadowWordPain, 'mouseover.isAttackable and mouseover.inCombat and mouseover.myDebuffDuration(spells.shadowWordPain) < 4.8 and not spells.shadowWordPain.isRecastAt("mouseover") and heal.lowestInRaid.hp > 0.80' , "mouseover" },
    {{"nested"}, 'kps.multiTarget and target.isAttackable' , {
        {spells.powerInfusion, 'not player.isInGroup and target.hp > 0.55' , env.damageTarget },
        {spells.powerInfusion, 'not player.isInGroup and target.isElite and target.hp > 0.20' , env.damageTarget },
        {spells.holyWordChastise, 'true' , env.damageTarget },
        {spells.holyFire, 'not player.isMoving' , env.damageTarget },
        {spells.mindgames, 'not player.isMoving' , env.damageTarget },
        {spells.smite, 'not player.isMoving' , env.damageTarget },
        {spells.holyNova, 'target.distance <= 10' , "target" },
    }},

    -- "Soins rapides"
    {spells.flashHeal, 'not player.isMoving and heal.lowestInRaid.hpIncoming < 0.40 and heal.lowestInRaid.hpIncoming < heal.lowestTankInRaid.hpIncoming' , kps.heal.lowestInRaid , "flashHeal_lowest" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hpIncoming < 0.40' , kps.heal.lowestTankInRaid , "flashHeal_tank"  },
    {spells.flashHeal, 'not player.isInRaid and not player.isMoving and heal.lowestInRaid.hpIncoming < 0.65 and heal.lowestInRaid.hpIncoming < heal.lowestTankInRaid.hpIncoming' , kps.heal.lowestInRaid , "flashHeal_lowest" },
    {spells.flashHeal, 'not player.isInRaid and not player.isMoving and heal.lowestTankInRaid.hpIncoming < 0.65' , kps.heal.lowestTankInRaid , "flashHeal_tank"  },
    -- "Soins"
    {spells.heal, 'kps.concentration and not player.isMoving and heal.lowestInRaid.hpIncoming < 0.80 and heal.lowestInRaid.hpIncoming < heal.lowestTankInRaid.hpIncoming' , kps.heal.lowestInRaid , "heal_lowest" },
    {spells.heal, 'kps.concentration and not player.isMoving and heal.lowestTankInRaid.hpIncoming < 0.80' , kps.heal.lowestTankInRaid , "heal_tank" },
    {spells.heal, 'not player.isInRaid and not player.isMoving and heal.lowestInRaid.hpIncoming < 0.80 and heal.lowestInRaid.hpIncoming < heal.lowestTankInRaid.hpIncoming' , kps.heal.lowestInRaid , "heal_lowest" },
    {spells.heal, 'not player.isInRaid and not player.isMoving and heal.lowestTankInRaid.hpIncoming < 0.80' , kps.heal.lowestTankInRaid , "heal_tank" },

    {spells.smite, 'not player.isMoving', env.damageTarget },
    {spells.holyNova, 'player.isMoving and target.distance <= 10' },

}
,"priest_holy_shadowlands")

--AZERITE
-- "Vitality Conduit"
--{spells.azerite.vitalityConduit, 'heal.lowestInRaid.hp < 0.65' , kps.heal.lowestInRaid },
--"Refreshment" -- Release all healing stored in The Well of Existence into an ally. This healing is amplified by 20%.
--{spells.azerite.refreshment, 'heal.lowestInRaid.hp < 0.65' , kps.heal.lowestInRaid },
--{spells.azerite.concentratedFlame, 'heal.lowestInRaid.hp < 0.85' , kps.heal.lowestInRaid },
-- "Concentrated Flame"
--{spells.azerite.concentratedFlame, 'heal.lowestInRaid.hp < 0.65' , kps.heal.lowestInRaid },
--{spells.azerite.concentratedFlame, 'target.isAttackable' , "target" },


-- MACRO --
--[[

#showtooltip Rénovation
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Rénovation

#showtooltip Soins rapides
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Soins rapides

#showtooltip Esprit gardien
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Esprit gardien

#showtooltip Prière de guérison
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Prière de guérison

#showtooltip Prière de soins
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Prière de soins

#showtooltip Purifier
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Purifier

#showtooltip Mot sacré : Sérénité
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Mot sacré : Sérénité

#showtooltip Supplique
/cast [@mouseover,exists,nodead,help][@player] Supplique

#showtooltip Mot de pouvoir : Bouclier
/cast [@mouseover,exists,nodead,help][@player] Mot de pouvoir : Bouclier

]]--


