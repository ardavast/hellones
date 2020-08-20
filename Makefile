hellones.nes: hellones.o hellones.ld
	ld65 -o hellones.nes -C hellones.ld hellones.o

hellones.o: hellones.S font.chr
	ca65 -o hellones.o hellones.S

clean:
	rm -f hellones.nes hellones.o

run: hellones.nes
	fceux hellones.nes
