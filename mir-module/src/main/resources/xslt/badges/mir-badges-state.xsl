<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrstringutils="http://www.mycore.de/xslt/stringutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:badges:badges/mir-badges-state.xsl"/>
  <xsl:include href="resource:xslt/badges/mir-badges-utils.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:if test="(str[@name ='state'] | field[@name ='state'])[1]">
      <xsl:if test="not($isCurrentUserGuest)">
        <xsl:call-template name="output-state-badge">
          <xsl:with-param name="stateValue" select="(str[@name ='state'] | field[@name ='state'])[1]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="output-state-badge">
    <xsl:param name="stateValue" select="*[@name ='state'][1]"/>
    <xsl:call-template name="output-badge">
      <xsl:with-param name="class" select="concat('mir-badge-state-', $stateValue)"/>
      <xsl:with-param name="label"
        select="mcrstringutils:capitalize(mcrclassification:current-label-text(mcrclassification:category('state', $stateValue)))"/>
      <xsl:with-param name="tooltip" select="mcri18n:translate('component.mods.metaData.dictionary.status')"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
