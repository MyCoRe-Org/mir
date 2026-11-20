<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='basket']" mode="result-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />

    <li>
      <xsl:call-template name="basketLink">
        <xsl:with-param name="identifier" select="$object-id" />
        <xsl:with-param name="dropdown" select="'true'" />
      </xsl:call-template>
    </li>
  </xsl:template>

</xsl:stylesheet>
