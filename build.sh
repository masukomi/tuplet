#!/bin/bash

antlr-gemerator create \
	--author='masukomi' \
	--desc="a twiki parser for ruby" \
	--email='masukomi@masukomi.org' \
	--homepage='https://github.com/masukomi/twiki' \
	--grammar=TwikiAntlr/Twiki.g4  --root=main
