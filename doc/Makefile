# DocBook stylesheets/DTD are resolved through the local XML catalog:
#   macOS: brew install docbook docbook-xsl   (catalog under $(brew --prefix)/etc/xml)
#   Linux: apt-get install docbook-xml docbook-xsl   (catalog /etc/xml/catalog)
CATALOG := $(firstword $(wildcard /opt/homebrew/etc/xml/catalog /usr/local/etc/xml/catalog /etc/xml/catalog))

all: html/index.html

html/index.html: quickref.xml quickref.xsl
	@test -n "$(CATALOG)" || { echo "No XML catalog found - install docbook + docbook-xsl"; exit 1; }
	mkdir -p html
	XML_CATALOG_FILES=$(CATALOG) xsltproc --nonet -o html/ quickref.xsl quickref.xml

check:
	@test -n "$(CATALOG)" || { echo "No XML catalog found - install docbook + docbook-xsl"; exit 1; }
	XML_CATALOG_FILES=$(CATALOG) xmllint --nonet --valid --noout quickref.xml

clean:
	rm -f *.html html/*.html *.txt
	-rmdir html
