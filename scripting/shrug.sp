#include <sourcemod>
#undef REQUIRE_PLUGIN
#include "sourceirc.inc"
#include "ccc.inc"
#include "cccm.inc"
#define REQUIRE_PLUGIN
#include "color_literals.inc"

#pragma semicolon 1
#pragma newdecls required

ConVar cvarTimer;
bool g_bCoolDown[MAXPLAYERS+1];
bool g_bIRC;
bool g_bCCC;
bool g_bCCCM;
// team index 0 will be for console, 1 is spec, 2 is red, 3 is blue
char g_sTeamColor[][] = {"FFFFFF", "CCCCCC", "FF4040", "99CCFF"};

public Plugin myinfo = {
	name = "¯\\_(ツ)_/¯",
	author = "¯\\_(ツ)_/¯",
	description = "¯\\_(ツ)_/¯",
	version = "¯\\_(ツ)_/¯",
	url = "¯\\_(ツ)_/¯"
}

public void OnPluginStart() {
	// create command
	RegAdminCmd("sm_shrug", cmdShrug, ADMFLAG_RESERVATION);
	// create convar to control cooldown timer if need.
	cvarTimer = CreateConVar("sm_shrug_timer", "30.0", "", FCVAR_NONE, true, 0.0);
}

public void OnAllPluginsLoaded(){
	g_bIRC = LibraryExists("sourceirc");
	g_bCCC = LibraryExists("ccc");
	g_bCCCM = LibraryExists("cccm");
}

public Action cmdShrug(int client, int args) {
	// If cooldown, do nothing
	if (g_bCoolDown[client]) {
		return Plugin_Handled;
	}

	char tag[24];
	if (g_bCCCM && CheckCommandAccess(client, "sm_ccc", ADMFLAG_RESERVATION) && !CCCM_IsTagHidden(client)) {
		CCC_GetTag(client, tag, sizeof(tag));
		int tagcolor = CCC_GetColor(client, CCC_TagColor);
		Format(tag, sizeof(tag), "\x07%06X%s ", tagcolor, tag);
	}

	int namecolor;
	int team = GetClientTeam(client);
	// if client == 0 or player doesn't have a custom color...
	if (!client || !g_bCCC || (namecolor = CCC_GetColor(client, CCC_NameColor)) < 0) {
		// ... then set their name color according to their team
		namecolor = StringToInt(g_sTeamColor[team], 16);
	}

	PrintColoredChatAll("%s\x07%06X%N\x01 : ¯\\_(ツ)_/¯", tag, namecolor, client);

	if (g_bIRC) {
		IRC_MsgFlaggedChannels("relay", "\x03%02d%N\x03: ¯\\_(ツ)_/¯", client ? IRC_GetTeamColor(team) : 0, client);
	}

	// enable cooldown
	g_bCoolDown[client] = true;
	// create 30 second timer for cooldown
	CreateTimer(cvarTimer.FloatValue, timerCoolDown, client);

	return Plugin_Handled;
}

Action timerCoolDown(Handle timer, int client) {
	// disable cooldown
	g_bCoolDown[client] = false;
}