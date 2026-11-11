<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirmapper="http://www.mycore.de/xslt/mirmapper"
  xmlns:mirvalidationhelper="http://www.mycore.de/xslt/mirvalidationhelper"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirvalidationhelper:classification-exists" as="xs:boolean">
    <xsl:param name="classid" as="xs:string" />
    <xsl:param name="categid" as="xs:string" />
    <xsl:variable name="uri" select="concat('classification:metadata:0:children:', $classid, ':', encode-for-uri($categid))" />
    <xsl:sequence select="doc-available($uri) and exists(document($uri)//category[@ID = $categid])" />
  </xsl:function>

  <xsl:function name="mirvalidationhelper:validateSDNB" as="xs:string">
    <xsl:param name="sdnb" as="xs:string?" />
    <xsl:variable name="value" select="normalize-space($sdnb)" />
    <xsl:variable name="mapped-old" select="if (string-length($value) = 2) then mirmapper:getSDNBfromOldSDNB($value) else ''" />
    <xsl:choose>
      <xsl:when test="$value = ''">
        <xsl:sequence select="''" />
      </xsl:when>
      <xsl:when test="mirvalidationhelper:classification-exists('SDNB', $value)">
        <xsl:sequence select="$value" />
      </xsl:when>
      <xsl:when test="$mapped-old != '' and mirvalidationhelper:classification-exists('SDNB', $mapped-old)">
        <xsl:sequence select="$mapped-old" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
