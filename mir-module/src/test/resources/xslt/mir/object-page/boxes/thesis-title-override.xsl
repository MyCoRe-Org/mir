<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='title'][contains-token(@genres, 'thesis')]" mode="metadata-box-field" priority="1">
    <dt data-field="title-override">Thesis</dt>
    <dd data-field="title-override">override</dd>
  </xsl:template>

</xsl:stylesheet>
