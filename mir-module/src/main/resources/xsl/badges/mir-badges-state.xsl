<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:badges/mir-badges-state.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-utils.xsl"/>

  <xsl:template match="doc" mode="badge">
    <xsl:apply-imports/>

    <xsl:if test="not($isCurrentUserGuest)">
      <xsl:call-template name="output-state-badge">
        <xsl:with-param name="stateValue" select="(str[@name ='state'] | field[@name ='state'])[1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="output-state-badge">
    <xsl:param name="stateValue" select="*[@name ='state'][1]"/>
    <xsl:variable name="labelTextNative" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:state:', $stateValue))"/>
    <xsl:call-template name="output-badge">
      <xsl:with-param name="class" select="'mir-badge-state'"/>
      <xsl:with-param name="badge-type" select="concat('text-white mir-', $stateValue)"/>
      <xsl:with-param name="label" select="document(concat('callJava:org.apache.commons.lang3.StringUtils:capitalize:', $labelTextNative))"/>
      <xsl:with-param name="tooltip" select="document('i18n:component.mods.metaData.dictionary.status')/i18n/text()"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
