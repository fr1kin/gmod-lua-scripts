// credit to s0beit

#ifdef _WIN32
#pragma once
#endif

class IScriptEnforcer
{
public:
	virtual void				Unknown001();					//0000
	virtual void				Unknown002();					//0004
	virtual void				Unknown003();					//0008
	virtual void				Unknown004();					//000C
	virtual void				Unknown005();					//0010
	virtual void				Unknown006();					//0014
	virtual void				Unknown007();					//0018
	virtual void				Unknown008();					//001C
	virtual void				Unknown009();					//0020
	virtual void				Unknown010();					//0024
	virtual void				Unknown011();					//0028
	virtual void				Unknown012();					//002C
	virtual void				Unknown013();					//0030
	virtual void				Unknown014();					//0034
	virtual void				Unknown015();					//0038
	virtual void				Unknown016();					//003C
	virtual void				Unknown017();					//0040
	virtual bool				IsActive( void );				//0044
	virtual bool				ScriptAllowed(
									char* strScript,
									unsigned char* data,
									int size,
									unsigned char* u1 );		//0048
};

struct ScriptEnforcer_VTable
{
	void ( __stdcall* Unknown001 )();							//0000
	void ( __stdcall* Unknown002 )();							//0004
	void ( __stdcall* Unknown003 )();							//0008
	void ( __stdcall* Unknown004 )();							//000C
	void ( __stdcall* Unknown005 )();							//0010
	void ( __stdcall* Unknown006 )();							//0014
	void ( __stdcall* Unknown007 )();							//0018
	void ( __stdcall* Unknown008 )();							//001C
	void ( __stdcall* Unknown009 )();							//0020
	void ( __stdcall* Unknown010 )();							//0024
	void ( __stdcall* Unknown011 )();							//0028
	void ( __stdcall* Unknown012 )();							//002C
	void ( __stdcall* Unknown013 )();							//0030
	void ( __stdcall* Unknown014 )();							//0034
	void ( __stdcall* Unknown015 )();							//0038
	void ( __stdcall* Unknown016 )();							//003C
	void ( __stdcall* Unknown017 )();							//0040
	bool ( __stdcall* IsActive )();								//0044
	bool ( __stdcall* ScriptAllowed )(char* strScript, unsigned char* data, int size, unsigned char* u1); //004C
};