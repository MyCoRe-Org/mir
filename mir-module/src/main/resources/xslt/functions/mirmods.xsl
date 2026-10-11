<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirmods:root-ids" as="xs:string*">
    <xsl:param name="parent" as="element()" />
    <xsl:for-each select="$parent/mods:relatedItem[@type = ('host', 'series')][@xlink:href]">
      <xsl:variable name="ancestor-ids" select="mirmods:root-ids(.)" />
      <xsl:sequence select="if (exists($ancestor-ids)) then $ancestor-ids else string(@xlink:href)" />
    </xsl:for-each>
  </xsl:function>

</xsl:stylesheet>
