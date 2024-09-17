<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common"
  extension-element-prefixes="exslt"
  exclude-result-prefixes="xsl">

  <xsl:import href="resource:xsl/orcid/mir-orcid.xsl"/>

  <xsl:param name="MCR.ORCID2.Work.PublishStates" select="''"/>

  <xsl:variable name="publishStatesXml">
    <xsl:if test="$isOrcidEnabled">
      <xsl:call-template name="Tokenizer">
        <xsl:with-param name="string" select="$MCR.ORCID2.Work.PublishStates"/>
        <xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="publishStates" select="exslt:node-set($publishStatesXml)"/>

  <xsl:template name="check-state-is-publishable">
    <xsl:param name="state"/>
    <xsl:value-of select="boolean($publishStates[. = $state])"/>
  </xsl:template>

</xsl:stylesheet>
