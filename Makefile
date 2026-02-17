# VMSL — Makefile for C modules
# Build vectors.so and matrix.so for use with Lua >= 5.4

LUA_VERSION ?= 5.4

# Try pkg-config first, fall back to common paths
LUA_INC  ?= $(shell pkg-config --cflags lua$(LUA_VERSION) 2>/dev/null || \
             pkg-config --cflags lua-$(LUA_VERSION) 2>/dev/null || \
             pkg-config --cflags lua 2>/dev/null || \
             echo "-I/usr/include/lua$(LUA_VERSION)")

LUA_CMOD ?= $(shell pkg-config --variable=INSTALL_CMOD lua$(LUA_VERSION) 2>/dev/null || \
             pkg-config --variable=INSTALL_CMOD lua-$(LUA_VERSION) 2>/dev/null || \
             echo "/usr/local/lib/lua/$(LUA_VERSION)")

CC      ?= gcc
CFLAGS  += -O2 -Wall -Wextra -fPIC $(LUA_INC)
LDFLAGS += -shared -lm

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    LDFLAGS += -undefined dynamic_lookup
    EXT = .so
else
    EXT = .so
endif

# ── targets ──────────────────────────────────────────────────────

all: vectors$(EXT) matrix$(EXT)

vectors$(EXT): src/vector.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

matrix$(EXT): src/matrix.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

install: all
	install -d $(DESTDIR)$(LUA_CMOD)
	install -m 755 vectors$(EXT) $(DESTDIR)$(LUA_CMOD)/vectors$(EXT)
	install -m 755 matrix$(EXT) $(DESTDIR)$(LUA_CMOD)/matrix$(EXT)

clean:
	rm -f vectors$(EXT) matrix$(EXT)

.PHONY: all install clean
