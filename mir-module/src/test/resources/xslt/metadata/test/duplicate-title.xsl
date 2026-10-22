<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='title']" mode="metadata-box-field">
    <dt data-field="title">Duplicate</dt>
  </xsl:template>

</xsl:stylesheet>
