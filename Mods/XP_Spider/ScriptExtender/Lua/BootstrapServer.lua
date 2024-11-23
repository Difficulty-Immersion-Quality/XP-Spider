Ext.Require("Stuff/Utils/_FileUtils.lua")
Ext.Require("Stuff/Utils/_ModUtils.lua")
Ext.Require("Stuff/Utils/_Logger.lua")

Logger:ClearLogFile()

reportTable = { { "uuid", "StatsId", "faction", "combatGroupId", "canFight", "isBoss", "experienceGiven" } }

function printCSV()
	for i, row in pairs(reportTable) do
		Logger:BasicDebug(table.concat(row, ","))
	end

	_D("Completed report")
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
	if status == "SNEAKING" then

		for i, v in pairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
			if Osi.IsImmortal(v.Uuid.EntityUuid) == 0 and Ext.Stats.Get(v.Data.StatsId).XPReward then
				local uuid = v.Uuid.EntityUuid

				local record = {
					string.sub(Osi.GetTemplate(uuid), 0, -36) .. "_" .. uuid,
					v.Data.StatsId,
					Osi.GetFaction(uuid),
					Osi.GetCombatGroupID(uuid),
					Osi.CanFight(uuid),
					Osi.IsBoss(uuid),
					Ext.StaticData.Get(Ext.Stats.Get(v.Data.StatsId).XPReward, "ExperienceReward").PerLevelRewards[Osi.GetLevel(uuid)]
				}

				table.insert(reportTable, record)
			end
		end

		printCSV()
	end
end)
