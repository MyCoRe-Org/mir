<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode name="result-action" on-no-match="deep-skip" on-multiple-match="fail" />

  <xsl:template name="result-actions">
    <xsl:param name="names" as="xs:string*" />
    <xsl:param name="doc" as="element(doc)" />
    <xsl:param name="object-id" as="xs:string" />

    <xsl:variable name="actions">
      <xsl:for-each select="$names">
        <action name="{.}" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:apply-templates select="$actions/action" mode="result-action">
      <xsl:with-param name="doc" select="$doc" tunnel="yes" />
      <xsl:with-param name="object-id" select="$object-id" tunnel="yes" />
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>
