<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:mir-badges.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

  <!-- terminate xslImport chain sparked in response-mir.xsl-->
  <xsl:template match="doc" mode="resultList"/>
  <!-- terminate xslImport chain sparked in mir-badges.xsl -->
  <xsl:template match="mycoreobject" mode="mycoreobject-badge"/>
</xsl:stylesheet>
