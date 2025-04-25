<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template name="ouput-badge">
    <xsl:param name="text"/>

    <span class="badge badge-success">
      <xsl:value-of select="$text"/>
    </span>
  </xsl:template>
</xsl:stylesheet>
