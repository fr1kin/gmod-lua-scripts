require( 'downloadfilter' );

local allowed = {
	"bsp",
	"dua",
	"txt",
}

hook.Add("ShouldDownload", "DownloadFilter", function( strName )
	local ext = string.GetExtensionFromFilename( strName )
	
	if( !table.HasValue( allowed, ext ) ) then
		return false;
	end
end )