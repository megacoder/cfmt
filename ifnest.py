#!/usr/bin/python

import  sys
import  re

class   IfNester( object ):
    def __init__( self ):
        self.depth = -1
        return

    def pushCondition( self, condition ):
        self.depth = self.depth + 1
        return

    def getDepth( self ):
        return self.depth

    def popCondition( self ):
        self.depth = self.depth - 1
        return

    def printPreprocessor( self, verb, tuples ):
        print '#%s%-6s %s' % (
            '__' * self.depth,
            verb,
            ' '.join( tuples )
        )

    def process( self, line ):
        tokens = line.split()
        if len( tokens ) == 0 or not tokens[0].startswith( '#' ):
            # Not a preprocessor line, just print it and bail out
            print line
            return
        # Sharp could be a token by itself
        if tokens[0] == '#':
            tokens.pop( 0 )
            try:
                verb = tokens.pop( 0 )[1:]
            except:
                verb = 'error'
        else:
            # Nope, so take remainder of token for the directive
            verb = tokens.pop(0)[1:]
        if verb == 'if':
            self.pushCondition( tokens )
            self.printPreprocessor( verb, tokens )
        elif verb == 'ifdef':
            self.pushCondition( tokens )
            self.printPreprocessor( verb, tokens )
        elif verb == 'elif':
            # Does not change nexting level
            self.printPreprocessor( verb, tokens )
        elif verb == 'else':
            # Does not change nexting level
            self.printPreprocessor( verb, tokens )
        elif verb == 'endif':
            self.printPreprocessor( verb, tokens )
            self.popCondition()
        elif verb == 'define':
            self.printPreprocessor( verb, tokens )
        elif verb == 'error':
            self.printPreprocessor( verb, tokens )
        else:
            self.printPreprocessor( 'error', tokens )
        return

if __name__ == '__main__':
    nest = IfNester()
    for line in sys.stdin:
        nest.process( line.rstrip() )
    if nest.getDepth() != -1:
        next.process(
            '#error WARNING! WARNING! DANGER, WILL ROBINSON!'.split()
         )
