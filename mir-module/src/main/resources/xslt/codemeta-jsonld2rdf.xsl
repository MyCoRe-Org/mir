<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:copy-of select="document(concat('codemeta2rdf:',':',.))" />
  </xsl:template>
</xsl:stylesheet>
