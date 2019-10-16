// credit to LauCorp

#ifdef _WIN32
#pragma once
#endif

#define GMODLUASHAREDINTERFACE "LuaShared001"

struct ScriptData
{
	char path[MAX_PATH];
	int crc;
	char* contents;
	int timestamp;
	bool somebool;
};

#ifndef NO_SDK
	typedef CUtlVector<char[64]> AddonVector; // this may be a struct, but this can be solved with amazing C++ typedefs
#else
	typedef void* AddonVector;
#endif

class ILuaShared
{
public:
	virtual void			deconstructor();									//0000
	virtual void			Init();												//0004
	virtual void			LoadCache();										//0008
	virtual void			SaveCache();										//000C
	virtual int				Shutdown();											//0010
	virtual int				DumpStats();										//0014
	virtual void			Unknown001();										//0018
	virtual void			Unknown002();										//001C
	virtual void*			GetLuaInterface( unsigned char v );					//0020
	virtual ScriptData*		GetFile(char  const*,char  const*,bool,bool,bool *);//0024
	virtual bool			FileExists(char  const*,char  const*,bool,bool,bool *); //0028
	virtual void*			SetTranslateHook(void*);							//002C
	virtual void*			MountContent(void);									//0030
	virtual void*			MountAddons(void);									//0034
	virtual void*			MountGamemodes(void);								//0038
	virtual void*			MountLua(void);										//003C
	virtual void			Unknown004();										//0040
	virtual int				UnMountLua( char const* Lua );						//0044
	virtual void*			GetAddonList();										//0048
	virtual void*			GetGamemodeList();									//004C
	virtual void*			GetContentList();									//0050
	virtual void			Unknown005();										//0054
	virtual void			Unknown006();										//0058
	virtual void*			GetInterfaceByState( lua_State* );					//005C
	virtual int				SetDepotMountable(char  const*,bool);				//0060
};

//.text:10003900 ; CLuaShared::GetLuaInterface(unsigned char)