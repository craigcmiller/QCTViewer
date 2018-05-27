CXX = g++
CXXFLAGS = -fPIC
CXXFLAGS_REL = -O3 -fomit-frame-pointer -Wall
CXXFLAGS_DBG = -g -ggdb
LDFLAGS = -shared

OBJECTS = 	qctmap.o \
			georef.o \
			qctpalette.o \
			qcttilemgr.o \
            qctmmap.o

TESTSUITE_OBJECTS = test.o

release: CXXFLAGS += $(CXXFLAGS_REL)
release: lastmade_rel libqct

debug: CXXFLAGS += $(CXXFLAGS_DBG)
debug: lastmade_dbg libqct

debug: CXXFLAGS += $(CXXFLAGS_DBG)

libqct: $(OBJECTS)
	$(CXX) -o $@.so $(LDFLAGS) $(OBJECTS)

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<

lastmade_rel:
	@if [ -f .lastmadedbg ]; then rm -f .lastmadedbg; rm -f *.o; fi
	@touch .lastmaderel

lastmade_dbg:
	@if [ -f .lastmaderel ]; then rm -f .lastmaderel; rm -f *.o; fi
	@touch .lastmadedbg

test: $(TESTSUITE_OBJECTS)
	$(CXX) -o test -O3 -L. -lqct $(TESTSUITE_OBJECTS)

clean:
	rm -f *.so *.o

