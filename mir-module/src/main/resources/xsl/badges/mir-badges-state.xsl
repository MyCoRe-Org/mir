<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="i18n mcrxsl">

  <xsl:import href="xslImport:badges:badges/mir-badges-state.xsl"/>
  <xsl:include href="mir-badges-style-template.xsl"/>

  <xsl:param name="CurrentUser"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:if test="not (mcrxsl:isCurrentUserGuestUser())">
      <xsl:call-template name="output-badge">
        <xsl:with-param name="of-type" select="'doc_state'"/>
        <xsl:with-param name="badge-type" select="concat('mir-', str[@name='state'])"/>
        <xsl:with-param name="label" select="document(concat('callJava:org.apache.commons.lang3.StringUtils:capitalize:', mcrxsl:getDisplayName('state', str[@name='state'])))"/>
        <xsl:with-param name="tooltip" select="i18n:translate('component.mods.metaData.dictionary.status')"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
