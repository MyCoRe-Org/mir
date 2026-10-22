<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:mircrossrefutils="http://www.mycore.de/xslt/mircrossrefutils"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mircrossrefutils:convert-jats-abstract" as="element()*">
    <xsl:param name="jatsXml" as="xs:string"/>
    <xsl:variable name="wrapperDoc" select="fn:document(concat('crossref-jats-abstract2mods-abstract:', fn:encode-for-uri($jatsXml)))"/>
    <xsl:sequence select="$wrapperDoc/mods:mods/*"/>
  </xsl:function>

</xsl:stylesheet>
