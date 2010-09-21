#!/CYGNUS/B19/H-I386~1/BIN/awk -f
function trimLeft( s,		v )	{
	v = s
	sub( /^[ \t]*/, "", v )
	return( v )
}
function trimRight( s, 		v )	{
	v = s
	sub( /[ \t]*$/, "", v )
	return( v )
}
function trim( s )	{
	return( trimLeft( trimRight( s ) ) )
}
function before( name, l, m, r )	{
	printf "%s[before] --> [%s|%s|%s]\n", name, l, m, r
}
function after( name, l, m, r )	{
	printf "%s[after] --> [%s|%s|%s]\n", name, l, m, r
}
{	sub( /[\r]/, "" )	}	# Drop \r DOS crap
{
	# Force HEX constants into uppercase, even in preprocessor
	while( match( $0, /0[Xx][0-9A-F]*[a-f][0-9a-fA-F]*/ ) > 0 )	{
		left  = substr( $0, 1, RSTART - 1 )
		mid   = substr( $0, RSTART, RLENGTH )
		right = substr( $0, RSTART + RLENGTH )
		# before( "hex constant", left, mid, right )
		mid = "0x" toupper( substr( mid, 3 ) )
		# after( "hex constant", left, mid, right )
		$0 = left mid right
	}
}
/^[ \t]*[#]/	{ print; next }		# Ignore preprocessor lines
/^[ 	]*[)]/	{ print; next }		# Ignore line w/only right paren
{
	# Separate code and comment
	if( match( $0, /[ \t]*[\/][*].*[*][\/][ \t]*$/ ) > 0 )	{
		code = trimRight( substr( $0, 1, RSTART - 1 ) )
		comment = substr( $0, RSTART )
	} else	{
		code = trimRight( $0 )
		comment = ""
	}
	# Template: [ :] --> [:]
	# Remove spaces before colons
	while( match( code, /[ \t]:/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "colon spaces", left, mid, right )
		mid = trim( mid )
		# after( "colon spaces", left, mid, right )
		code = left mid right
	}
	# Template: [token=token] --> [token = token]
	# Insert spaces around single-character operators
	while( match( code, /[a-zA-Z0-9\)][=<>\/*][a-zA-Z0-9\)]/ ) > 0 ) {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "operator spaces", left, mid, right )
		lop= substr( mid, 1, 1 )
		mop= substr( mid, 2, 1 )
		rop= substr( mid, 3, 1 )
		mid = lop " " mop " " rop
		# after( "operator spaces", left, mid, right )
		code = left mid right
	}
	# Template: [token==token] --> [token == token]
	# Insert spaces around double-character operators
	while(match( code, /[a-zA-Z0-9)\]][\!=<>+*%-][=<>][a-zA-Z0-9)\]]/ ) > 0 ) {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "double-operator spaces", left, mid, right )
		lop= substr( mid, 1, 1 )
		mop= substr( mid, 2, 2 )
		rop= substr( mid, 4, 1 )
		mid = lop " " mop " " rop
		# after( "double-operator spaces", left, mid, right )
		code = left mid right
	}
	# Template: [token<<=token] --> [token <<= token]
	# Insert spaces around triple-character operators
	while( match( code, /[a-zA-Z0-9)\]][<>][<>]=[a-zA-Z0-9)\]]/ ) > 0 ) {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "triple-operator spaces", left, mid, right )
		lop= substr( mid, 1, 1 )
		mop= substr( mid, 2, 3 )
		rop= substr( mid, 5, 1 )
		mid = lop " " mop " " rop
		# after( "triple-operator spaces", left, mid, right )
		code = left mid right
	}
	# Template: [ptr -> field] --> [ptr->field]
	# Remove spaces round pointers
	while( match( code, /[ \t][ \t]*->[ \t][ \t]*/ ) > 0 ) {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "pointer spaces", left, mid, right )
		mid = trim( mid )
		# after( "pointer spaces", left, mid, right )
		code = left mid right
	}
	# Template: [word (] --> [word( ]
	# Collapse spaces bewteen words and left parens
	while( match( code, /[a-zA-Z_][a-zA-Z0-9_]*[ \t][ \t]*[(][ \t]*/ ) > 0 ) {
		left  = substr( code, 1, RSTART - 1 )
		mid   = trim( substr( code, RSTART, RLENGTH ) )
		right = trimLeft( substr( code, RSTART + RLENGTH ) )
		# before( "lparen spaces", left, mid, right )
		sub( /[ \t(].*$/, "( ", mid )
		# after( "lparen spaces", left, mid, right )
		code = left mid right
	}
	# Template: [  )] --> [ )]
	# Collapse multiple spaces before right parens
	while( match( code, /[ \t][ \t][ \t]*[)]/ ) > 0 )	{
		left  = trimRight( substr( code, 1, RSTART - 1 ) )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "rparen spaces", left, mid, right )
		code = left " )" right
		# after( "rparen spaces", left, mid, right )
	}
	# Template: [;foo] --> [; foo]
	# Enforce a space after every semicolon
	while( match( code, /;[^ \t]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "semi space", left, mid, right )
		mid = "; " substr( mid, 2 )
		# after( "semi space", left, mid, right )
		code = left mid right
	}
	# Template: [(foo] --> [( foo]
	# Enforce a space after every left paren not before another left paren
	while( match( code, /[(][^ \t(]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "space after lparen", left, mid, right )
		mid = "( " trim( substr( mid, 2 ) )
		# after( "space after lparen", left, mid, right )
		code = left mid right
	}
	# Template: [foo)] --> [foo )]
	# Enfore a space before ever right paren not after another rparen
	while( match( code, /[^ \t)*][)]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "space before rparen", left, mid, right )
		mid = substr( mid, 1, RLENGTH-1 ) " )"
		# after( "space before rparen", left, mid, right )
		code = left mid right
	}
	# Template: [( token )] --> [(token)]
	# Remove spaces around token used as a cast 
	# while( match( code, /[ \t][(][ \t]*[a-zA-Z0-9_][a-zA-Z0-9_]*[ \t][)]/ ) > 0 ) {
	while( match( code, /[ \t]*[(][ \t][^-+=\/%]*[)][ \t]*/ ) > 0 ) {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "token cast spaces", left, mid, right )
		sub( /[(][ \t]*/, "(", mid )
		sub( /[ \t]*[)]/, ")", mid )
		# after( "token cast spaces", left, mid, right )
		code = left mid right
	}
	# Template: [( foo * )] --> [(foo *)]
	# Drop space after pointer before right paren of a cast
	while( match( code, /[(][^*]*[*][ \t][ \t]*[)]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "pointer cast space", left, mid, right )
		sub( /^[(][ \t]*/, "(", mid )
		sub( /[*][ \t]*[)]/, "*)", mid )
		# after( "pointer cast space", left, mid, right )
		code = left mid right
	}
	# Template: [( foo *)] --> [(foo *)]
	# Drop space after left paren of a cast
	while( match( code, /[(][ \t][^*]*[*][ \t]*[)]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "lparen cast space", left, mid, right )
		sub( /^[(][ \t]*/, "(", mid )
		sub( /[*][ \t]*[)]/, "*)", mid )
		# after( "lparen cast space", left, mid, right )
		code = left mid right
	}
	# Template: [)(] --> [) (]
	# Enfore a space between rparen--lparen
	while( match( code, /[)][(]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "rparen/lparen", left, mid, right )
		mid = ") ("
		# after( "rparen/lparen", left, mid, right )
		code = left mid right
	}
	# Template: [,foo] --> [, foo]
	# Enforce blank after comma
	while( match( code, /,[^ \t]/ ) > 0 )	{
		left  = substr( code, 1, RSTART-1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART+RLENGTH )
		# before( "blank after comma", left, mid, right )
		mid = ", " substr( mid, 2 )
		# after( "blank after comma", left, mid, right )
		code = left mid right
	}
	# Template: [return abc;] --> [return( abc );]
	# Enforce parens around return statements
	while( match( code, /return[ \t][^(][^;]*;/ ) > 0 )	{
		left  = substr( code, 1, RSTART-1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART+RLENGTH )
		# before( "return parens", left, mid, right )
		# mid == "return[ \t]*tokens...;"
		mid = "return( " trim( substr( mid, 8, RLENGTH-8 ) ) " );"
		# after( "return parens", left, mid, right )
		code = left mid right
	}
	# Template: [*( foo )] --> [*(foo)]
	# Remove layer of blanks around simple expression used a pointer
	while( match( code, /[*&][(][ \t][^()]*[)]/ ) > 0 )	{
		left  = substr( code, 1, RSTART-1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART+RLENGTH )
		# before( "pointer expr", left, mid, right )
		mid = substr( mid, 1, 1 ) "(" trim( substr( mid, 3, RLENGTH-4 ) ) ")"
		# after( "pointer expr", left, mid, right )
		code = left mid right
	}
	# Template: [ {] --> [\t{]
	# Force TAB before LBRACE not at left margin
	if( match( code, /[ \t]*[{][ \t]*$/ ) > 0 )	{
		if( RSTART > 1 )	{
			left  = substr( code, 1, RSTART - 1 )
			mid   = substr( code, RSTART, RLENGTH )
			right = substr( code, RSTART + RLENGTH )
			# before( "lbrace-bol", left, mid, right )
			mid     = "\t{"
			# after( "lbrace-bol", left, mid, right )
			code = left mid right
		}
	}
	# Template: [{foo] --> [{ foo]
	# Force space after LBRACE not at EOL
	if( match( code, /[{][^ \t]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "lbrace-leadin", left, mid, right )
		mid     = sprintf( "{ %s", substr( mid, 2 ) )
		# after( "lbrace-leadin", left, mid, right )
		code = left mid right
	}
	# Template: [}[,]$] --> [\t}[,]]
	# Force TAB before RBRACE at end of line, unless at left margin
	if( match( code, /[ \t]*[}][,]?[ \t]*$/ ) > 0 )	{
		if( RSTART > 1 )	{
			left  = substr( code, 1, RSTART - 1 )
			mid   = substr( code, RSTART, RLENGTH )
			right = substr( code, RSTART + RLENGTH )
			# before( "rbrace-eol", left, mid, right )
			mid     = sprintf( "\t%s", trim( mid ) )
			# after( "rbrace-eol", left, mid, right )
			code = left mid right
		}
	}
	# Template: [func(args)] --> [func( args )]
	# Force spaces around outermost (I hope) parens of function call
	if( match( code, /[a-zA-Z0-9_][ \t]*[(][^)(]*[)]/) > 0 ) {
		# Do not include last char of func with RE
		left  = substr( code, 1, RSTART )
		mid   = substr( code, RSTART+1, RLENGTH-1 )
		right = substr( code, RSTART + RLENGTH )
		# before( "arg-parens", left, mid, right )
		mid   = trimLeft( mid )		# Drop leading whitespace
		if( match( mid, /[(][ \t][ \t]*/ ) > 0 )	{
			# Drop any spaces after first lparen
			mid = "(" substr( mid, RSTART + RLENGTH )
		}
		if( match( mid, /[ \t][ \t]*[)]/ ) > 0 )	{
			# Drop any spaces before last rparen
			mid = substr( mid, 1, RSTART - 1 ) ")"
		}
		Lmid = length( mid )
		mid = sprintf( "( %s )", substr( mid, 2, Lmid - 2 ) )
		# after( "arg-parens", left, mid, right )
		code = left mid right
	}
	# Template: [while(args)] --> [while( args )]
	# Force spaces around outermost (I hope) parens of function call
	if( match( code, /[a-zA-Z0-9_][ \t]*[(][^)(]*[)]/) > 0 ) {
		# Do not include last char of func with RE
		left  = substr( code, 1, RSTART )
		mid   = substr( code, RSTART+1, RLENGTH-1 )
		right = substr( code, RSTART + RLENGTH )
		# before( "arg-parens", left, mid, right )
		mid   = trimLeft( mid )		# Drop leading whitespace
		if( match( mid, /[(][ \t][ \t]*/ ) > 0 )	{
			# Drop any spaces after first lparen
			mid = "(" substr( mid, RSTART + RLENGTH )
		}
		if( match( mid, /[ \t][ \t]*[)]/ ) > 0 )	{
			# Drop any spaces before last rparen
			mid = substr( mid, 1, RSTART - 1 ) ")"
		}
		Lmid = length( mid )
		mid = sprintf( "( %s )", substr( mid, 2, Lmid - 2 ) )
		# after( "arg-parens", left, mid, right )
		code = left mid right
	}
	# Template: [( )] --> [()]
	# Remove any intervening whitespace between matching parens
	while( match( code, /[(][ \t][ \t]*[)]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "rparen/lparen", left, mid, right )
		mid = "()"
		# after( "rparen/lparen", left, mid, right )
		code = left mid right
	}
	# Template: [)foo] --> [) foo]
	# Enfore a space after rparens followed by non-punctuation
	while( match( code, /[)][a-zA-Z0-9_]/ ) > 0 )	{
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "space after rparen", left, mid, right )
		mid = ") " substr( mid, 2 )
		# after( "space after rparen", left, mid, right )
		code = left mid right
	}
        # Remove bogus spaces from single quotes
        while( match( code, /['][ ][^'][']/ ) > 0 )     {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "space after rparen", left, mid, right )
                mid = "'" substr( mid, 3, 1 ) "'"
		code = left mid right
	}
        while( match( code, /['][^'][ ][']/ ) > 0 )     {
		left  = substr( code, 1, RSTART - 1 )
		mid   = substr( code, RSTART, RLENGTH )
		right = substr( code, RSTART + RLENGTH )
		# before( "space after rparen", left, mid, right )
                mid = "'" substr( mid, 2, 1 ) "'"
		code = left mid right
	}
	# Finished
	print trimRight( code comment )
} 
