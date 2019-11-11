# A custom makefile for the check-health utility.
# Copyright (C) 2019 Jaromir Hradilek <jhradilek@gmail.com>

# This program is  free software:  you can redistribute it and/or modify it
# under  the terms  of the  GNU General Public License  as published by the
# Free Software Foundation, version 3 of the License.
#
# This program  is  distributed  in the hope  that it will  be useful,  but
# WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
# BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the  GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# General information about the utility:
NAME    = check-health
VERSION = 20191111

# General settings:
SHELL   = /bin/sh
INSTALL = /usr/bin/install -c
POD2MAN = /usr/bin/pod2man
SRCS    = check-health.sh
MAN1    = check-health.1
DOCS    = AUTHORS COPYING README.adoc TODO

# Target directories:
prefix  = /usr/local
bindir  = $(prefix)/bin
docdir  = $(prefix)/share/doc/$(NAME)-$(VERSION)
mandir  = $(prefix)/share/man/man1

# The following are the make rules. Do not edit the rules unless you really
# know what you are doing:
.PHONY: all
all: $(MAN1)

.PHONY: clean
clean:
	-rm -f $(MAN1)

.PHONY: install
install: $(SRCS) $(MAN1) $(DOCS)
	@echo "Creating target directories:"
	$(INSTALL) -d $(bindir)
	$(INSTALL) -d $(mandir)
	$(INSTALL) -d $(docdir)
	@echo "Installing executables:"
	$(INSTALL) -m 755 check-health.sh $(bindir)/check-health
	@echo "Installing manual pages:"
	$(INSTALL) -m 644 check-health.1 $(mandir)
	@echo "Installing documentation files:"
	$(INSTALL) -m 644 AUTHORS $(docdir)
	$(INSTALL) -m 644 COPYING $(docdir)
	$(INSTALL) -m 644 README.adoc $(docdir)
	$(INSTALL) -m 644 TODO $(docdir)
	-$(INSTALL) -m 644 ChangeLog $(docdir)
	@echo "Done."

.PHONY: uninstall
uninstall:
	@echo "Removing executables:"
	-rm -f $(bindir)/check-health
	@echo "Removing manual pages:"
	-rm -f $(mandir)/check-health.1
	@echo "Removing documentation files:"
	-rm -f $(docdir)/AUTHORS
	-rm -f $(docdir)/COPYING
	-rm -f $(docdir)/README.adoc
	-rm -f $(docdir)/TODO
	-rm -f $(docdir)/ChangeLog
	@echo "Removing empty directories:"
	-rmdir $(bindir)
	-rmdir $(mandir)
	-rmdir $(docdir)
	@echo "Done."

%.1: %.sh
	$(POD2MAN) --section=1 --name="$(basename $^)" \
	                       --release="Version $(VERSION)" $^ $@
