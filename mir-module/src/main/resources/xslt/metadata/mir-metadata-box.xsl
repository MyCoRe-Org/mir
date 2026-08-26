<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode name="display-metadata" on-no-match="shallow-skip" />

  <xsl:import href="xslImport:modsmeta:metadata/mir-metadata-box.xsl" />
  <xsl:import href="xslImport:metadatabox" />

  <xsl:template match="/">
    <div id="mir-metadata">
      <dl>
        <xsl:apply-templates mode="display-metadata" select="mycoreobject" />
      </dl>
    </div>

    <xsl:apply-imports/>
  </xsl:template>

</xsl:stylesheet>
