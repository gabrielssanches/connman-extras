.DEFAULT: all

TARGETS=connman-agent

ARCH?=x64
BINDIR?=_bin_$(ARCH)
BUILDDIR?=_build_$(ARCH)

.PHONY: all
all: $(BUILDDIR) $(BINDIR) $(addprefix $(BINDIR)/, $(TARGETS))

.PHONY: clean
clean:
	rm -rf _bin*
	rm -rf _build*

$(BINDIR):
	mkdir -p $(BINDIR)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

DBG_OPT?=-gdwarf-2 -O2 # symbols and optimization

CFLAGS+=-DG_LOG_USE_STRUCTURED
CFLAGS+=-DG_LOG_DOMAIN=\"connman-agent\"
CFLAGS+=-std=c11
CFLAGS+=-Werror
CFLAGS+=-Wall
CFLAGS+=$(shell pkg-config --cflags-only-I gio-2.0)
CFLAGS+=$(shell pkg-config --cflags-only-I gio-unix-2.0)

SRC_DEPS=Makefile
SRC=connman-agent.c
HINCS+=-I.

SRC_OBJ=$(subst .c,.o,$(SRC))
OBJS=$(SRC_OBJ)

LDFLAGS+=$(shell pkg-config --libs gio-2.0 gio-2.0)

$(BINDIR)/connman-agent: $(addprefix $(BUILDDIR)/, $(OBJS))
	$(CC) $(CFLAGS) $(DBG_OPT) $^ $(HINCS) -o $@ $(LDFLAGS)

DEPFLAGS = -MT $@ -MMD -MP -MF $(BUILDDIR)/$*.d

$(BUILDDIR)/%.o:%.c $(SRC_DEPS)
	$(CC) $(CFLAGS) $(DBG_OPT) $(DEPFLAGS) $(HINCS) -c $< -o $@

-include $(subst .o,.d,$(shell ls $(BUILDDIR)/*.o))
