# ifnest.awk
BEGIN   {
        AND = "AND"
}
function trim( s,       v )     {
        v = s
        sub( /^[ \t]*/, "", v )
        sub( /[ \t]*$/, "", v )
        return( v )
}
function parens( s,     v )     {
        v = trim( s )
        # Parens must be around whitespace
        if( substr( v, 1, 1 ) == "(" )  {
                # If no internal whitespace then drop parens
                if( match( v, /[ \t]/ ) < 1 )    {
                        # Drop surrounding parens
                        v = substr( v, 2, length(v)-2 )
                }
        } else if( match( v, /[ \t]/ ) > 0 )    {
                # Internal whitespace so add parens
                v = sprintf( "(%s)", v )
        }
        # printf "parens( |%s| ) --> |%s|\n", s, v
        return( v )
}
function canonicalTerm( old,      new )   {
        new = trim( old )
        # Change into either YUP or NOPE
        if( new == "0" )        {
                new = "NOPE"
        } else if( new == "1" )        {
                new = "YUP"
        }
        return( new )
}
function simplify( s,           c, v )     {
        v = trim( s )
        c = substr( v, 1, 1 )
        if( c == "(" )  {
                # Remove outer layer of parens, simplify and put them back
                v = "(" simplify( substr( v, 2, length(v)-2 ) ) ")"
        } else if( c == "!" )   {
                # Simplify operand of unary NOT
                v = "!" simplify( substr( v, 2 ) )
                if( v == "!YUP" )       {
                        v = "NOPE"
                } else if( v == "!NOPE" )       {
                        v = "YUP"
                }
        } else  {
                # Simple (non-ifdef) expression
                v = canonicalTerm( v )
        }
        v = parens( v )
        # printf "simplify( |%s| ) --> |%s|\n", s, v
        return( v )
}
function rewrite( old, conjunct, new ) {
        # If level > 0 and we have a conjunction, append new stuff
        if( length( old ) && length( conjunct ) )      {
                reformed = sprintf( "%s %s %s", parens( old ), conjunct,
                        simplify( new ) )
        } else  {
                reformed = simplify( new )
        }
        return( parens( reformed ) )
}
/./     { sub( /$/, "" ) }            # Drop stupid Windoze line endings
/^[ \t]*[#][ \t]*/ { sub( /^[ \t]*[#][ \t]*/, "#" ) }# Drop whitespace around #
/^[^#]/	{ print; next }			# Copy non-preprocessor lines
$1 == "#if"	{
	gsub( /[ \t]*\/\*.*\*\/[ \t]*/, "" )	# Drop comments
	print indent( $0 )
	$1 = ""
	sub( /^[ \t]*/, "" )
	# condition[ ++level ]  = $0
        old = condition[ level ]
        condition[ ++level ] = rewrite( old, AND, $0 )
        # printf "%d\t|%s|\n", level, condition[ level ]
	lines[ level ] = NR
	next
}
$1 == "#ifndef"	{
	gsub( /[ \t]*\/\*.*\*\/[ \t]*/, "" )	# Drop comments
	print indent( $0 )
	$1 = ""
	sub( /^[ \t]*/, "" )
	# condition[ ++level ] = sprintf( "!%s", $0 )
        old = condition[ level ]
	condition[ ++level ] = rewrite( old, AND, "!(" $0 ")" )
        # printf "%d\t|%s|\n", level, condition[ level ]
	lines[ level ] = NR
	next
}
$1 == "#ifdef"	{
	gsub( /[ \t]*\/\*.*\*\/[ \t]*/, "" )	# Drop comments
	print indent( $0 )
	$1 = ""
	sub( /^[ \t]*/, "" )
	# condition[ ++level ] = sprintf( "%s", $0 )
        old = condition[ level ]
        condition[ ++level ] = rewrite( old, AND, $0 )
        # printf "%d\t|%s|\n", level, condition[ level ]
	lines[ level ] = NR
	next
}
$1 == "#elif"	{
	gsub( /[ \t]*\/\*.*\*\/[ \t]*/, "" )	# Drop comments
	--level; print indent( $0 ); ++level
	$1 = ""
	sub( /^[ \t]*/, "" )
        # Nested
        old = sprintf( "!%s", parens( condition[level] ) )
        condition[ level ] = rewrite( old, AND, $0 )
        # printf "%d\t|%s|\n", level, condition[ level ]
	lines[ level ] = NR
	next
}
$1 == "#else"	{
	--level; printf "%s", indent( $1 ); ++level
	if( doComment )	{
		# condition[ level ] = "(NOT " condition[ level ] ")"
		condition[ level ] = "!" condition[ level ]
		lines[ level ] = NR
		printf " /* %s */", condition[level]
	}
	printf "\n"
	next
}
$1 == "#endif"	{
	--level; printf "%s", indent( $1 ); ++level
	if( doComment )	{
		printf " /* %s */", condition[level]
	}
	printf "\n"
	--level
	next
}
{ print indent( $0 ) }			# Any other pre-processor line
# Rewrite the input string "#abcdef" into "#  abcdef" to indent nested lines
function indent( s,		n )	{
	n = level * 2
	if( n < 0 ) n = 0
	return sprintf( "%s%" n "." n "s%s", substr( s, 1, 1 ),
		" ", substr( s, 2 ) )
}
END	{
	if( level )	{
		bars = sprintf( "%72.72s", " " )
		gsub( / /, "-", bars )
		bars = " *" bars
		printf "\n"
		print "/*"
		print bars
		print " * WATCH OUT, THIS DID NOT WORK SO WELL!"
		print bars
		printf( " * %d unterminated conditional:\n", level,
			(level == 1) ? "" : "s" )
		print  " *"
		for( i = 1; i <= level; ++i )	{
			printf " * Line %d\n", lines[ i ]
		}
		print bars
		print " */"
	}
}
