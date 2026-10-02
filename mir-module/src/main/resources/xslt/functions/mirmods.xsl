<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrmods="http://www.mycore.de/xslt/mods"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirmods:genres" as="xs:string*">
    <xsl:param name="mods" as="element(mods:mods)?" />

    <xsl:variable name="genre" select="$mods/mods:genre[@type='intern'][1]" />
    <xsl:if test="$genre">
      <xsl:variable name="hierarchy" select="mcrmods:to-mycoreclass($genre, 'parent')//category/@ID ! string()" />
      <xsl:sequence select="
        if (exists($hierarchy)) then reverse($hierarchy)
        else substring-after($genre/@valueURI, '#')[. != '']
      " />
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>
