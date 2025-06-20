<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods xlink">

  <xsl:import href="xslImport:badges:badges/mir-badges-license.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-utils.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:choose>
      <xsl:when test="arr[@name='category.top']/str[contains(text(), 'mir_licenses:')]">
        <xsl:call-template name="output-license-badge">
          <xsl:with-param name="accessConditionClass" select="arr[@name='category.top']/str[contains(text(), 'mir_licenses:')][last()]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="field[@name='category.top'][starts-with(., 'mir_licenses:')]">
        <xsl:call-template name="output-license-badge">
          <xsl:with-param name="accessConditionClass" select="field[@name='category.top'][starts-with(., 'mir_licenses:')][last()]"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="output-license-badge">
    <xsl:param name="accessConditionClass"/>
    <xsl:variable name="accessCondition">
      <xsl:value-of select="substring-after($accessConditionClass, ':')"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="contains($accessCondition, 'rights_reserved')">
          <xsl:value-of select="document('i18n:component.mods.metaData.dictionary.rightsReserved')/i18n/text()"/>
        </xsl:when>
        <xsl:when test="contains($accessCondition, 'oa_nlz')">
          <xsl:value-of select="document('i18n:component.mods.metaData.dictionary.oa_nlz.short')/i18n/text()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:mir_licenses:', $accessCondition))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="output-badge">
      <xsl:with-param name="class" select="concat('mir-badge-license-', $accessCondition)"/>
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="link"  select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category:%22', $accessConditionClass, '%22')"/>
      <xsl:with-param name="tooltip" select="document('i18n:mir.rights')/i18n/text()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
