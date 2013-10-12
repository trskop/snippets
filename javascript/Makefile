SRC = user-message.js
TARGET = $(SRC:.js=.min.js)
COPYRIGHT = \
    // Copyright(c) 2013, Peter Trsko <peter.trsko@gmail.com>. \
    Licensed under <http://opensource.org/licenses/BSD-3-Clause>.

%.min.js: %.js
	echo "$(COPYRIGHT)" > $@
	uglifyjs --no-copyright $< >> $@

.DEFAULT: all

all: $(TARGET)

clean:
	rm $(TARGET)

.PHONY: all clean
