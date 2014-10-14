<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods" version="1.0">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="@valueURIxEditor">
    <xsl:attribute name="valueURI">
      <xsl:value-of select="concat(../@authorityURI,'#',.)" />
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>