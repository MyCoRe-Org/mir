<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />
  <xsl:include href="resource:xslt/mir/guidance-panel/functions/mirguidancepanel.xsl" />

  <xsl:param name="path" as="xs:string"/>

  <xsl:template match="/">
    <result>
      <xsl:value-of select="mirguidancepanel:rel-path($path)" />
    </result>
  </xsl:template>
</xsl:stylesheet>
