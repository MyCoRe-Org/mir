<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template mode="mods2mods" match="mods:classification[@generator='mir_genres2marcgt-mycore']">
    <mods:genre>
      <xsl:copy-of select="@authority|text()" />
    </mods:genre>
  </xsl:template>

</xsl:stylesheet>
