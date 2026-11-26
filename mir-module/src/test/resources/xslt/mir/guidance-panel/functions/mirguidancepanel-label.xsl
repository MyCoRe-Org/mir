<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />
  <xsl:include href="resource:xslt/mir/guidance-panel/functions/mirguidancepanel.xsl" />

  <xsl:param name="current-lang" />
  <xsl:param name="default-lang" />

  <xsl:template match="/test-label">
    <result>
      <xsl:value-of select="mirguidancepanel:label(label, $current-lang, $default-lang)" />
    </result>
  </xsl:template>
</xsl:stylesheet>
