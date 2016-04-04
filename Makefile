test: _PHONY
	haxe test.hxml
	neko test.n

ndll/Linux64/flare.ndll: src/flare.c
	gcc src/flare.c -shared -o ndll/Linux64/flare.ndll -fPIC

clean: _PHONY
	rm ndll/*/flare.ndll

.PHONY: _PHONY

