# cfmt
Collection of shell scripts to reformat C programs the way I like them: easy to read.

## Why, Oh Why?
I couldn't get indent(1) to indent my code the One True Way(tm), which is my arrangements of braces, parens, commas, comments, and sundry just my way.
This even add comments to the infamous Nested #Include egregiory so try to hint to the reader just what code is being examined by cpp(1) and which isn't.

## This Seems Like A Good Idea Because???
Each project and every company I had to deal with used their own One True Coding Standard(company private) to fit their mindset.  I could have developed using those but by using one consistent method allowed me to develop a "sense of smell" about finding bugs and debugging was a more instinctive activity than one of translating:

1. What the customer said he wanted; and
2. What the statement of work actuall said; and
3. What I thought the specs were after; and
4. How the previous engineer borked their undersanding of steps #1-#4; and
5. Oh, my <i>deity</i>, how to I get out of this one?

Each script was written to address a particular item where my One True Way(tm) was most likely to differ from their canonical code that met the standard buy didn't work, so they got no points for their workmanship code layout conformance.  After my keen instinct honed in on the problem, running indent(1) or its ilk to render the code back into the preferred patois' we were off to the next race against time.

## How Do I Use This Stuff?
For the most part, the scripts (usually awk(1) pattern matcning) are simple filters and can be piped in whatever sequence you like.  Being part of a shell pipeline permits them to corrupt the original input only very seldomly -- and that is usually because of pilot error.  (Let no pilots near your code without close supervision.)

## Notes About Comments
Single-line comments (/* foo foo */) are always aligned on the same columns and are padded out to column 72 for the ending "*/" tag.  Yeah, used to have similar tool for FORTRAN decks.

Multi-line comments (/* and */ are on differing lines) construct a box comment:
```
/*
 **********************************************************************************
 * This is my comment stuff here to dazzle your boggle.
 **********************************************************************************
 */
```

## But I Use An IDE
My sympathies.  Where should we all send the flowers?
