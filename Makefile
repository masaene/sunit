
TARGET="sunit"
FLEX_ORG="sunit.l"
FLEX_C="sunit.yy.c"
BISON_ORG="sunit.y"
BISON_C="sunit.tab.c"
LOG="bison.log"

all:$(TARGET)
.PHONY:all clean $(FLEX_ORG) $(BISON_ORG)

$(TARGET):$(FLEX_C) $(BISON_C)
	gcc -g $^ -lfl -ly -o $@

$(FLEX_C):$(FLEX_ORG)
	flex -o $@ $^

$(BISON_C):$(BISON_ORG)
	bison -r all --report-file=$(LOG) -d -o $@ $^

clarn:
	rm $(TARGET)
	rm $(FLEX_C)
	rm $(BISON_C)
