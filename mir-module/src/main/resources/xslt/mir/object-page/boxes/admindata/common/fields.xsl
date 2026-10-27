<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode name="admindata-box-field" on-no-match="deep-skip" on-multiple-match="fail" />

  <xsl:template name="admindata-box-fields">
    <xsl:param name="names" as="xs:string*" />
    <xsl:param name="object" select="." as="element(mycoreobject)" />

    <xsl:variable name="fields">
      <xsl:for-each select="$names">
        <field name="{.}" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="$fields/field">
      <xsl:apply-templates select="." mode="admindata-box-field">
        <xsl:with-param name="object" select="$object" />
        <xsl:with-param name="field-name" select="string(@name)" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
