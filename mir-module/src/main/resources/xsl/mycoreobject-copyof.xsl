<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <xsl:include href="copynodes.xsl" />

  <!-- remove structure, service and objectID -->
  <xsl:template match="mycoreobject/@ID">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template match="mods:mods/mods:identifier">
    <!-- do nothing -->
  </xsl:template>


  <xsl:template match="structure">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template match="service">
    <!-- do nothing -->
  </xsl:template>

</xsl:stylesheet>