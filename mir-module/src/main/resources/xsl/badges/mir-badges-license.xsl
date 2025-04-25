<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n mcrxsl">

  <xsl:import href="xslImport:badges:badges/mir-badges-license.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:if test="arr[@name='category.top']/str[contains(text(), 'mir_licenses:')]">
      <xsl:variable name="accessConditionClass" select="arr[@name='category.top']/str[contains(text(), 'mir_licenses:')][last()]"/>
      <xsl:variable name="accessCondition">
        <xsl:value-of
          select="substring-after($accessConditionClass, ':')"/>
      </xsl:variable>

      <xsl:variable name="label">
        <xsl:choose>
          <xsl:when test="contains($accessCondition, 'rights_reserved')">
            <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')"/>
          </xsl:when>
          <xsl:when test="contains($accessCondition, 'oa_nlz')">
            <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.oa_nlz.short')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mcrxsl:getDisplayName('mir_licenses', $accessCondition)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:call-template name="output-badge">
        <xsl:with-param name="of-type" select="'hit_license'"/>
        <xsl:with-param name="badge-type" select="'badge-primary'"/>
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="link"  select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category:%22', $accessConditionClass, '%22')"/>
        <xsl:with-param name="link-class" select="'access_condition'"/>
        <xsl:with-param name="tooltip" select="i18n:translate('mir.rights')"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
