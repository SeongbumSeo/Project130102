/*
 *
 *
 *		PureunBa(서성범)
 *
 *			Player Core
 *
 *
 *		Coded by PureunBa 2011-2013 @ all right reserved.
 *
 *			< pureunba.tistory.com >
 *
 *
 *		Release:	2013/01/02
 *		Update:		2013/02/21
 *
 *
 */
/*

  < Callbacks >
	gInitHandler_Player(playerid)
	pConnectHandler_Player(playerid)
	pDisconnectHandler_Player(playerid)
	pRequestClassHandler_Player(playerid, classid)
	pRequestSpawnHandler_Player(playerid)
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
	ShowPlayerLoginDialog(playerid, bool:wrong)
	SpawnPlayer_(playerid)
	ShowPlayerPlunderStatus(playerid)
	IsMeleeWeapon(weaponid)

*/



//-----< Includes



//-----< Variables
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
	KillerId[MAX_PLAYERS];



//-----< Defines
#define DialogId_Player(%0)			(25+%0)
#define INTRO_MUSIC					"cfile9.uf.tistory.com/original/135DD247510CA50F37CEE8"



//-----< Callbacks
forward gInitHandler_Player();
forward pConnectHandler_Player(playerid);
forward pDisconnectHandler_Player(playerid);
forward pRequestClassHandler_Player(playerid, classid);
forward pRequestSpawnHandler_Player(playerid);
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

	new str[512], receive[3][128];
	for (new i; i < 20; i++)
		SendClientMessage(playerid, COLOR_WHITE, chEmpty);
	if (!GetPVarInt_(playerid, "LoggedIn"))
	{
		format(str, sizeof(str), "SELECT Password From playerdata WHERE Name='%s'", GetPlayerNameA(playerid));
		mysql_query(str);
		mysql_store_result();
		if (mysql_num_rows() > 0)
		{
			SetPVarInt_(playerid, "Registered", true);
		}
		mysql_free_result();
	}
	
	format(str, sizeof(str), "SELECT * FROM bandata WHERE IP='%s'", GetPlayerIpA(playerid));
	mysql_query(str);
	mysql_store_result();
	if (mysql_num_rows() > 0)
	{
		mysql_fetch_field("Name", receive[0]);
		mysql_fetch_field("Reason", receive[1]);
		mysql_fetch_field("Date", receive[2]);
		mysql_free_result();
		format(str, sizeof(str), "\
		사용중인 IP는 다음과 같은 이유로 차단되어 있습니다.\n\
		\n\
		"C_PASTEL_BLUE"이름: "C_WHITE"%s\n\
		"C_PASTEL_BLUE"이유: "C_WHITE"%s\n\
		"C_PASTEL_BLUE"일시: "C_WHITE"%s\n\
		\n\
		차단 해제를 원하신다면 저희 포럼에 문의해 주십시오.\n\
		Nogov - "C_ORANGE"http://cafe.daum.net/Nogov\
		", receive[0], receive[1], receive[2]);
		ShowPlayerDialog(playerid, DialogId_Player(3), DIALOG_STYLE_MSGBOX, "알림", str, "확인", chNullString);
	}
	mysql_free_result();
	
	return 1;
}
//-----< pDisconnectHandler >---------------------------------------------------
public pDisconnectHandler_Player(playerid)
{
	for (new i = 0, t = GetMaxPlayers(); i < t; i++)
		if (PlunderId[i] == playerid)
		{
			PlunderId[i] = INVALID_PLAYER_ID;
			for (new j = 0, u = GetMaxPlayerItems(); j < u; j++)
				if (IsValidPlayerItemID(playerid, j))
					DestroyPlayerItem(playerid, j);
			ShowPlayerDialog(i, 0, DIALOG_STYLE_MSGBOX, "알림", "사자가 게임을 종료했습니다.\n사자는 모든 아이템을 잃게 됩니다.", "확인", chNullString);
		}
	return 1;
}
//-----< pRequestClassHandler >-------------------------------------------------
public pRequestClassHandler_Player(playerid, classid)
{
	if (!GetPVarInt_(playerid, "LoggedIn"))
	{
		PlayAudioStreamForPlayer(playerid, "http://"INTRO_MUSIC);
		SetPlayerTime(playerid, 0, 0);
		SetPlayerPos(playerid, -2955.9641, 1280.6005, 0.0);
		SetPlayerCameraPos(playerid, -2955.9641, 1280.6005, 30.3001);
		SetPlayerCameraLookAt(playerid, -2862.5815, 1182.5625, 9.6069);
		ShowPlayerLoginDialog(playerid, false);
	}
	return 1;
}
//-----< pRequestSpawnHandler >-------------------------------------------------
public pRequestSpawnHandler_Player(playerid)
{
	if (!GetPVarInt_(playerid, "LoggedIn"))
		ShowPlayerLoginDialog(playerid, false);
	else
		return 1;
	return 0;
}
//-----< pUpdateHandler >-------------------------------------------------------
public pUpdateHandler_Player(playerid)
{
	Streamer_Update(playerid);

	new Float:x, Float:y, Float:z,
		keys, ud, lr;
	if (IsPlayerInAnyVehicle(playerid) || !GetPVarInt_(playerid, "LoggedIn")) return 1;
	
	GetPlayerVelocity(playerid, x, y, z);
	GetPlayerKeys(playerid, keys, ud, lr);
	new Float:bag = (float(GetPlayerItemsWeight(playerid, "가방")) / float(GetPVarInt_(playerid, "pWeight"))) * 100,
		Float:hand = (float(GetPlayerItemsWeight(playerid, "손")) / float(GetPVarInt_(playerid, "pPower"))) * 100;
	
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
	SetPVarInt_(playerid, "Spawned", false);
	killerid = KillerId[playerid];
	KillerId[playerid] = INVALID_PLAYER_ID;
	if (!GetPVarInt_(playerid, "LoggedIn")) return 0;
	
	PlunderTime[playerid] = 60;
	Dead[playerid] = true;
	GetPlayerPos(playerid, DeadPos[playerid][0], DeadPos[playerid][1], DeadPos[playerid][2]);
	GetPlayerFacingAngle(playerid, DeadPos[playerid][3]);
	DeadInterior[playerid] = GetPlayerInterior(playerid);
	DeadVirtualWorld[playerid] = GetPlayerVirtualWorld(playerid);
	if (IsPlayerConnected(killerid))
	{
		PlunderId[killerid] = playerid;
		SendClientMessage(killerid, COLOR_WHITE, "시체 주변에서 "C_YELLOW"F키"C_WHITE"를 눌러 아이템을 탈취할 수 있습니다.");
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
			if (IsPlayerConnected(i) && GetPVarInt_(i, "LoggedIn") && Dead[i])
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
	SetPVarInt_(playerid, "Spawned", true);
	StopAudioStreamForPlayer(playerid);
	
	if (!GetPVarInt_(playerid, "FirstSpawn"))
	{
		SetPVarInt_(playerid, "FirstSpawn", true);
		SetPlayerSkin(playerid, GetPVarInt_(playerid, "pSkin"));
		SetPlayerTeam(playerid, 0);
		SetPlayerHealth(playerid, GetPVarFloat_(playerid, "pHealth"));
		SetPlayerArmour(playerid, GetPVarFloat_(playerid, "pArmour"));
	}
	
	if (GetPVarInt_(playerid, "RestoreSpawn"))
	{
		new receive[6][16];
		split(GetPVarString_(playerid, "pLastPos"), receive, ',');
		SetPlayerPos(playerid, floatstr(receive[0]), floatstr(receive[1]), floatstr(receive[2]));
		SetPlayerFacingAngle(playerid, floatstr(receive[3]));
		SetPlayerInterior(playerid, strval(receive[4]));
		SetPlayerVirtualWorld(playerid, strval(receive[5]));
		SetPVarInt_(playerid, "RestoreSpawn", false);
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
	
	if (!GetPVarInt_(playerid, "LoggedIn")) return 0;
	else if (!strcmp(cmd, "/비번변경", true) || !strcmp(cmd, "/암호변경", true))
	{
		format(str, sizeof(str), "\
		\n\
		새 비밀번호를 입력하세요.\n\
		\n\
		");
		ShowPlayerDialog(playerid, DialogId_Player(1), DIALOG_STYLE_PASSWORD, "비밀번호 변경", str, "확인", "취소");
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
			if (!GetPVarInt_(playerid, "Registered"))
			{
				if (strlen(inputtext) >= 8)
				{
					new year, month, day;
					getdate(year, month, day);
					format(str, sizeof(str), "%04d%02d%02d", year, month, day);
					SetPVarInt_(playerid, "pRegDate", strval(str));
					format(str, sizeof(str), "INSERT INTO playerdata (Name,Password,IP) VALUES ('%s',SHA1('%s'),'%s')", GetPlayerNameA(playerid), inputtext, GetPlayerIpA(playerid));
					mysql_query(str);
					SetPVarInt_(playerid, "Registered", true);
					ShowPlayerLoginDialog(playerid, false);
				}
				else
					ShowPlayerLoginDialog(playerid, true);
			}
			else if (!GetPVarInt_(playerid, "LoggedIn"))
			{
				format(str, sizeof(str), "SELECT ID FROM playerdata WHERE Name='%s' AND Password=SHA1('%s')", GetPlayerNameA(playerid), inputtext);
				mysql_query(str);
				mysql_store_result();
				if (mysql_num_rows() == 1)
				{
					SetPVarInt_(playerid, "LoggedIn", true);
					LoadPlayerData(playerid);
					if (strlen(GetPVarString_(playerid, "pLastPos")) > 10)
						ShowPlayerDialog(playerid, DialogId_Player(2), DIALOG_STYLE_LIST, "로그인", "리스폰\n위치 복구", "선택", chNullString);
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
					format(str, sizeof(str), "UPDATE playerdata SET Password=SHA1('%s') WHERE Name='%s'", inputtext, GetPlayerNameA(playerid));
					mysql_query(str);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, "비밀번호가 성공적으로 변경되었습니다.");
				}
				else
				{
					format(str, sizeof(str), "\
					\n\
					새 비밀번호를 입력하세요.\n\
					비밀번호는 반드시 8자리 이상이어야 합니다.\n\
					\n\
					");
					ShowPlayerDialog(playerid, DialogId_Player(1), DIALOG_STYLE_PASSWORD, "비밀번호 변경", str, "확인", "취소");
				}
		case 2:
		{
			if (listitem == 1)
				SetPVarInt_(playerid, "RestoreSpawn", true);
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
				GivePlayerItemToPlayer(plunderid, playerid, itemid, "가방");
				SendClientMessage(playerid, COLOR_WHITE, "아이템을 탈취했습니다.");
			}
			PlunderId[playerid] = INVALID_PLAYER_ID;
		}
		case 5:
		{
			if (PlunderTime[playerid] && !GetPVarInt_(playerid, "pAdmin") || !GetPVarInt_(playerid, "Spawned"))
				return ShowPlayerPlunderStatus(playerid);
			Dead[playerid] = false;
			PlunderTime[playerid] = 0;
			SpawnPlayer_(playerid);
			ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "알림", "리스폰되었습니다.", "확인", chNullString);
			for (new i = 0, t = GetMaxPlayers(); i < t; i++)
				if (PlunderId[i] == playerid)
				{
					PlunderId[i] = INVALID_PLAYER_ID;
					ShowPlayerDialog(i, 0, DIALOG_STYLE_MSGBOX, "알림", "사자가 리스폰되었습니다.", "확인", chNullString);
				}
		}
	}
	return 1;
}
//-----< pTimerTickHandler >----------------------------------------------------
public pTimerTickHandler_Player(nsec, playerid)
{
	if (!IsPlayerConnected(playerid) || !GetPVarInt_(playerid, "LoggedIn")) return 1;

	if (nsec == 1000)
	{
		new Float:pos[4],
			interior = GetPlayerInterior(playerid),
			virtualworld = GetPlayerVirtualWorld(playerid),
			Float:health, Float:armour,
			str[64];

		if (GetPVarInt_(playerid, "Spawned"))
		{
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			GetPlayerFacingAngle(playerid, pos[3]);
			format(str, sizeof(str), "%.4f,%.4f,%.4f,%.4f,%d,%d", pos[0], pos[1], pos[2], pos[3], interior, virtualworld);
			SetPVarString_(playerid, "pLastPos", str);
			GetPlayerHealth(playerid, health);
			SetPVarFloat_(playerid, "pHealth", health);
			GetPlayerArmour(playerid, armour);
			SetPVarFloat_(playerid, "pArmour", armour);
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
		
		SavePlayerData(playerid);
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
		damage = (amount / 100) * GetPVarInt_(issuerid, "pPower");
	
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
	strcat(str, "ID int(5) NOT NULL auto_increment PRIMARY KEY");
	strcat(str, ",Name varchar(32) NOT NULL default ' '");
	strcat(str, ",Password varchar(128) NOT NULL  default ' '");
	strcat(str, ",IP varchar(15) NOT NULL default '0.0.0.0'");
	strcat(str, ",RegDate int(8) NOT NULL default '0'");
	strcat(str, ",Level int(5) NOT NULL default '0'");
	strcat(str, ",Radio int(5) NOT NULL default '0'");
	strcat(str, ",Origin varchar(64) NOT NULL  default ' '");
	strcat(str, ",Money int(10) NOT NULL default '0'");
	strcat(str, ",Skin int(3) NOT NULL default '29'");
	strcat(str, ",Deaths int(5) NOT NULL default '0'");
	strcat(str, ",LastQuit int(1) NOT NULL default '0'");
	strcat(str, ",LastPos varchar(64) NOT NULL  default ' '");
	strcat(str, ",Tutorial int(1) NOT NULL default '0'");
	strcat(str, ",Admin int(5) NOT NULL default '0'");
	strcat(str, ",Warns int(5) NOT NULL default '0'");
	strcat(str, ",Praises int(5) NOT NULL default '0'");
	strcat(str, ",Toy1 varchar(256) NOT NULL  default ' '");
	strcat(str, ",Toy2 varchar(256) NOT NULL  default ' '");
	strcat(str, ",Toy3 varchar(256) NOT NULL  default ' '");
	strcat(str, ",Toy4 varchar(256) NOT NULL  default ' '");
	strcat(str, ",Toy5 varchar(256) NOT NULL  default ' '");
	strcat(str, ",Banned varchar(256) NOT NULL default ' '");
	strcat(str, ",Weight int(3) NOT NULL default '50'");
	strcat(str, ",Power int(3) NOT NULL default '50'");
	strcat(str, ",Health float(16,4) NOT NULL default '100.0'");
	strcat(str, ",Armour float(16,4) NOT NULL default '0.0'");
	strcat(str, ") ENGINE = InnoDB CHARACTER SET euckr COLLATE euckr_korean_ci");
	mysql_query(str);
	
	format(str, sizeof(str), "CREATE TABLE IF NOT EXISTS bandata (");
	strcat(str, "ID int(5) NOT NULL auto_increment PRIMARY KEY");
	strcat(str, ",IP varchar(15) NOT NULL default '0.0.0.0'");
	strcat(str, ",Name varchar(32) NOT NULL  default ' '");
	strcat(str, ",Reason varchar(128) NOT NULL default ' '");
	strcat(str, ",Date int(8) NOT NULL default '0'");
	strcat(str, ",Time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) ");
	strcat(str, "ENGINE = InnoDB CHARACTER SET euckr COLLATE euckr_korean_ci");
	mysql_query(str);
	return 1;
}
//-----< SavePlayerData >-------------------------------------------------------
stock SavePlayerData(playerid)
{
	new str[3840];
	if (IsPlayerNPC(playerid)) return 1;
	if (!GetPVarInt_(playerid, "LoggedIn")) return 1;

	format(str, sizeof(str), "UPDATE playerdata SET");
	format(str, sizeof(str), "%s IP='%s'", str, GetPlayerIpA(playerid));
	format(str, sizeof(str), "%s,RegDate=%d", str, GetPVarInt_(playerid, "pRegDate"));
	format(str, sizeof(str), "%s,Level=%d", str, GetPVarInt_(playerid, "pLevel"));
	format(str, sizeof(str), "%s,Radio=%d", str, GetPVarInt_(playerid, "pRadio"));
	format(str, sizeof(str), "%s,Origin='%s'", str, escape(GetPVarString_(playerid, "pOrigin")));
	format(str, sizeof(str), "%s,Money=%d", str, GetPVarInt_(playerid, "pMoney"));
	format(str, sizeof(str), "%s,Skin=%d", str, GetPVarInt_(playerid, "pSkin"));
	format(str, sizeof(str), "%s,Deaths=%d", str, GetPVarInt_(playerid, "pDeaths"));
	format(str, sizeof(str), "%s,LastQuit=%d", str, GetPVarInt_(playerid, "pLastQuit"));
	format(str, sizeof(str), "%s,LastPos='%s'", str, GetPVarString_(playerid, "pLastPos"));
	format(str, sizeof(str), "%s,Tutorial=%d", str, GetPVarInt_(playerid, "pTutorial"));
	format(str, sizeof(str), "%s,Admin=%d", str, GetPVarInt_(playerid, "pAdmin"));
	format(str, sizeof(str), "%s,Warns=%d", str, GetPVarInt_(playerid, "pWarns"));
	format(str, sizeof(str), "%s,Praises=%d", str, GetPVarInt_(playerid, "pPraises"));
	format(str, sizeof(str), "%s,Toy1='%s'", str, GetPVarString_(playerid, "pToy1"));
	format(str, sizeof(str), "%s,Toy2='%s'", str, GetPVarString_(playerid, "pToy2"));
	format(str, sizeof(str), "%s,Toy3='%s'", str, GetPVarString_(playerid, "pToy3"));
	format(str, sizeof(str), "%s,Toy4='%s'", str, GetPVarString_(playerid, "pToy4"));
	format(str, sizeof(str), "%s,Toy5='%s'", str, GetPVarString_(playerid, "pToy5"));
	format(str, sizeof(str), "%s,Banned='%s'", str, GetPVarString_(playerid, "pBanned"));
	format(str, sizeof(str), "%s,Weight=%d", str, GetPVarInt_(playerid, "pWeight"));
	format(str, sizeof(str), "%s,Power=%d", str, GetPVarInt_(playerid, "pPower"));
	format(str, sizeof(str), "%s,Health=%.4f", str, GetPVarFloat_(playerid, "pHealth"));
	format(str, sizeof(str), "%s,Armour=%.4f", str, GetPVarFloat_(playerid, "pArmour"));
	format(str, sizeof(str), "%s WHERE Name='%s'", str, GetPlayerNameA(playerid));
	mysql_query(str);
	return 1;
}
//-----< LoadPlayerData >-------------------------------------------------------
stock LoadPlayerData(playerid)
{
	new str[256],
		receive[512];
	if (IsPlayerNPC(playerid)) return 1;
	if (!GetPVarInt_(playerid, "LoggedIn")) return 1;
	
	format(str, sizeof(str), "SELECT * FROM playerdata WHERE Name='%s'", GetPlayerNameA(playerid));
	mysql_query(str);
	mysql_store_result();
	
	mysql_fetch_field("RegDate",	receive); SetPVarInt_(playerid, "pRegDate", strval(receive));
	mysql_fetch_field("Level",		receive); SetPVarInt_(playerid, "pLevel", strval(receive));
	mysql_fetch_field("Radio",		receive); SetPVarInt_(playerid, "pRadio", strval(receive));
	mysql_fetch_field("Origin",		receive); SetPVarString_(playerid, "pOrigin", receive);
	mysql_fetch_field("Money",		receive); SetPVarInt_(playerid, "pMoney", strval(receive));
	mysql_fetch_field("Skin",		receive); SetPVarInt_(playerid, "pSkin", strval(receive));
	mysql_fetch_field("Deaths",		receive); SetPVarInt_(playerid, "pDeaths", strval(receive));
	mysql_fetch_field("LastQuit",	receive); SetPVarInt_(playerid, "pLastQuit", strval(receive));
	mysql_fetch_field("LastPos",	receive); SetPVarString_(playerid, "pLastPos", receive);
	mysql_fetch_field("Tutorial",	receive); SetPVarInt_(playerid, "pTutorial", strval(receive));
	mysql_fetch_field("Admin",		receive); SetPVarInt_(playerid, "pAdmin", strval(receive));
	mysql_fetch_field("Warns",		receive); SetPVarInt_(playerid, "pWarns", strval(receive));
	mysql_fetch_field("Praises",	receive); SetPVarInt_(playerid, "pPraises", strval(receive));
	mysql_fetch_field("Toy1",		receive); SetPVarString_(playerid, "pToy1", receive);
	mysql_fetch_field("Toy2",		receive); SetPVarString_(playerid, "pToy2", receive);
	mysql_fetch_field("Toy3",		receive); SetPVarString_(playerid, "pToy3", receive);
	mysql_fetch_field("Toy4",		receive); SetPVarString_(playerid, "pToy4", receive);
	mysql_fetch_field("Toy5",		receive); SetPVarString_(playerid, "pToy5", receive);
	mysql_fetch_field("Banned",		receive); SetPVarString_(playerid, "pBanned", receive);
	mysql_fetch_field("Weight",		receive); SetPVarInt_(playerid, "pWeight", strval(receive));
	mysql_fetch_field("Power",		receive); SetPVarInt_(playerid, "pPower", strval(receive));
	mysql_fetch_field("Health",		receive); SetPVarFloat_(playerid, "pHealth", floatstr(receive));
	mysql_fetch_field("Armour",		receive); SetPVarFloat_(playerid, "pArmour", floatstr(receive));
	
	mysql_free_result();
	
	if (!GetPVarInt_(playerid, "pRegDate"))
	{
		new year, month, day;
		getdate(year, month, day);
		format(str, sizeof(str), "%04d%02d%02d", year, month, day);
		SetPVarInt_(playerid, "pRegDate", strval(str));
	}
	return 1;
}
//-----< ShowPlayerLoginDialog >------------------------------------------------
stock ShowPlayerLoginDialog(playerid, bool:wrong)
{
	new str[512];
	format(str, sizeof(str), "\
	\n\
	"C_LIGHTBLUE"%s님, 안녕하세요!\n\
	"C_YELLOW"Nogov"C_WHITE"에 오신 것을 환영합니다.\n\
	", GetPlayerNameA(playerid));
	if (GetPVarInt_(playerid, "Registered"))
	{
		if (wrong)
			strcat(str, "\
			\n\
			비밀번호가 옳바르지 않습니다.\n\
			다시 확인해 주세요!\n\
			\n\
			");
		else
			strcat(str, "\
			\n\
			가입되어 있는 닉네임입니다.\n\
			비밀번호를 입력하여 로그인하세요.\n\
			\n\
			");
		ShowPlayerDialog(playerid, DialogId_Player(0), DIALOG_STYLE_PASSWORD, "Login", str, "로그인", chNullString);
	}
	else
	{
		if (wrong)
			strcat(str, "\
			\n\
			비밀번호를 8자리 이상 입력하세요.\n\
			\n\
			");
		else
			strcat(str, "\
			\n\
			가입되어 있지 않은 닉네임입니다.\n\
			비밀번호를 입력하여 가입하세요.\n\
			\n\
			");
		ShowPlayerDialog(playerid, DialogId_Player(0), DIALOG_STYLE_PASSWORD, "Login", str, "가입", chNullString);
	}
	return 1;
}
//-----< SpawnPlayer_ >---------------------------------------------------------
stock SpawnPlayer_(playerid)
{
	SetPlayerHealth(playerid, 100.0);
	SetSpawnInfo(playerid, 0, GetPVarInt_(playerid, "pSkin"), -1422.2572, -289.8291, 14.1484, 270.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}
//-----< ShowPlayerPlunderStatus >----------------------------------------------
stock ShowPlayerPlunderStatus(playerid)
{
	new str[256];
	strcpy(str, "\
		당신은 죽었습니다.\n\
		리스폰하지 않고 접속을 종료하면 모든 아이템을 잃게 됩니다.\
		");
	if (PlunderTime[playerid])
		format(str, sizeof(str), "%s\n\n"C_GREY"\
			%d초 후에 리스폰할 수 있습니다.\
			", str, PlunderTime[playerid]);
	else
		strcat(str, "\n\n"C_GREY"지금 리스폰할 수 있습니다.");
	ShowPlayerDialog(playerid, DialogId_Player(5), DIALOG_STYLE_MSGBOX, "알림", str, "리스폰", chNullString);
	return 1;
}
//-----< IsMeleeWeapon >--------------------------------------------------------
stock IsMeleeWeapon(weaponid)
{
	if (weaponid >= 0 && weaponid <= 15) return true;
	return false;
}
//-----<  >---------------------------------------------------------------------
