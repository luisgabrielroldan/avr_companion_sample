# File: Makefile

NAME = arduino
PREFIX = $(MIX_APP_PATH)/priv
FIRMWARE = $(PREFIX)/$(NAME).hex

# Unexport some vars defined by Nerves that
# will cause issues with the arduino Makefile
unexport CFLAGS
unexport CXX
unexport CXXFLAGS
unexport OVERRIDE_EXECUTABLES

export TARGET = $(NAME)
export OBJDIR = $(MIX_APP_PATH)/obj

$(FIRMWARE): build $(PREFIX)
	cp $(OBJDIR)/$(NAME).hex $(FIRMWARE)

build:
	$(MAKE) -C $(NAME)

$(PREFIX):
	mkdir -p $@
