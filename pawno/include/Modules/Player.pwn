/*
 *
 *
 *			Nogov Player Module
 *		  	2013/01/02
 *
 *
 *		Copyright (c) sBum. All rights reserved.
 *
 *
 */
/*

  < Callbacks >
	gInitHandler_Player(playerid)
	pConnectHandler_Player(playerid)
	pDisconnectHandler_Player(playerid)
	pRequestClassHandler_Player(playerid, classid)
	aConnectHandler_Player(playerid)
	pUpdateHandler_Player(playerid)
	pDeathHandler_Player(playerid, killerid, reason)
	pSpawnHandler_Player(playerid)
	dRequestHandler_Player(playerid, dialogid, olddialogid)
	dResponseHandler_Player(playerid, dialogid, response, listitem, inputtext[])
	pTimerTickHandler_Player(nsec, playerid)
	pTakeDamageHandler_Player(playerid, issuerid, Float:amount, weaponid)

  < Functions >
	CreatePlayerDataTable()
	SavePlayerData(playerid)
	LoadPlayerData(playerid)
	ShowPlayerLoginMovie(playerid)
	ShowPlayerLoginDialog(playerid, bool:wrong)
	SpawnPlayer_(playerid)
	ShowPlayerPlunderStatus(playerid)
	IsMeleeWeapon(weaponid)
	IdBan(playerid, reason[])
	IpBan(playerid, reason[])
	ShowPlayerBanDialog(playerid, name[], reason[], date[], type)
	SetPlayerData(playerid, varname[], vartype, int_value, Float:float_value, string_value[])
	InsertPlayerData(playerid, varname[], vartype, int_value, Float:float_value, string_value[], encryption[]="")
	DeletePlayerData(playerid, varname[])

*/



//-----< Defines
#define MAX_PLAYER_DATAS			30
#define DialogId_Player(%0)			(25+%0)



//-----< Variables
enum ePlayerData
{
	pdVarname[64],
	pdVartype,
	bool:pdSave
}
new bool:HeavyWalking[MAX_PLAYERS],
	bool:Tired[MAX_PLAYERS],
	bool:TiredWalking[MAX_PLAYERS],
	PlunderId[MAX_PLAYERS],
	PlunderTime[MAX_PLAYERS],
	bool:Dead[MAX_PLAYERS],
	Float:DeadPos[MAX_PLAYERS][4],
	DeadInterior[MAX_PLAYERS],
	DeadVirtualWorld[MAX_PLAYERS],
	DeadAnim[MAX_PLAYERS],
	KillerId[MAX_PLAYERS],
	PlayerData[MAX_PLAYERS][MAX_PLAYER_DATAS][ePlayerData],
	NumSaveDatas[MAX_PLAYERS],
	LoginTextDraw[5];



