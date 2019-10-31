.PHONY: run
run: love
	./love .

love:
	wget -O love https://bitbucket.org/rude/love/downloads/love-11.3-x86_64.AppImage
	chmod +x love
