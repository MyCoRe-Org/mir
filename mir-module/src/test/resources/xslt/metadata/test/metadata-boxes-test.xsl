<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/metadata/mir-admindata-box.xsl" />

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:template match="/">
    <boxes>
      <xsl:apply-imports />
    </boxes>
  </xsl:template>

</xsl:stylesheet>
