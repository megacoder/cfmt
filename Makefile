TARGETS	:= all install install.bin install.awks uninstall uninstall.all

.PHONEY: ${TARGETS}

PREFIX	=/opt
BINDIR  =${PREFIX}/bin
MANDIR  =${PREFIX}/man

SCRIPTS =castfmt cfmt comment ifnest parens
AWKS    =castfmt.awk comment.awk ifnest.awk parens.awk

define	INSTALL_BIN_template
install:: install-${1}
install-${1}:: ${1}
	@cmp -s ${1} $${BINDIR}/${1} || $${SHELL} -xc 'install -D ${1} $${BINDIR}/${1}'
endef

define	INSTALL_AWK_template
install:: install-${1}
install-${1}:: ${1}
	@cmp -s ${1} $${BINDIR}/${1} || $${SHELL} -xc 'install -D -m 0444 ${1} $${BINDIR}/${1}'
endef

all:: ${SCRIPTS} ${AWKS}

$(foreach f,${SCRIPTS},$(eval $(call INSTALL_BIN_template,${f})))
$(foreach f,${AWKS},$(eval $(call INSTALL_AWK_template,${f})))

uninstall:: uninstall.all

uninstall.all::
	cd ${BINDIR} && ${RM} ${SCRIPTS} ${AWKS}
