TARGETS	:= all install install.bin install.awks uninstall uninstall.all

.PHONEY: ${TARGETS}

PREFIX	=${DESTDIR}/opt/cfmt
BINDIR  =${PREFIX}/bin
MANDIR  =${PREFIX}/man

SCRIPTS =castfmt cfmt comment ifnest parens
AWKS    =castfmt.awk comment.awk ifnest.awk parens.awk

OWNER	=$(shell id -u)
GRP	=$(shell id -g)
MODE	=0755
DMODE	=0644

define	INSTALL_BIN_template
install:: install-${1}
install-${1}:: ${1}
	@cmp -s ${1} $${BINDIR}/${1} || $${SHELL} -xc "install -D -m '${MODE}' -o '${OWNER}' -g '${GRP}' '${1}' '$${BINDIR}/${1}'"
.PHONY: install-${1}
endef

define	INSTALL_AWK_template
install:: install-${1}
install-${1}:: ${1}
	@cmp -s ${1} $${BINDIR}/${1} || $${SHELL} -xc "install -D -m '${DMODE}' -o '${OWNER}' -g '${GRP}' '${1}' '$${BINDIR}/${1}'"
.PHONY: install-${1}
endef

all:: ${SCRIPTS} ${AWKS}

$(foreach f,${SCRIPTS},$(eval $(call INSTALL_BIN_template,${f})))
$(foreach f,${AWKS},$(eval $(call INSTALL_AWK_template,${f})))

uninstall:: uninstall.all

uninstall.all::
	cd ${BINDIR} && ${RM} ${SCRIPTS} ${AWKS}
