<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <xsl:template match="mods:classification[@generator='mir_genres2marcgt-mycore']" mode="mods2mods">
    <mods:genre>
      <xsl:copy-of select="@authority|text()" />
    </mods:genre>
  </xsl:template>
</xsl:stylesheet>