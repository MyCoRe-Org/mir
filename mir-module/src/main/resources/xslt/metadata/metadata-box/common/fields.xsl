<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode name="metadata-box-field" on-no-match="deep-skip" on-multiple-match="fail" />

  <xsl:template name="metadata-box-fields">
    <xsl:param name="names" as="xs:string*" />
    <xsl:param name="object" select="." as="element(mycoreobject)" />
    <xsl:param name="genres" select="mirmods:genres(mirobject:mods($object))" as="xs:string*" />

    <xsl:variable name="fields">
      <xsl:for-each select="$names">
        <field name="{.}" genres="{$genres}" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="$fields/field">
      <xsl:apply-templates select="." mode="metadata-box-field">
        <xsl:with-param name="object" select="$object" />
        <xsl:with-param name="field-name" select="string(@name)" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