//-----< Callbacks
forward gInitHandler_Player();
forward pConnectHandler_Player(playerid);
forward pDisconnectHandler_Player(playerid);
forward pRequestClassHandler_Player(playerid, classid);
forward aConnectHandler_Player(playerid);
forward pUpdateHandler_Player(playerid);
forward pDeathHandler_Player(playerid, killerid, reason);
forward pKeyStateChangeHandler_Player(playerid, newkeys, oldkeys);
forward pSpawnHandler_Player(playerid);
forward pCommandTextHandler_Player(playerid, cmdtext[]);
forward dRequestHandler_Player(playerid, dialogid, olddialogid);
forward dResponseHandler_Player(playerid, dialogid, response, listitem, inputtext[]);
forward pTimerTickHandler_Player(nsec, playerid);
forward pTakeDamageHandler_Player(playerid, issuerid, Float:amount, weaponid);
//-----< gInitHandler >---------------------------------------------------------
public gInitHandler_Player()
{
	CreatePlayerDataTable();
	
	LoginTextDraw[0] = TextDrawCreate(320.000000, 1.000000, ".");
	TextDrawUseBox(LoginTextDraw[0], 1);
	TextDrawBoxColor(LoginTextDraw[0], 0x000000ff);
	TextDrawTextSize(LoginTextDraw[0], 50.000000, -650.000000);
	TextDrawAlignment(LoginTextDraw[0], 2);
	TextDrawBackgroundColor(LoginTextDraw[0], 0x00000000);
	TextDrawFont(LoginTextDraw[0], 3);
	TextDrawLetterSize(LoginTextDraw[0], 1.000000, 13.100000);
	TextDrawColor(LoginTextDraw[0], 0x00000000);
	TextDrawSetOutline(LoginTextDraw[0], 1);
	TextDrawSetProportional(LoginTextDraw[0], 1);
	TextDrawSetShadow(LoginTextDraw[0], 1);

	LoginTextDraw[1] = TextDrawCreate(317.000000, 121.000000, ".");
	TextDrawUseBox(LoginTextDraw[1], 1);
	TextDrawBoxColor(LoginTextDraw[1], 0x0000ffff);
	TextDrawTextSize(LoginTextDraw[1], 10.000000, -650.000000);
	TextDrawAlignment(LoginTextDraw[1], 2);
	TextDrawBackgroundColor(LoginTextDraw[1], 0x00000000);
	TextDrawFont(LoginTextDraw[1], 3);
	TextDrawLetterSize(LoginTextDraw[1], 1.000000, -0.000000);
	TextDrawColor(LoginTextDraw[1], 0x00000000);
	TextDrawSetOutline(LoginTextDraw[1], 1);
	TextDrawSetProportional(LoginTextDraw[1], 1);
	TextDrawSetShadow(LoginTextDraw[1], 1);

	LoginTextDraw[2] = TextDrawCreate(320.000000, 330.000000, ".");
	TextDrawUseBox(LoginTextDraw[2], 1);
	TextDrawBoxColor(LoginTextDraw[2], 0x000000ff);
	TextDrawTextSize(LoginTextDraw[2], 50.000000, -650.000000);
	TextDrawAlignment(LoginTextDraw[2], 2);
	TextDrawBackgroundColor(LoginTextDraw[2], 0x00000000);
	TextDrawFont(LoginTextDraw[2], 3);
	TextDrawLetterSize(LoginTextDraw[2], 1.000000, 13.100000);
	TextDrawColor(LoginTextDraw[2], 0x00000000);
	TextDrawSetOutline(LoginTextDraw[2], 1);
	TextDrawSetProportional(LoginTextDraw[2], 1);
	TextDrawSetShadow(LoginTextDraw[2], 1);

	LoginTextDraw[3] = TextDrawCreate(317.000000, 327.000000, ".");
	TextDrawUseBox(LoginTextDraw[3], 1);
	TextDrawBoxColor(LoginTextDraw[3], 0x0000ffff);
	TextDrawTextSize(LoginTextDraw[3], 10.000000, -650.000000);
	TextDrawAlignment(LoginTextDraw[3], 2);
	TextDrawBackgroundColor(LoginTextDraw[3], 0x00000000);
	TextDrawFont(LoginTextDraw[3], 3);
	TextDrawLetterSize(LoginTextDraw[3], 1.000000, -0.000000);
	TextDrawColor(LoginTextDraw[3], 0x00000000);
	TextDrawSetOutline(LoginTextDraw[3], 1);
	TextDrawSetProportional(LoginTextDraw[3], 1);
	TextDrawSetShadow(LoginTextDraw[3], 1);

	LoginTextDraw[4] = TextDrawCreate(250.000000, 31.000000, "Nogov");
	TextDrawAlignment(LoginTextDraw[4], 1);
	TextDrawBackgroundColor(LoginTextDraw[4], 0x0000ffff);
	TextDrawFont(LoginTextDraw[4], 0);
	TextDrawLetterSize(LoginTextDraw[4], 1.500000, 5.299998);
	TextDrawColor(LoginTextDraw[4], 0xffffffff);
	TextDrawSetOutline(LoginTextDraw[4], 1);
	TextDrawSetProportional(LoginTextDraw[4], 1);
	TextDrawSetShadow(LoginTextDraw[4], 1);
	return 1;
}
//-----< pConnectHandler >------------------------------------------------------
public pConnectHandler_Player(playerid)
{
	HeavyWalking[playerid] = false;
	Tired[playerid] = false;
	TiredWalking[playerid] = false;
	PlunderId[playerid] = INVALID_PLAYER_ID;
	PlunderTime[playerid] = 0;
	Dead[playerid] = false;
	for (new i = 0; i < 3; i++)
		DeadPos[playerid][0] = 0.0;
	DeadInterior[playerid] = 0;
	DeadVirtualWorld[playerid] = 0;
	DeadAnim[playerid] = 0;
	KillerId[playerid] = INVALID_PLAYER_ID;
	for (new i = 0; i < MAX_PLAYER_DATAS; i++)
	{
		strcpy(PlayerData[playerid][i][pdVarname], chNullString);
		PlayerData[playerid][i][pdVartype] = PLAYER_VARTYPE_NONE;
		PlayerData[playerid][i][pdSave] = false;
	}
	NumSaveDatas[playerid] = 0;

	new str[512], receive[4][128];
	for (new i; i < 20; i++)
		SendClientMessage(playerid, COLOR_WHITE, chEmpty);
	if (!GetPVarInt(playerid, "LoggedIn"))
	{
		format(str, sizeof(str), "SELECT * From playerdata WHERE Name='%s' And Varname='pPassword'", GetPlayerNameA(playerid));
		mysql_query(str);
		mysql_store_result();
		if (mysql_num_rows() > 0)
		{
			SetPVarInt(playerid, "Registered", true);
		}
		mysql_free_result();
	}

	format(str, sizeof(str), "SELECT * FROM bandata WHERE (Name='%s' AND IP=' ') OR IP='%s'", GetPlayerNameA(playerid), GetPlayerIpA(playerid));
	mysql_query(str);
	mysql_store_result();
	if (mysql_num_rows() > 0)
	{
		mysql_fetch_field("Name", receive[0]);
		mysql_fetch_field("Reason", receive[1]);
		mysql_fetch_field("Date", receive[2]);
		mysql_fetch_field("Type", receive[3]);
		mysql_free_result();
		ShowPlayerBanDialog(playerid, receive[0], receive[1], receive[2], strval(receive[3]));
	}
	mysql_free_result();

	return 1;
}
//-----< pDisconnectHandler >---------------------------------------------------
public pDisconnectHandler_Player(playerid)
{
	SavePlayerData(playerid);
	for (new i = 0, t = GetMaxPlayers(); i < t; i++)
		if (PlunderId[i] == playerid)
		{
			PlunderId[i] = INVALID_PLAYER_ID;
			for (new j = 0, u = GetMaxPlayerItems(); j < u; j++)
				if (IsValidPlayerItemID(playerid, j))
					DestroyPlayerItem(playerid, j);
			ShowPlayerDialog(i, 0, DIALOG_STYLE_MSGBOX, "�˸�", "���ڰ� ������ �����߽��ϴ�.\n���ڴ� ��� �������� �Ұ� �˴ϴ�.", "Ȯ��", chNullString);
		}
	return 1;
}
//-----< pRequestClassHandler >-------------------------------------------------
public pRequestClassHandler_Player(playerid, classid)
{
	SpawnPlayer_(playerid);
	if (!GetPVarInt(playerid, "LoggedIn"))
	{
		ShowPlayerLoginMovie(playerid);
		ShowPlayerLoginDialog(playerid, false);
	}
	return 1;
}
//-----< aConnectHandler >------------------------------------------------------
public aConnectHandler_Player(playerid)
{
	if (!GetPVarInt(playerid, "LoggedIn"))
		PlayAudioStreamForPlayer(playerid, GetGVarString("IntroMusic"));
	return 1;
}
//-----< pUpdateHandler >-------------------------------------------------------
public pUpdateHandler_Player(playerid)
{
	Streamer_Update(playerid);

	new Float:x, Float:y, Float:z,
		keys, ud, lr;
	if (IsPlayerInAnyVehicle(playerid) || !GetPVarInt(playerid, "LoggedIn")) return 1;

	GetPlayerVelocity(playerid, x, y, z);
	GetPlayerKeys(playerid, keys, ud, lr);
	new Float:bag = (float(GetPlayerItemsWeight(playerid, "����")) / float(GetPVarInt(playerid, "pWeight"))) * 100,
		Float:hand = (float(GetPlayerItemsWeight(playerid, "��")) / float(GetPVarInt(playerid, "pPower"))) * 100;

	if (bag > 75.0 || hand > 75.0)
	{
		if (z > 0.0)
		{
			SetPlayerVelocity(playerid, 0.0, 0.0, -z);
		}
		else if (ud != 0 || lr != 0)
		{
			HeavyWalking[playerid] = true;
			ApplyAnimation(playerid, "PED", "WALK_fatold", 4.1, 1, 1, 1, 1, 1, true);
		}
		else if (HeavyWalking[playerid])
		{
			HeavyWalking[playerid] = false;
			ClearAnimations(playerid, true);
		}
	}

	return 1;
}
//-----< pDeathHandler >--------------------------------------------------------
public pDeathHandler_Player(playerid, killerid, reason)
{
	SetPVarInt(playerid, "Spawned", false);
	killerid = KillerId[playerid];
	KillerId[playerid] = INVALID_PLAYER_ID;
	if (!GetPVarInt(playerid, "LoggedIn")) return 0;

	PlunderTime[playerid] = 60;
	Dead[playerid] = true;
	GetPlayerPos(playerid, DeadPos[playerid][0], DeadPos[playerid][1], DeadPos[playerid][2]);
	GetPlayerFacingAngle(playerid, DeadPos[playerid][3]);
	DeadInterior[playerid] = GetPlayerInterior(playerid);
	DeadVirtualWorld[playerid] = GetPlayerVirtualWorld(playerid);
	if (IsPlayerConnected(killerid))
	{
		PlunderId[killerid] = playerid;
		SendClientMessage(killerid, COLOR_WHITE, "��ü �ֺ����� "C_YELLOW"FŰ"C_WHITE"�� ���� �������� Ż���� �� �ֽ��ϴ�.");
		ShowPlayerItemList(killerid, playerid, DialogId_Player(4), "All");
	}
	ShowPlayerPlunderStatus(playerid);
	return 1;
}
//-----< pKeyStateChangeHandler >-----------------------------------------------
public pKeyStateChangeHandler_Player(playerid, newkeys, oldkeys)
{
	if (IsPlayerInAnyVehicle(playerid)) return 1;
	if (newkeys == KEY_SECONDARY_ATTACK)
	{
		for (new i = 0, t = GetMaxPlayers(); i < t; i++)
			if (IsPlayerConnected(i) && GetPVarInt(i, "LoggedIn") && Dead[i])
			{
				new Float:x, Float:y, Float:z;
				GetPlayerPos(i, x, y, z);
				if (IsPlayerInRangeOfPoint(playerid, 2.0, x, y, z) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
				{
					PlunderId[playerid] = i;
					ShowPlayerItemList(playerid, i, DialogId_Player(4), "All");
					break;
				}
			}
	}
	return 1;
}
//-----< pSpawnHandler >--------------------------------------------------------
public pSpawnHandler_Player(playerid)
{
	if (!GetPVarInt(playerid, "LoggedIn")) return 1;
	
	SetPVarInt(playerid, "Spawned", true);
	StopAudioStreamForPlayer(playerid);

	if (!GetPVarInt(playerid, "FirstSpawn"))
	{
		SetPVarInt(playerid, "FirstSpawn", true);
		SetPlayerSkin(playerid, GetPVarInt(playerid, "pSkin"));
		SetPlayerTeam(playerid, 0);
		SetPlayerHealth(playerid, GetPVarFloat(playerid, "pHealth"));
		SetPlayerArmour(playerid, GetPVarFloat(playerid, "pArmour"));
	}

	if (GetPVarInt(playerid, "RestoreSpawn"))
	{
		new receive[6][16];
		split(GetPVarString(playerid, "pLastPos"), receive, ',');
		SetPlayerPos(playerid, floatstr(receive[0]), floatstr(receive[1]), floatstr(receive[2]));
		SetPlayerFacingAngle(playerid, floatstr(receive[3]));
		SetPlayerInterior(playerid, strval(receive[4]));
		SetPlayerVirtualWorld(playerid, strval(receive[5]));
		SetPVarInt(playerid, "RestoreSpawn", false);
	}

	if (Dead[playerid])
	{
		SetPlayerPos(playerid, DeadPos[playerid][0], DeadPos[playerid][1], DeadPos[playerid][2]);
		SetPlayerFacingAngle(playerid, DeadPos[playerid][3]);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, DeadInterior[playerid]);
		SetPlayerVirtualWorld(playerid, DeadVirtualWorld[playerid]);
		DeadAnim[playerid] = random(4);
	}
	return 1;
}
//-----< pCommandTextHandler >--------------------------------------------------
public pCommandTextHandler_Player(playerid, cmdtext[])
{
	new cmd[256], idx,
		str[256];
	cmd = strtok(cmdtext, idx);

	if (!GetPVarInt(playerid, "LoggedIn")) return 0;
	else if (!strcmp(cmd, "/�������", true) || !strcmp(cmd, "/��ȣ����", true))
	{
		format(str, sizeof(str), "\
		\n\
		�� ��й�ȣ�� �Է��ϼ���.\n\
		\n\
		");
		ShowPlayerDialog(playerid, DialogId_Player(1), DIALOG_STYLE_PASSWORD, "��й�ȣ ����", str, "Ȯ��", "���");
		return 1;
	}
	return 0;
}
//-----< dRequestHandler >------------------------------------------------------
public dRequestHandler_Player(playerid, dialogid, olddialogid)
{
	if (dialogid != DialogId_Player(4))
		PlunderId[playerid] = INVALID_PLAYER_ID;
	if (olddialogid == DialogId_Player(3))
	{
		Kick(playerid);
		return 0;
	}
	return 1;
}
//-----< dResponseHandler >-----------------------------------------------------
public dResponseHandler_Player(playerid, dialogid, response, listitem, inputtext[])
{
	new str[256];
	switch (dialogid - DialogId_Player(0))
	{
		case 0:
			if (!GetPVarInt(playerid, "Registered"))
			{
				if (strlen(inputtext) >= 8)
				{
					new year, month, day;
					getdate(year, month, day);
					format(str, sizeof(str), "%04d%02d%02d", year, month, day);
					InsertPlayerData(playerid, "pRegDate", PLAYER_VARTYPE_STRING, 0, 0.0, str);
					InsertPlayerData(playerid, "pPassword", PLAYER_VARTYPE_STRING, 0, 0.0, inputtext, "SHA1");
					InsertPlayerData(playerid, "pIP", PLAYER_VARTYPE_STRING, 0, 0.0, GetPlayerIpA(playerid));
					InsertPlayerData(playerid, "pSkin", PLAYER_VARTYPE_INT, 29, 0.0, chNullString);
					InsertPlayerData(playerid, "pWeight", PLAYER_VARTYPE_INT, 50, 0.0, chNullString);
					InsertPlayerData(playerid, "pPower", PLAYER_VARTYPE_INT, 50, 0.0, chNullString);
					InsertPlayerData(playerid, "pHealth", PLAYER_VARTYPE_FLOAT, 0, 100.0, chNullString);
					
					SetPVarInt(playerid, "Registered", true);
					ShowPlayerLoginDialog(playerid, false);
				}
				else
					ShowPlayerLoginDialog(playerid, true);
			}
			else if (!GetPVarInt(playerid, "LoggedIn"))
			{
				format(str, sizeof(str), "SELECT * FROM playerdata WHERE Name='%s' AND Varname='pPassword' And Value=SHA1('%s')", GetPlayerNameA(playerid), inputtext);
				mysql_query(str);
				mysql_store_result();
				if (mysql_num_rows() == 1)
				{
					SetPVarInt(playerid, "LoggedIn", true);
					for (new i = 0; i < sizeof(LoginTextDraw); i++)
						TextDrawHideForPlayer(playerid, LoginTextDraw[i]);
					LoadPlayerData(playerid);
					if (strlen(GetPVarString(playerid, "pLastPos")) > 10)
						ShowPlayerDialog(playerid, DialogId_Player(2), DIALOG_STYLE_LIST, "�α���", "������\n��ġ ����", "����", chNullString);
					else
						SpawnPlayer_(playerid);
				}
				else
					ShowPlayerLoginDialog(playerid, true);
				mysql_free_result();
			}
		case 1:
			if (response)
				if (strlen(inputtext) >= 8)
				{
					InsertPlayerData(playerid, "pPassword", PLAYER_VARTYPE_STRING, 0, 0.0, inputtext, "SHA1");
					SendClientMessage(playerid, COLOR_LIGHTBLUE, "��й�ȣ�� ���������� ����Ǿ����ϴ�.");
				}
				else
				{
					format(str, sizeof(str), "\
					\n\
					�� ��й�ȣ�� �Է��ϼ���.\n\
					��й�ȣ�� �ݵ�� 8�ڸ� �̻��̾�� �մϴ�.\n\
					\n\
					");
					ShowPlayerDialog(playerid, DialogId_Player(1), DIALOG_STYLE_PASSWORD, "��й�ȣ ����", str, "Ȯ��", "���");
				}
		case 2:
		{
			if (listitem == 1)
				SetPVarInt(playerid, "RestoreSpawn", true);
			SpawnPlayer_(playerid);
		}
		case 3: return Kick(playerid);
		case 4:
		{
			if (response)
			{
				if (!listitem) return ShowPlayerItemList(playerid, PlunderId[playerid], DialogId_Player(4));
				new itemid = DialogData[playerid][listitem],
					plunderid = PlunderId[playerid];
				if (!IsPlayerConnected(plunderid)) return 1;
				GivePlayerItemToPlayer(plunderid, playerid, itemid, "����");
				SendClientMessage(playerid, COLOR_WHITE, "�������� Ż���߽��ϴ�.");
			}
			PlunderId[playerid] = INVALID_PLAYER_ID;
		}
		case 5:
		{
			if (PlunderTime[playerid] && !GetPVarInt(playerid, "pAdmin") || !GetPVarInt(playerid, "Spawned"))
				return ShowPlayerPlunderStatus(playerid);
			Dead[playerid] = false;
			PlunderTime[playerid] = 0;
			SpawnPlayer_(playerid);
			ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "�˸�", "�������Ǿ����ϴ�.", "Ȯ��", chNullString);
			for (new i = 0, t = GetMaxPlayers(); i < t; i++)
				if (PlunderId[i] == playerid)
				{
					PlunderId[i] = INVALID_PLAYER_ID;
					ShowPlayerDialog(i, 0, DIALOG_STYLE_MSGBOX, "�˸�", "���ڰ� �������Ǿ����ϴ�.", "Ȯ��", chNullString);
				}
		}
	}
	return 1;
}
//-----< pTimerTickHandler >----------------------------------------------------
public pTimerTickHandler_Player(nsec, playerid)
{
	if (!IsPlayerConnected(playerid) || !GetPVarInt(playerid, "LoggedIn")) return 1;

	if (nsec == 1000)
	{
		new Float:pos[4],
			interior = GetPlayerInterior(playerid),
			virtualworld = GetPlayerVirtualWorld(playerid),
			Float:health, Float:armour,
			str[64];

		if (GetPVarInt(playerid, "Spawned"))
		{
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			GetPlayerFacingAngle(playerid, pos[3]);
			format(str, sizeof(str), "%.4f,%.4f,%.4f,%.4f,%d,%d", pos[0], pos[1], pos[2], pos[3], interior, virtualworld);
			SetPVarString(playerid, "pLastPos", str);
			GetPlayerHealth(playerid, health);
			SetPVarFloat(playerid, "pHealth", health);
			GetPlayerArmour(playerid, armour);
			SetPVarFloat(playerid, "pArmour", armour);
		}

		if (PlunderTime[playerid])
		{
			PlunderTime[playerid]--;
			ShowPlayerPlunderStatus(playerid);
			switch (DeadAnim[playerid])
			{
				case 0: ApplyAnimation(playerid, "CRACK", "crckidle1", 4.1, 0, 1, 1, 1, 1, true);
				case 1: ApplyAnimation(playerid, "CRACK", "crckidle2", 4.1, 0, 1, 1, 1, 1, true);
				case 2: ApplyAnimation(playerid, "CRACK", "crckidle3", 4.1, 0, 1, 1, 1, 1, true);
				default: ApplyAnimation(playerid, "CRACK", "crckidle4", 4.1, 0, 1, 1, 1, 1, true);
			}
		}
	}
	return 1;
}
//-----< pTakeDamageHandler >---------------------------------------------------
public pTakeDamageHandler_Player(playerid, issuerid, Float:amount, weaponid)
{
	new Float:damage = amount,
		Float:health;
	GetPlayerHealth(playerid, health);

	if (weaponid == 14)
		damage = 0.0;
	else if (weaponid == 34)
		damage = health;
	else if (IsMeleeWeapon(weaponid))
		damage = (amount / 100) * GetPVarInt(issuerid, "pPower");

	if (health - damage < 1)
		KillerId[playerid] = issuerid;
	GivePlayerDamage(playerid, damage);
	return 1;
}
//-----<  >---------------------------------------------------------------------



