<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl">

  <xsl:include href="xslInclude:solrResponseBadges"/>

  <xsl:template name="mir-hit-badges">
    <xsl:call-template name="hit-oa"/>
    <xsl:call-template name="hit-type"/>
    <xsl:call-template name="hit-licence"/>
    <xsl:call-template name="hit-date"/>
    <xsl:call-template name="hit-state"/>
  </xsl:template>
</xsl:stylesheet>
