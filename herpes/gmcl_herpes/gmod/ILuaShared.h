// credit to LauCorp

#ifndef _LUASHARED_FILE_
#define _LUASHARED_FILE_

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

	/*
class ILuaShared
{
public:
	virtual void			blah();
	virtual void			InitializeCommonInterfaces();
	virtual void			unknown01();
	virtual void			unknown02();
	virtual void			ParseContentTxt();
	virtual ScriptData*		LuaGetFile(const char *file);
	virtual void			LoadLua2();
	virtual void			PrintLuaStats();
	virtual void			unknown03();
	virtual void			unknown04();
	virtual void			MountGameContent();
	virtual void			LoadAddonInfo();
	virtual void			LoadGamemodes();
	virtual void			LoadAddonLua();
	virtual void			unknown05();
	virtual void			unknown06();
	virtual AddonVector*	GetLuaAddons();
	virtual void			unknown08();
	virtual void			unknown09();
	virtual void			unknown10();
	virtual void			unknown11();
	virtual void			unknown12();
	virtual void			unknown13();
	virtual void			unknown14();
	virtual void			unknown15();
};
*/

class ILuaShared
{
public:
    virtual void            blah();
    virtual void            Init(void * (*)(char  const*,int *),bool,void *);
    virtual void            LoadCache(void);
    virtual void            SaveCache(void);
    virtual void            Shutdown(void);
    virtual void            DumpStats(void);
    virtual void            CreateLuaInterface(ILuaCallback *,char);
    virtual void            CloseLuaInterface(ILuaInterface *);
    virtual ILuaInterface*    GetLuaInterface(char);
    virtual void            GetFile(char  const*,char  const*,bool,bool,bool *);
    virtual void            FileExists(char  const*,char  const*,bool,bool,bool *);
    virtual void            SetTranslateHook(ILuaCallback*);
    virtual void            MountContent(void);
    virtual void            MountAddons(void);
    virtual void            MountGamemodes(void);
    virtual void            MountLua(char  const*,bool);
    virtual void            MountLuaAdd(char  const*,char  const*);
    virtual void            UnMountLua(char  const*);
    virtual void            GetAddonList(void);
    virtual void            GetGamemodeList(void);
    virtual void            GetContentList(void);
    virtual void            GetCommaSeperatedContentList(void);
    virtual void            LZMACompress(char *,int);
    virtual void            GetInterfaceByState(lua_State *);
    virtual void            SetDepotMountable(char  const*,bool);
};

#endif