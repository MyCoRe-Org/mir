<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mireditorutils="http://www.mycore.de/xslt/mireditorutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="value" />

  <xsl:template match="/test-serialize-node">
    <result>
      <xsl:value-of select="mireditorutils:serialize-node(*[1])" />
    </result>
  </xsl:template>

  <xsl:template match="/test-is-valid-object-id">
    <result>
      <xsl:value-of select="mireditorutils:is-valid-object-id($value)" />
    </result>
  </xsl:template>

  <xsl:template match="/test-build-extent-pages">
    <result>
      <xsl:sequence select="mireditorutils:build-extent-pages($value)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
