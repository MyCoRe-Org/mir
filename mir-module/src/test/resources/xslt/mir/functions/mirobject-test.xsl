<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="value" />

  <xsl:template match="/test-edit-url">
    <result>
      <xsl:value-of select="mirobject:edit-url($value)" />
    </result>
  </xsl:template>

</xsl:stylesheet>
