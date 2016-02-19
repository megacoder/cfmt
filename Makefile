TARGETS	:= all install install.bin install.awks uninstall uninstall.all

.PHONEY: ${TARGETS}

PREFIX	=/opt
BINDIR  =${PREFIX}/bin
MANDIR  =${PREFIX}/man

SCRIPTS =castfmt cfmt comment ifnest parens
AWKS    =castfmt.awk comment.awk ifnest.awk parens.awk

all:: ${SCRIPTS} ${AWKS}

install:: install.bin install.awks

install.bin:: ${SCRIPTS}
	for x in ${SCRIPTS}; do install -D -m 0555 $$x /opt/bin/$$x; done

install.awks:: ${AWKS}
	for x in ${AWKS}; do install -D -m 0444 $$x /opt/bin/$$x; done

uninstall:: uninstall.all

uninstall.all::
	cd ${BINDIR} && ${RM} ${SCRIPTS} ${AWKS}
