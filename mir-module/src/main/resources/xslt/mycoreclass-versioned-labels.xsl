<xsl:stylesheet version="1.0"
                xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="mycoreclass">
    <mycoreclass xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="MCRClassification.xsd">
      <xsl:apply-templates select="@ID|node()" />
    </mycoreclass>
  </xsl:template>

  <xsl:template match="valid">
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="label[not(starts-with(@xml:lang,'x-'))]/@text">
    <xsl:attribute name="text">
      <xsl:value-of select="." />
      <xsl:apply-templates select="../../parent::valid" mode="label">
        <xsl:with-param name="lang" select="../@xml:lang" />
      </xsl:apply-templates>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="valid[@from]" mode="label" />

  <xsl:template match="valid[@until]" mode="label">
    <xsl:param name="lang" />
    <xsl:text> (</xsl:text>
    <xsl:choose>
      <xsl:when test="$lang='en'">until</xsl:when>
      <xsl:when test="$lang='de'">bis</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="mcri18n:translate('ubo.classification.versioning.until')" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="@until" mode="date" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="valid[@from][@until]" mode="label" priority="1">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="@from" mode="date" />
    <xsl:text> - </xsl:text>
    <xsl:apply-templates select="@until" mode="date" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="@from|@until" mode="date">
    <xsl:value-of select="substring(.,6,2)" />
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring(.,1,4)" />
  </xsl:template>

</xsl:stylesheet>
