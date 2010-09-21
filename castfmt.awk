#!awk -f
# void(*foo)	(a, b, c)
function trim( s,               v )     {
        v = s
        sub( /^[ \t]*/, "", v )
        sub( /[ \t]*$/, "", v )
        return( v )
}
BEGIN	{
	# re = "[a-zA-Z_][a-zA-Z0-9_]*[ \t]*[(][^)]*[)][ \t]*[(].*[)];.*$"
	re = "[a-zA-Z_][a-zA-Z0-9_]*[ \t]*[(][^)]*[)][ \t]*[(][^)]*[)]"
}
{
	line = ""
	while( match( $0, re ) > 0 )	{
		# printf "clip=|%s|\n", substr( $0, RSTART, RLENGTH )
		left = line substr( $0, 1, RSTART - 1 )
		mid   = substr( $0, RSTART, RLENGTH )
		$0 = substr( $0, RSTART + RLENGTH )
		# DEBUG printf "%s|%s|%s\n", line, mid, $0
		#
		# Everything up to first lparen is the type
		match( mid, /[(]/ )
		type = trim( substr( mid, 1, RSTART - 1 ) )
		mid = substr( mid, RSTART )
		# Everything before second lparens is the name
		match( mid, /[(][^)]*[)][ \t]*/ )
		name = trim( substr( mid, RSTART, RLENGTH ) )
		args = substr( mid, RSTART + RLENGTH )
		Ltype = length( type )
                if( Ltype < n ) {
                        filler = n - Ltype
                        pad = sprintf( "%" filler "." filler "s", " " )
                }
		# Clean up stuff
		sub( /[(][ \t]*/, "(", name )
		sub( /[ \t]*[)][ \t]*/, ")", name )
		sub( /[(][ \t]*/, "(", args )
		sub( /[ \t]*[)][ \t]*/, ")", args )
		#
		cast = type pad name args
		#
		line = line left cast
	}
	print line $0
}
