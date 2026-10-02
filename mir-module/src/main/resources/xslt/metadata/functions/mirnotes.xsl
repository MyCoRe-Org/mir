<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:mirnotes="http://www.mycore.de/xslt/mirnotes"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirnotes:type" as="xs:string">
    <xsl:param name="note" as="element(mods:note)" />
    <xsl:sequence select="
      if ($note/@type) then replace(normalize-space($note/@type), ' ', '_') else 'admin'
    " />
  </xsl:function>

  <xsl:function name="mirnotes:category" as="element()?">
    <xsl:param name="note" as="element(mods:note)" />
    <xsl:sequence select="mcrclass:category('noteTypes', mirnotes:type($note))" />
  </xsl:function>

  <xsl:function name="mirnotes:visible" as="xs:boolean">
    <xsl:param name="note" as="element(mods:note)" />
    <xsl:param name="access" as="xs:string*" />

    <xsl:variable name="x-access" select="
      mirnotes:category($note)/label[@xml:lang='x-access']/@text
    " />
    <xsl:sequence select="$access = tokenize(normalize-space($x-access[1]), ' ')" />
  </xsl:function>

  <xsl:function name="mirnotes:label" as="xs:string">
    <xsl:param name="note" as="element(mods:note)" />
    <xsl:sequence select="string(mcrclass:current-label-text(mirnotes:category($note)))" />
  </xsl:function>

</xsl:stylesheet>
