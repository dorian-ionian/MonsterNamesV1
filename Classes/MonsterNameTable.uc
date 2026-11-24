//
// Configurable display names for monster classes, shown in TitanRPG and InvasionProMod messages and labels.
// The table is read from MonsterNamesV1.ini, section [MonsterNamesV1.MonsterNameTable].
// ClassName is either the bare monster class name, e.g. Imp_Red, or Package.Class, e.g. DoomPawns2k4.Skeleton.
// A Package.Class entry is used for that exact class; a bare entry matches any package with that class name.
//

class MonsterNameTable extends Object
	config(MonsterNamesV1);

struct MonsterNameStruct
{
	var string ClassName;
	var string DisplayName;
};
var config array<MonsterNameStruct> MonsterNames;

//Returns the configured display name for a monster class, or "" if the class has no entry.
//An entry with a package prefix (Package.Class) is matched first; otherwise the bare class name is matched.
static function string GetOverride(class<Object> C)
{
	local int i;
	local string FullName, BareName;

	if(C == None)
		return "";

	FullName = string(C);
	BareName = class'Object'.static.GetItemName(FullName);

	for(i = 0; i < default.MonsterNames.Length; i++)
	{
		if(default.MonsterNames[i].ClassName ~= FullName)
			return default.MonsterNames[i].DisplayName;
	}
	for(i = 0; i < default.MonsterNames.Length; i++)
	{
		if(default.MonsterNames[i].ClassName ~= BareName)
			return default.MonsterNames[i].DisplayName;
	}
	return "";
}

//Server: packs MonsterNames[Start..Start+Count-1] as "Class|Display|" pairs for ClientReceiveMonsterNames
static function string PackBatch(int Start, int Count)
{
	local int i, End;
	local string Packed;

	End = Start + Count;
	if(End > default.MonsterNames.Length)
		End = default.MonsterNames.Length;

	for(i = Start; i < End; i++)
		Packed = Packed $ default.MonsterNames[i].ClassName $ "|" $ default.MonsterNames[i].DisplayName $ "|";

	return Packed;
}

//Client: stores a batch sent by the server, so the client resolves names the same way the server does
static function SetBatch(int Start, string Packed)
{
	local int i, Pos;
	local string ClassName, DisplayName;

	i = Start;
	while(true)
	{
		Pos = InStr(Packed, "|");
		if(Pos < 0)
			break;
		ClassName = Left(Packed, Pos);
		Packed = Mid(Packed, Pos + 1);

		Pos = InStr(Packed, "|");
		if(Pos < 0)
			break;
		DisplayName = Left(Packed, Pos);
		Packed = Mid(Packed, Pos + 1);

		if(default.MonsterNames.Length <= i)
			default.MonsterNames.Length = i + 1;
		default.MonsterNames[i].ClassName = ClassName;
		default.MonsterNames[i].DisplayName = DisplayName;
		i++;
	}
}

//Configured name if there is one, otherwise the plain class name
static function string GetDisplayName(class<Object> C)
{
	local string Name;

	Name = GetOverride(C);
	if(Name != "")
		return Name;
	if(C == None)
		return "";
	return string(C.Name);
}
