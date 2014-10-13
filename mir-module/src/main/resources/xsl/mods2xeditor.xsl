<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods" version="1.0">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:genre[@type='intern']">
    <xsl:copy>
      <xsl:apply-templates select="@*[name()!='valueURI']" />
      <xsl:attribute name="valueURIxEditor">
        <xsl:value-of select="substring-after(@valueURI,'#')" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>