//-----< Functions
//-----< CreatePlayerDataTable >------------------------------------------------
stock CreatePlayerDataTable()
{
	new str[3840];
	format(str, sizeof(str), "CREATE TABLE IF NOT EXISTS playerdata (");
	strcat(str, "ID int(5) NOT NULL auto_increment PRIMARY KEY,");
	strcat(str, "Name varchar(32) NOT NULL default ' ',");
	strcat(str, "Varname varchar(64) NOT NULL default ' ',");
	strcat(str, "Vartype int(1) NOT NULL default '0',");
	strcat(str, "Value varchar(512) NOT NULL default ' '");
	strcat(str, ") ENGINE = InnoDB CHARACTER SET euckr COLLATE euckr_korean_ci");
	mysql_query(str);
	
	format(str, sizeof(str), "CREATE TABLE IF NOT EXISTS bandata (");
	strcat(str, "ID int(5) NOT NULL auto_increment PRIMARY KEY");
	strcat(str, ",IP varchar(15) NOT NULL default '0.0.0.0'");
	strcat(str, ",Name varchar(32) NOT NULL  default ' '");
	strcat(str, ",Reason varchar(128) NOT NULL default ' '");
	strcat(str, ",Date varchar(16) NOT NULL default ' '");
	strcat(str, ",Type int(1) NOT NULL default '0'");
	strcat(str, ",Time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) ");
	strcat(str, "ENGINE = InnoDB CHARACTER SET euckr COLLATE euckr_korean_ci");
	mysql_query(str);
	return 1;
}
//-----< SavePlayerData >-------------------------------------------------------
stock SavePlayerData(playerid)
{
	new count = GetTickCount();
	new str[3840];
	if (IsPlayerNPC(playerid)) return 1;
	if (!GetPVarInt(playerid, "LoggedIn")) return 1;
	
	for (new i = 0; i < NumSaveDatas[playerid]; i++)
		if (strlen(PlayerData[playerid][i][pdVarname]) && PlayerData[playerid][i][pdSave])
		{
			new varname[64];
			strcpy(varname, PlayerData[playerid][i][pdVarname]);

			format(str, sizeof(str), "UPDATE playerdata SET");
			format(str, sizeof(str), "%s Vartype=%d", str, GetPVarType(playerid, varname));
			switch (GetPVarType(playerid, varname))
			{
				case PLAYER_VARTYPE_INT:	format(str, sizeof(str), "%s,Value=%d", str, GetPVarInt(playerid, varname));
				case PLAYER_VARTYPE_STRING: format(str, sizeof(str), "%s,Value='%s'", str, escape(GetPVarString(playerid, varname)));
				case PLAYER_VARTYPE_FLOAT:  format(str, sizeof(str), "%s,Value=%f", str, GetPVarFloat(playerid, varname));
			}
			format(str, sizeof(str), "%s WHERE Name='%s' And Varname='%s'", str, GetPlayerNameA(playerid), varname);
			mysql_query(str);
			PlayerData[playerid][i][pdSave] = false;
			printf("%s Saved", varname);
		}
	NumSaveDatas[playerid] = 0;
	printf("SavePlayerData(%s): %dms", GetPlayerNameA(playerid), GetTickCount() - count);
	return 1;
}
//-----< LoadPlayerData >-------------------------------------------------------
stock LoadPlayerData(playerid)
{
	new count = GetTickCount();
	new str[1024],
		receive[5][512],
		idx;
	if (IsPlayerNPC(playerid)) return 1;
	if (!GetPVarInt(playerid, "LoggedIn")) return 1;
	
	format(str, sizeof(str), "SELECT * FROM playerdata WHERE Name='%s'", GetPlayerNameA(playerid));
	mysql_query(str);
	mysql_store_result();
	for (new i = 0, t = mysql_num_rows(); i < t; i++)
	{
		mysql_fetch_row(str, "|");
		split(str, receive, '|');
		idx = 2;

		strcpy(PlayerData[playerid][i][pdVarname], receive[idx++]);
		PlayerData[playerid][i][pdVartype] = strval(receive[idx++]);
		switch (PlayerData[playerid][i][pdVartype])
		{
			case PLAYER_VARTYPE_INT:	SetPVarInt(playerid, PlayerData[playerid][i][pdVarname], strval(receive[idx++]));
			case PLAYER_VARTYPE_STRING: SetPVarString(playerid, PlayerData[playerid][i][pdVarname], receive[idx++]);
			case PLAYER_VARTYPE_FLOAT:  SetPVarFloat(playerid, PlayerData[playerid][i][pdVarname], floatstr(receive[idx++]));
		}
		PlayerData[playerid][i][pdSave] = false;
	}
	if (!GetPVarInt(playerid, "pRegDate"))
	{
		new year, month, day;
		getdate(year, month, day);
		format(str, sizeof(str), "%04d%02d%02d", year, month, day);
		SetPVarInt(playerid, "pRegDate", strval(str));
	}
	printf("LoadPlayerData(%s): %dms", GetPlayerNameA(playerid), GetTickCount() - count);
	return 1;
}
//-----< ShowPlayerLoginMovie >-------------------------------------------------
stock ShowPlayerLoginMovie(playerid)
{
	SetPlayerTime(playerid, 0, 0);
	SetPlayerPos(playerid, -2955.9641, 1280.6005, 0.0);
	SetPlayerCameraPos(playerid, -2955.9641, 1280.6005, 30.3001);
	SetPlayerCameraLookAt(playerid, -2862.5815, 1182.5625, 9.6069);
	return 1;
}
//-----< ShowPlayerLoginDialog >------------------------------------------------
stock ShowPlayerLoginDialog(playerid, bool:wrong)
{
	new str[512];
	format(str, sizeof(str), "\
	\n\
	"C_LIGHTBLUE"%s��, �ȳ��ϼ���!\n\
	"C_YELLOW"Nogov"C_WHITE"�� ���� ���� ȯ���մϴ�.\n\
	", GetPlayerNameA(playerid));
	if (GetPVarInt(playerid, "Registered"))
	{
		if (wrong)
			strcat(str, "\
			\n\
			��й�ȣ�� �ǹٸ��� �ʽ��ϴ�.\n\
			�ٽ� Ȯ���� �ּ���!\n\
			\n\
			");
		else
			strcat(str, "\
			\n\
			���ԵǾ� �ִ� �г����Դϴ�.\n\
			��й�ȣ�� �Է��Ͽ� �α����ϼ���.\n\
			\n\
			");
		ShowPlayerDialog(playerid, DialogId_Player(0), DIALOG_STYLE_PASSWORD, "Login", str, "�α���", chNullString);
	}
	else
	{
		if (wrong)
			strcat(str, "\
			\n\
			��й�ȣ�� 8�ڸ� �̻� �Է��ϼ���.\n\
			\n\
			");
		else
			strcat(str, "\
			\n\
			���ԵǾ� ���� ���� �г����Դϴ�.\n\
			��й�ȣ�� �Է��Ͽ� �����ϼ���.\n\
			\n\
			");
		ShowPlayerDialog(playerid, DialogId_Player(0), DIALOG_STYLE_PASSWORD, "Login", str, "����", chNullString);
	}
	for (new i = 0; i < sizeof(LoginTextDraw); i++)
		TextDrawShowForPlayer(playerid, LoginTextDraw[i]);
	return 1;
}
//-----< SpawnPlayer_ >---------------------------------------------------------
stock SpawnPlayer_(playerid)
{
	SetPlayerHealth(playerid, 100.0);
	SetSpawnInfo(playerid, 0, GetPVarInt(playerid, "pSkin"), -1422.2572, -289.8291, 14.1484, 270.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}
//-----< ShowPlayerPlunderStatus >----------------------------------------------
stock ShowPlayerPlunderStatus(playerid)
{
	new str[256];
	strcpy(str, "\
		����� �׾����ϴ�.\n\
		���������� �ʰ� ������ �����ϸ� ��� �������� �Ұ� �˴ϴ�.\
		");
	if (PlunderTime[playerid])
		format(str, sizeof(str), "%s\n\n"C_GREY"\
			%d�� �Ŀ� �������� �� �ֽ��ϴ�.\
			", str, PlunderTime[playerid]);
	else
		strcat(str, "\n\n"C_GREY"���� �������� �� �ֽ��ϴ�.");
	ShowPlayerDialog(playerid, DialogId_Player(5), DIALOG_STYLE_MSGBOX, "�˸�", str, "������", chNullString);
	return 1;
}
//-----< IsMeleeWeapon >--------------------------------------------------------
stock IsMeleeWeapon(weaponid)
{
	if (weaponid >= 0 && weaponid <= 15) return true;
	return false;
}
//-----< IdBan >----------------------------------------------------------------
stock IdBan(playerid, reason[])
{
	new string[256],
		year, month, day;
	getdate(year, month, day);
	format(str, sizeof(str), "INSERT INTO bandata (ID,IP,Name,Reason,Date,Type)");
	format(str, sizeof(str), "%s VALUES ('%s',' ','%s','%d�� %d�� %d��',1)", str, GetPlayerNameA(playerid), escape(reason), year, month, day);
	mysql_query(str);
	format(str, sizeof(str), "%d�� %d�� %d��", year, month, day);
	ShowPlayerBanDialog(playerid, GetPlayerNameA(playerid), reason, string, 1);
	Kick(playerid);
	return 1;
}
//-----< IpBan >----------------------------------------------------------------
stock IpBan(playerid, reason[])
{
	new string[256],
		year, month, day;
	getdate(year, month, day);
	format(str, sizeof(str), "INSERT INTO bandata (ID,IP,Name,Reason,Date,Type)");
	format(str, sizeof(str), "%s VALUES ('%s','%s','%s','%d�� %d�� %d��',2)", str, GetPlayerNameA(playerid), GetPlayerIpA(playerid), escape(reason), year, month, day);
	mysql_query(str);
	format(str, sizeof(str), "%d�� %d�� %d��", year, month, day);
	ShowPlayerBanDialog(playerid, GetPlayerNameA(playerid), reason, string, 2);
	Kick(playerid);
	return 1;
}
//-----< ShowPlayerBanDialog >--------------------------------------------------
stock ShowPlayerBanDialog(playerid, name[], reason[], date[], type)
{
	new str[512], typetext[64];
	if (type == 1) typetext = "ID";
	else if (type == 2) typetext = "IP";
	format(str, sizeof(str), "\
	������� "C_RED"%s"C_WHITE"�� ������ ���� ������ ���ܵǾ� �ֽ��ϴ�.\n\
	\n\
	"C_PASTEL_BLUE"�̸�: "C_WHITE"%s\n\
	"C_PASTEL_BLUE"����: "C_WHITE"%s\n\
	"C_PASTEL_BLUE"�Ͻ�: "C_WHITE"%s\n\
	\n\
	���� ������ ���ϽŴٸ� ���� ������ ������ �ֽʽÿ�.\n\
	Nogov - "C_ORANGE"http://cafe.daum.net/Nogov\
	", typetext, name, reason, date);
	ShowPlayerDialog(playerid, DialogId_Player(3), DIALOG_STYLE_MSGBOX, "�˸�", str, "Ȯ��", chNullString);
}
//-----< SetPlayerData >--------------------------------------------------------
stock SetPlayerData(playerid, varname[], vartype, int_value, Float:float_value, string_value[])
{
	if (varname[0] != 'p' || !GetPVarInt(playerid, "LoggedIn")) return 1;
	new breaks;
	switch (vartype)
	{
		case PLAYER_VARTYPE_INT:	breaks = (int_value == GetPVarInt(playerid, varname)) ? true : false;
		case PLAYER_VARTYPE_FLOAT:	breaks = (float_value == GetPVarFloat(playerid, varname)) ? true : false;
		case PLAYER_VARTYPE_STRING:	breaks = (!strcmp(string_value, GetPVarString(playerid, varname), true)) ? true : false;
	}
	if (breaks) return 1;
	new j = MAX_PLAYER_DATAS;
	for (new i = 0; i < MAX_PLAYER_DATAS; i++)
	{
		if (strlen(PlayerData[playerid][i][pdVarname])
		&& !strcmp(PlayerData[playerid][i][pdVarname], varname, true))
		{
			PlayerData[playerid][i][pdSave] = true;
			if (NumSaveDatas[playerid] < i)
				NumSaveDatas[playerid] = i+1;
			return 1;
		}
		else if (!strlen(PlayerData[playerid][i][pdVarname]) && j > i) j = i;
	}
	if (j == MAX_PLAYER_DATAS)
	{
		printf("%s���� �÷��̾� ������ ���� �ѵ�(%d)�� �ʰ��߽��ϴ�.", GetPlayerNameA(playerid), MAX_PLAYER_DATAS);
		return 1;
	}
	InsertPlayerData(playerid, varname, vartype, int_value, float_value, string_value);
	strcpy(PlayerData[playerid][j][pdVarname], varname);
	PlayerData[playerid][j][pdVartype] = vartype;
	PlayerData[playerid][j][pdSave] = false;
	return 1;
}
//-----< InsertPlayerData >-----------------------------------------------------
stock InsertPlayerData(playerid, varname[], vartype, int_value, Float:float_value, string_value[], encryption[]="")
{
	new str[1024], tmp[512];
	format(str, sizeof(str), "INSERT INTO playerdata (Name,Varname,Vartype,Value)");
	format(str, sizeof(str), "%s VALUES ('%s','%s',%d,", str, GetPlayerNameA(playerid), escape(varname), vartype);
	switch (vartype)
	{
		case PLAYER_VARTYPE_INT:	format(tmp, sizeof(tmp), "'%d')", int_value);
		case PLAYER_VARTYPE_FLOAT:  format(tmp, sizeof(tmp), "'%f')", float_value);
		case PLAYER_VARTYPE_STRING: format(tmp, sizeof(tmp), "'%s')", string_value);
	}
	if (strlen(encryption))
		format(str, sizeof(str), "%s%s(%s)", str, encryption, tmp);
	else
		format(str, sizeof(str), "%s%s", str, tmp);
	mysql_query(str);
	return 1;
}
//-----< DeletePlayerData >-----------------------------------------------------
stock DeletePlayerData(playerid, varname[])
{
	if (varname[0] != 'p' || !GetPVarInt(playerid, "LoggedIn")) return 1;
	new str[256];
	for (new i = 0; i < MAX_PLAYER_DATAS; i++)
		if (strlen(PlayerData[playerid][i][pdVarname])
		&& !strcmp(PlayerData[playerid][i][pdVarname], varname, true))
		{
			format(str, sizeof(str), "DELETE FROM playerdata WHERE Name='%s' And Varname='%s'", GetPlayerNameA(playerid), varname);
			mysql_query(str);
			strcpy(PlayerData[playerid][i][pdVarname], chNullString);
			PlayerData[playerid][i][pdVartype] = PLAYER_VARTYPE_NONE;
			PlayerData[playerid][i][pdSave] = false;
			break;
		}
	return 1;
}
//-----<  >---------------------------------------------------------------------