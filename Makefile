PREFIX	=/opt
BINDIR  =${PREFIX}/bin
MANDIR  =${PREFIX}/man

SCRIPTS =castfmt cfmt comment ifnest parens
AWKS    =castfmt.awk comment.awk ifnest.awk parens.awk

all:

install: install.bin

install.bin:
	install -d ${BINDIR}
	install -c ${SCRIPTS} ${BINDIR}
	install -c -m 0444 ${AWKS} ${BINDIR}

uninstall: uninstall.bin

uninstall.bin:
	cd ${BINDIR} && ${RM} ${SCRIPTS} ${AWKS}
