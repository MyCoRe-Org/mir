<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />
  <xsl:param name="json" />

  <xsl:template match="/">
    <xsl:copy-of select="json-to-xml($json)" />
  </xsl:template>

</xsl:stylesheet>