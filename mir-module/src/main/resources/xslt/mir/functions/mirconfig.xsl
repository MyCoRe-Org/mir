<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mirconfig="http://www.mycore.de/xslt/mirconfig"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirconfig:get-list" as="xs:string*">
    <xsl:param name="property" as="xs:string" />
    <xsl:param name="variants" as="xs:string*" />

    <xsl:variable name="value" select="(
      ($variants ! mcrproperty:get($property || '.' || .)),
      mcrproperty:get($property)
    )[normalize-space()][1]" />

    <xsl:if test="empty($value)">
      <xsl:message>WARN: property <xsl:value-of select="$property" /> is not set, nothing is displayed</xsl:message>
    </xsl:if>
    <xsl:sequence select="
      if (normalize-space($value) = 'none') then ()
      else tokenize($value, ',') ! normalize-space()[. != '']
    " />
  </xsl:function>

</xsl:stylesheet>
