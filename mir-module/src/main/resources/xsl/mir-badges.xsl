<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:mir-badges.xsl"/>
  <xsl:include href="mir-badges-style-template.xsl"/>

  <!-- terminate xslImport chain sparked in response-mir.xsl-->
  <xsl:template match="doc" mode="resultList"/>
</xsl:stylesheet>
