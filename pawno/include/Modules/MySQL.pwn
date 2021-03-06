/*
 *
 *
 *			Nogov MySQL Module
 *		  	2013/01/08
 *
 *
 *		Copyright (c) sBum. All rights reserved.
 *
 *
 */
/*

  < Callbacks >
	gInitHandler
	OnMysqlError(error[], errorid, MySQL:handle)

  < Functions >

*/



//-----< Defines
#define SQL_IP		  "pureunba.cafe24.com"
#define SQL_ID		  "pureunba"
#define SQL_PW		  "nogov2013"
#define SQL_DB		  "pureunba"



//-----< Variables
new MySQL:MySQL_Handle;



//-----< Callbacks
forward gInitHandler_MySQL();
//-----< gInitHandler >---------------------------------------------------------
public gInitHandler_MySQL()
{
	printf("DB 서버에 접속중입니다.");
	MySQL_Handle = mysql_init(LOG_OFF, true);
	if(mysql_connect(SQL_IP, SQL_ID, SQL_PW, SQL_DB, MySQL_Handle))
	{
		printf("DB 서버에 접속했습니다.");
		mysql_query("SET NAMES 'euckr'");
	}
	else
	{
		printf("DB 서버에 접속할 수 없습니다.");
		printf("서버를 종료합니다.");
		Wait(3000);
		Crash();
	}
	return 1;
}
public OnMysqlError(error[], errorid, MySQL:handle)
{
	if(errorid == 2006)
	{
		printf("MySQL에 문제가 생겼습니다.");
		printf("서버를 재부팅합니다.");
		SendRconCommand("gmx");
	}
	return 1;
}
//-----<  >---------------------------------------------------------------------



//-----< Functions
//-----<  >---------------------------------------------------------------------
