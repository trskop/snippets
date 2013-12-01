SRC = \
  controler.js \
  generics.js \
  user-message.js

MINIFY = uglifyjs
MINIFY_FLAGS = --no-copyright
TARGET = $(SRC:.js=.min.js) all.min.js
YEARS := 2013
CONTROLER_YEARS := 2012, 2013
ALL_YEARS := $(CONTROLER_YEARS)
COPYRIGHT = \
    // Copyright(c) $(YEARS), Peter Trsko <peter.trsko@gmail.com>. \
    Licensed under <http://opensource.org/licenses/BSD-3-Clause>.
MK_COPYRIGHT = echo "$(COPYRIGHT)"

%.min.js: %.js
	$(MK_COPYRIGHT) > $@
	$(MINIFY) $(MINIFY_FLAGS) $< >> $@

controler.min.js: YEARS = $(CONTROLER_YEARS)
all.min.js: YEARS = $(ALL_YEARS)

.DEFAULT: all

all: $(TARGET)

all.min.js: $(SRC)
	$(MK_COPYRIGHT) > $@
	$(MINIFY) $(MINIFY_FLAGS) $^ >> $@

clean:
	rm $(TARGET)

.PHONY: all clean
