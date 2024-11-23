Ext.Require("Stuff/Utils/_FileUtils.lua")
Ext.Require("Stuff/Utils/_ModUtils.lua")
Ext.Require("Stuff/Utils/_Logger.lua")


reportTable = {  }

function printCSV()
	for i, row in pairs(reportTable) do
		Logger:BasicDebug(table.concat(row, ","))
	end
	
	_D("Completed report")
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
	if status == "SNEAKING" then
		Logger:ClearLogFile()

		for i, v in pairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
			if Osi.IsImmortal(v.Uuid.EntityUuid) == 0 
			and Ext.Stats.Get(v.Data.StatsId).XPReward 
			and (v.Level and _C().Level.LevelName == v.Level.LevelName) then
				local uuid = v.Uuid.EntityUuid

				local xpData = Ext.StaticData.Get(Ext.Stats.Get(v.Data.StatsId).XPReward, "ExperienceReward")
				local record = {
					string.sub(Osi.GetTemplate(uuid), 0, -36) .. "_" .. uuid,
					v.Data.StatsId,
					Osi.GetFaction(uuid),
					Osi.GetCombatGroupID(uuid),
					Osi.CanFight(uuid),
					xpData.Name,
					xpData.PerLevelRewards[Osi.GetLevel(uuid)]
				}

				table.insert(reportTable, record)
			end
		end

		table.sort(reportTable, function (a, b)
			return a[2] < b[2]
		end)

		table.insert(reportTable, 1, { "uuid", "StatsId", "faction", "combatGroupId", "canFight", "XP Category", "experienceGiven" })
		printCSV()
	end
end)
