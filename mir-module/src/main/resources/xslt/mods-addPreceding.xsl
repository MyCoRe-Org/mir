<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <!-- used as editor preprocessing which copies the object removes all related items and add´s the copied object as preceding object-->

  <xsl:include href="resource:xsl/copynodes.xsl" />

  <xsl:template match="mods:mods">
    <mods:mods>
      <xsl:variable name="oldObjectContent">
        <xsl:apply-templates select='@*|node()' />
      </xsl:variable>
      <xsl:copy-of select="$oldObjectContent" />
      <mods:relatedItem type="preceding" xlink:href="{/mycoreobject/@ID}" xlink:type="simple">
        <xsl:copy-of select="$oldObjectContent" />
      </mods:relatedItem>
    </mods:mods>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='preceding']">
    <!-- remove existing preceding relations only; the previous version is added as the new
         preceding object above. All other related items (host, series, ...) are kept (MIR-1590). -->
  </xsl:template>

</xsl:stylesheet>
