<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:badges/mir-badges-state.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

  <xsl:variable name="tooltip-state" select="document('i18n:component.mods.metaData.dictionary.status')/i18n/text()"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:apply-imports/>

    <xsl:if test="document('callJava:org.mycore.common.xml.MCRXMLFunctions:isCurrentUserGuestUser') = 'false'">
      <xsl:variable name="label-text-native" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:state:', str[@name='state']))"/>

      <xsl:call-template name="output-badge">
        <xsl:with-param name="of-type" select="'hit_state'"/>
        <xsl:with-param name="badge-type" select="concat('text-white mir-', str[@name='state'])"/>
        <xsl:with-param name="label" select="document(concat('callJava:org.apache.commons.lang3.StringUtils:capitalize:', $label-text-native))"/>
        <xsl:with-param name="tooltip" select="$tooltip-state"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="mycoreobject-badge">
    <xsl:apply-imports/>

    <xsl:variable name="state" select="//servstate[@classid='state']/@categid"/>

    <xsl:if test="string-length($state) &gt; 0">
      <xsl:variable name="label-text-native" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:state:', $state))"/>

      <xsl:call-template name="output-badge">
        <xsl:with-param name="of-type" select="'doc_state'"/>
        <xsl:with-param name="badge-type" select="concat('text-white mir-', $state)"/>
        <xsl:with-param name="label" select="document(concat('callJava:org.apache.commons.lang3.StringUtils:capitalize:', $label-text-native))"/>
        <xsl:with-param name="tooltip" select="$tooltip-state"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
