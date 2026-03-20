<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/orcid/mir-orcid.xsl"/>

  <xsl:param name="MCR.ORCID2.Work.PublishStates" select="''"/>

  <xsl:variable name="publishStates" select="tokenize($MCR.ORCID2.Work.PublishStates, ',') ! normalize-space(.)[. != '']"/>

  <xsl:template name="check-state-is-publishable">
    <xsl:param name="state"/>
    <xsl:value-of select="boolean($publishStates[. = $state])"/>
  </xsl:template>

</xsl:stylesheet>
