vision = class({})

function vision:fow_check(unit,location)

  dummy = CreateUnitByName("npc_dummy_unit", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
  bool = unit:CanEntityBeSeenByMyTeam(dummy)
  UTIL_Remove(dummy)
  return bool
   
end