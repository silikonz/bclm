prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox --arch arm64
	#strip .build/apple/Products/Release/bclm

install: build
	mkdir -p "$(bindir)"
	install ".build/apple/Products/Release/bclm" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/bclm"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
