#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <zombiereloaded>
#include <smlib>

#define PL_VERSION "1.1"

new bool:hecho = false;

new gallina;
new cliente = 0;

public Plugin:myinfo =
{
    name        = "Beacon Chicken Last Human",
    author      = "Franc1sco franug",
    description = "Beacons last survivor for X seconds.",
    version     = PL_VERSION,
    url         = "http://steamcommunity.com/id/franug"
};


public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
}

public OnClientDisconnect(client)
{
	if(client == cliente)
	{
		if(gallina != 0)
		{
			new gallina2 = EntRefToEntIndex(gallina);
			if(gallina2 != -1 && IsValidEntity(gallina2)) 
			{
				SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
				AcceptEntityInput(gallina2, "Kill");
			}
		}
	}
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(victim == cliente)
	{
		if(gallina != 0)
		{
			new gallina2 = EntRefToEntIndex(gallina);
			if(gallina2 != -1 && IsValidEntity(gallina2)) 
			{
				SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
				AcceptEntityInput(gallina2, "Kill");
			}
		}
		hecho = false;
		
		return;
	}
	
	new humans = 0;
	new zombies = 0;
	cliente = 0;
	

	for(new i = 1; i <=MaxClients; ++i)
	{
		if (!IsClientInGame(i))
			continue;

		if (!IsPlayerAlive(i))
			continue;

		if (ZR_IsClientHuman(i))
		{
			humans++;
			cliente = i;
		}
		else if (ZR_IsClientZombie(i))
		{
			zombies++;
		}
	}

	if (zombies > 0 && humans == 1 && cliente != 0)
	{
		//SetEntProp(client, Prop_Send, "m_bShouldGlow", true, true);
		if(!hecho)
		{
			ServerCommand("sm_beacon #%i", GetClientUserId(cliente));
			//SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1, 1);
			    // Determine position for the model
			decl Float:Position[3]; 
			GetClientAbsOrigin(cliente, Position);
			Position[0] += 30.0;
			hecho = true;
			ThrowChicken(Position,cliente);
		}
	}
	else cliente = 0;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	hecho = false;
	if(gallina != 0)
	{
		new gallina2 = EntRefToEntIndex(gallina);
		if(gallina2 != -1 && IsValidEntity(gallina2)) 
		{
			SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
			AcceptEntityInput(gallina2, "Kill");
		}
	}
	cliente = 0;
}

stock ThrowChicken(Float:vSpawnPos[3],client)
{
	if(gallina != 0)
	{
		new gallina2 = EntRefToEntIndex(gallina);
		if(gallina2 != -1 && IsValidEntity(gallina2)) 
		{
			SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
			AcceptEntityInput(gallina2, "Kill");
		}
	}
	new chickent = CreateEntityByName("chicken");
	if(chickent == -1) return;
	DispatchSpawn(chickent);
    
	TeleportEntity(chickent, vSpawnPos, NULL_VECTOR, NULL_VECTOR);
	Entity_SetParent(chickent, client);
	//SetEntityMoveType(chickent, MOVETYPE_NONE);
	//Entity_Freeze(chickent);
	SetEntProp(chickent, Prop_Data, "m_takedamage", 0, 1);
	//SetEntData(chickent, g_offsCollisionGroup, 2, 4, true);
	SetEntProp(chickent, Prop_Send, "m_bShouldGlow", true, true);
	SetEntPropFloat(chickent, Prop_Send, "m_flModelScale", 5.0);
	SDKHook(chickent, SDKHook_SetTransmit, ShouldHide);
	gallina = EntIndexToEntRef(chickent);
	CreateTimer(1.0, Stop, client);
}

public Action:Stop(Handle:timer, any:client)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || !hecho)
		return;
		
	decl Float:Position2[3]; 
	GetClientAbsOrigin(client, Position2);
	Position2[0] += 30.0;
	ThrowChicken(Position2,client);
}

public Action:ShouldHide(ent, client)
{
	if(client == cliente)
		return Plugin_Handled;
	
	return Plugin_Continue;
}